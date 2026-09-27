using GrimSpire.Core.Combat;
using GrimSpire.Core.Models;
using Xunit;

namespace GrimSpire.Tests;

public class CombatTests
{
    [Fact]
    public void Combat_OverpoweredPlayer_DefeatsEnemy()
    {
        var player = new Character(new Stats
        {
            MaxHealth = 500,
            AttackDamage = 100,
            AttackSpeed = 2.0,
            Armor = 50
        });

        var enemy = new Enemy("Test Imp", new Stats
        {
            MaxHealth = 30,
            AttackDamage = 2,
            AttackSpeed = 0.5,
            Armor = 0
        });

        var engine = new CombatEngine(seed: 42);
        var result = engine.SimulateBattle(player, new List<Enemy> { enemy });

        Assert.True(result.PlayerWon);
        Assert.True(result.TotalDamageDealt >= 30);
        Assert.True(result.PlayerEndingHealth > 0);
        Assert.NotEmpty(result.Events);
    }

    [Fact]
    public void Combat_DeadlyEnemy_DefeatsWeakPlayer()
    {
        var player = new Character(new Stats
        {
            MaxHealth = 20,
            AttackDamage = 1,
            AttackSpeed = 0.5,
            Armor = 0
        });

        var boss = new Enemy("Tower Titan", new Stats
        {
            MaxHealth = 1000,
            AttackDamage = 150,
            AttackSpeed = 2.0,
            Armor = 50
        }, isBoss: true);

        var engine = new CombatEngine(seed: 42);
        var result = engine.SimulateBattle(player, new List<Enemy> { boss });

        Assert.False(result.PlayerWon);
        Assert.Equal(0, player.CurrentHealth);
        Assert.Contains(result.Events, e => e.Type == CombatEventType.UnitDefeated && e.Target == player.Name);
    }

    [Fact]
    public void Combat_Lifesteal_HealsAttacker()
    {
        var player = new Character(new Stats
        {
            MaxHealth = 100,
            AttackDamage = 50,
            AttackSpeed = 1.0,
            Lifesteal = 0.50, // 50% lifesteal
            CritChance = 0.0,
            DodgeChance = 0.0
        });
        player.CurrentHealth = 20; // Damaged

        var dummy = new Enemy("Target Dummy", new Stats
        {
            MaxHealth = 200,
            AttackDamage = 0,
            AttackSpeed = 0.1,
            Armor = 0,
            DodgeChance = 0.0
        });

        var engine = new CombatEngine(seed: 42);
        var result = engine.SimulateBattle(player, new List<Enemy> { dummy });

        Assert.True(result.TotalHealingDone > 0);
        Assert.True(player.CurrentHealth > 20);
    }

    [Fact]
    public void Combat_MultiEnemy_SimulatesAllEnemies()
    {
        var player = new Character(new Stats
        {
            MaxHealth = 250,
            AttackDamage = 35,
            AttackSpeed = 1.5,
            Armor = 10
        });

        var enemy1 = new Enemy("Skeleton 1", new Stats { MaxHealth = 25, AttackDamage = 5 });
        var enemy2 = new Enemy("Skeleton 2", new Stats { MaxHealth = 25, AttackDamage = 5 });
        var enemy3 = new Enemy("Skeleton 3", new Stats { MaxHealth = 25, AttackDamage = 5 });

        var engine = new CombatEngine(seed: 42);
        var result = engine.SimulateBattle(player, new List<Enemy> { enemy1, enemy2, enemy3 });

        Assert.True(result.PlayerWon);
        Assert.True(result.TotalDamageDealt >= 75);
    }
}
