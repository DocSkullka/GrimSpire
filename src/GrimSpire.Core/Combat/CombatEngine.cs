using GrimSpire.Core.Models;

namespace GrimSpire.Core.Combat;

/// <summary>
/// Deterministic auto-battler simulation engine.
/// Simulates combat in discrete ticks (default 0.05s).
/// </summary>
public class CombatEngine
{
    private readonly Random _rng;
    private const double TickStep = 0.05; // 20 updates per second
    private const double MaxBattleDurationSeconds = 120.0; // 2 minutes timeout cap

    public CombatEngine(int? seed = null)
    {
        _rng = seed.HasValue ? new Random(seed.Value) : new Random();
    }

    /// <summary>
    /// Simulates automatic combat between the player and one or more enemies.
    /// Returns full event telemetry for UI presentation or headless verification.
    /// </summary>
    public CombatResult SimulateBattle(Character player, List<Enemy> enemies)
    {
        if (enemies == null || enemies.Count == 0)
        {
            return new CombatResult
            {
                PlayerWon = player.CurrentHealth > 0,
                DurationSeconds = 0.0,
                TotalDamageDealt = 0,
                TotalDamageTaken = 0,
                TotalHealingDone = 0,
                PlayerEndingHealth = player.CurrentHealth,
                Events = Array.Empty<CombatEvent>()
            };
        }

        var events = new List<CombatEvent>();
        var effectivePlayerStats = player.GetEffectiveStats();
        
        double playerSpeed = Math.Clamp(effectivePlayerStats.AttackSpeed, 0.1, 10.0);
        double playerCooldownTimer = 0.0;

        var activeEnemies = enemies.Select(e => new EnemyCombatant(e)).ToList();

        double totalDmgDealt = 0;
        double totalDmgTaken = 0;
        double totalHealing = 0;
        double currentTime = 0.0;

        while (currentTime < MaxBattleDurationSeconds)
        {
            currentTime += TickStep;
            playerCooldownTimer -= TickStep;

            // 1. Check if all enemies are defeated
            var currentTarget = activeEnemies.FirstOrDefault(e => e.IsAlive);
            if (currentTarget == null)
            {
                events.Add(new CombatEvent
                {
                    TimestampSeconds = Math.Round(currentTime, 2),
                    Type = CombatEventType.UnitDefeated,
                    Source = player.Name,
                    Target = "All Enemies",
                    Message = $"{player.Name} stands victorious!"
                });
                break;
            }

            // 2. Player attacks if ready
            if (playerCooldownTimer <= 0.0 && player.CurrentHealth > 0)
            {
                playerCooldownTimer = 1.0 / playerSpeed;
                PerformAttack(
                    attackerName: player.Name,
                    attackerStats: effectivePlayerStats,
                    targetName: currentTarget.Enemy.Name,
                    targetStats: currentTarget.Enemy.Stats,
                    getCurrentTargetHp: () => currentTarget.CurrentHealth,
                    setTargetHp: hp => currentTarget.CurrentHealth = hp,
                    healAttacker: heal =>
                    {
                        player.Heal(heal);
                        totalHealing += heal;
                    },
                    currentTime: currentTime,
                    events: events,
                    onDamage: dmg => totalDmgDealt += dmg
                );

                if (!currentTarget.IsAlive)
                {
                    events.Add(new CombatEvent
                    {
                        TimestampSeconds = Math.Round(currentTime, 2),
                        Type = CombatEventType.UnitDefeated,
                        Source = player.Name,
                        Target = currentTarget.Enemy.Name,
                        Message = $"{currentTarget.Enemy.Name} has perished!"
                    });
                }
            }

            // Check if enemies still alive before enemy attacks
            if (!activeEnemies.Any(e => e.IsAlive))
            {
                break;
            }

            // 3. Enemies attack player
            foreach (var enemy in activeEnemies.Where(e => e.IsAlive))
            {
                enemy.CooldownTimer -= TickStep;
                if (enemy.CooldownTimer <= 0.0)
                {
                    double enemySpeed = Math.Clamp(enemy.Enemy.Stats.AttackSpeed, 0.1, 10.0);
                    enemy.CooldownTimer = 1.0 / enemySpeed;

                    PerformAttack(
                        attackerName: enemy.Enemy.Name,
                        attackerStats: enemy.Enemy.Stats,
                        targetName: player.Name,
                        targetStats: effectivePlayerStats,
                        getCurrentTargetHp: () => player.CurrentHealth,
                        setTargetHp: hp => player.CurrentHealth = hp,
                        healAttacker: heal => enemy.CurrentHealth = Math.Clamp(enemy.CurrentHealth + heal, 0, enemy.Enemy.Stats.MaxHealth),
                        currentTime: currentTime,
                        events: events,
                        onDamage: dmg => totalDmgTaken += dmg
                    );

                    if (player.CurrentHealth <= 0)
                    {
                        events.Add(new CombatEvent
                        {
                            TimestampSeconds = Math.Round(currentTime, 2),
                            Type = CombatEventType.UnitDefeated,
                            Source = enemy.Enemy.Name,
                            Target = player.Name,
                            Message = $"{player.Name} was slain by {enemy.Enemy.Name}!"
                        });
                        break;
                    }
                }
            }

            // 4. Check if player fell
            if (player.CurrentHealth <= 0)
            {
                break;
            }
        }

        // Check for timeout
        if (currentTime >= MaxBattleDurationSeconds && player.CurrentHealth > 0 && activeEnemies.Any(e => e.IsAlive))
        {
            events.Add(new CombatEvent
            {
                TimestampSeconds = Math.Round(currentTime, 2),
                Type = CombatEventType.UnitDefeated,
                Source = "The Spire's Creeping Miasma",
                Target = player.Name,
                Message = $"Time limit reached! The suffocating dark miasma of the Spire claims {player.Name}'s soul!"
            });
            player.CurrentHealth = 0;
        }

        // Sync final HP back to Enemy objects
        foreach (var combatant in activeEnemies)
        {
            combatant.Enemy.CurrentHealth = combatant.CurrentHealth;
        }

        bool playerWon = player.CurrentHealth > 0 && activeEnemies.All(e => !e.IsAlive);

        return new CombatResult
        {
            PlayerWon = playerWon,
            DurationSeconds = Math.Round(currentTime, 2),
            TotalDamageDealt = Math.Round(totalDmgDealt, 1),
            TotalDamageTaken = Math.Round(totalDmgTaken, 1),
            TotalHealingDone = Math.Round(totalHealing, 1),
            PlayerEndingHealth = Math.Max(0, Math.Round(player.CurrentHealth, 1)),
            Events = events
        };
    }

    private void PerformAttack(
        string attackerName,
        Stats attackerStats,
        string targetName,
        Stats targetStats,
        Func<double> getCurrentTargetHp,
        Action<double> setTargetHp,
        Action<double> healAttacker,
        double currentTime,
        List<CombatEvent> events,
        Action<double> onDamage)
    {
        // 1. Evade / Dodge Check
        if (_rng.NextDouble() < targetStats.DodgeChance)
        {
            events.Add(new CombatEvent
            {
                TimestampSeconds = Math.Round(currentTime, 2),
                Type = CombatEventType.Evaded,
                Source = attackerName,
                Target = targetName,
                Message = $"{targetName} swiftly dodged {attackerName}'s blow!"
            });
            return;
        }

        // 2. Critical Strike Check
        bool isCrit = _rng.NextDouble() < attackerStats.CritChance;
        double critMult = attackerStats.CritMultiplier > 0 ? attackerStats.CritMultiplier : 1.5;
        double rawDamage = attackerStats.AttackDamage * (isCrit ? critMult : 1.0);

        // 3. Armor Mitigation
        double mitigationMultiplier = Stats.CalculateDamageMitigationMultiplier(targetStats.Armor);
        double actualDamage = Math.Max(1.0, rawDamage * mitigationMultiplier);

        // Apply Damage
        double newHp = Math.Max(0, getCurrentTargetHp() - actualDamage);
        setTargetHp(newHp);
        onDamage(actualDamage);

        // 4. Lifesteal Check
        if (attackerStats.Lifesteal > 0)
        {
            double healAmount = actualDamage * attackerStats.Lifesteal;
            healAttacker(healAmount);
            events.Add(new CombatEvent
            {
                TimestampSeconds = Math.Round(currentTime, 2),
                Type = CombatEventType.Healed,
                Source = attackerName,
                Target = attackerName,
                Value = Math.Round(healAmount, 1),
                Message = $"{attackerName} drained {Math.Round(healAmount, 1)} health from the strike!"
            });
        }

        events.Add(new CombatEvent
        {
            TimestampSeconds = Math.Round(currentTime, 2),
            Type = isCrit ? CombatEventType.CriticalHit : CombatEventType.DamageDealt,
            Source = attackerName,
            Target = targetName,
            Value = Math.Round(actualDamage, 1),
            Message = isCrit
                ? $"*CRITICAL!* {attackerName} brutally struck {targetName} for {Math.Round(actualDamage, 1)} dmg! ({Math.Round(newHp, 1)} HP left)"
                : $"{attackerName} struck {targetName} for {Math.Round(actualDamage, 1)} dmg. ({Math.Round(newHp, 1)} HP left)"
        });
    }

    private class EnemyCombatant
    {
        public Enemy Enemy { get; }
        public double CurrentHealth { get; set; }
        public double CooldownTimer { get; set; }
        public bool IsAlive => CurrentHealth > 0;

        public EnemyCombatant(Enemy enemy)
        {
            Enemy = enemy;
            CurrentHealth = enemy.CurrentHealth;
            double speed = Math.Clamp(enemy.Stats.AttackSpeed, 0.1, 10.0);
            CooldownTimer = 1.0 / speed;
        }
    }
}
