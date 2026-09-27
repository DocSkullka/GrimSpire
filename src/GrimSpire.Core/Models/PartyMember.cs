namespace GrimSpire.Core.Models;

public enum PartyRole
{
    Hero,       // Midline DPS (The Wanderer)
    Tank,       // Frontline Tank (The Bulwark)
    Thief,      // Flank Rogue & Lockpicker (The Nightshade)
    Cleric      // Backline Healer / Blood Mage (The Bloodweaver)
}

/// <summary>
/// A squad member in the tactical 2.5D party formation.
/// </summary>
public class PartyMember
{
    public string Id { get; set; } = Guid.NewGuid().ToString("N");
    public string Name { get; set; }
    public PartyRole Role { get; set; }
    public Stats BaseStats { get; set; }
    public double CurrentHealth { get; set; }
    public bool IsRecruited { get; set; } = true;
    public bool IsActiveInSquad { get; set; } = true;

    // Tactical ability state
    public double AbilityCooldownTimer { get; set; } = 0.0;
    public double TauntDurationRemaining { get; set; } = 0.0;
    public double BarrierAbsorption { get; set; } = 0.0;
    public double SoulGauge { get; set; } = 0.0; // Hero Soul Cleave (0 - 100)

    public bool IsAlive => CurrentHealth > 0;

    public PartyMember(string name, PartyRole role, Stats baseStats)
    {
        Name = name;
        Role = role;
        BaseStats = baseStats;
        CurrentHealth = baseStats.MaxHealth;
    }

    public static PartyMember CreateHero() =>
        new("The Wanderer", PartyRole.Hero, new Stats
        {
            MaxHealth = 120,
            AttackDamage = 18,
            AttackSpeed = 1.0,
            Armor = 8,
            CritChance = 0.10,
            CritMultiplier = 1.5,
            Lifesteal = 0.05
        });

    public static PartyMember CreateTank() =>
        new("The Bulwark", PartyRole.Tank, new Stats
        {
            MaxHealth = 200,
            AttackDamage = 14,
            AttackSpeed = 0.75,
            Armor = 28,
            CritChance = 0.05,
            CritMultiplier = 1.5,
            DamageReduction = 0.20
        });

    public static PartyMember CreateThief() =>
        new("The Nightshade", PartyRole.Thief, new Stats
        {
            MaxHealth = 95,
            AttackDamage = 26,
            AttackSpeed = 1.45,
            Armor = 6,
            CritChance = 0.35,
            CritMultiplier = 2.2,
            DodgeChance = 0.22,
            GoldMultiplier = 0.35
        });

    public static PartyMember CreateCleric() =>
        new("The Bloodweaver", PartyRole.Cleric, new Stats
        {
            MaxHealth = 90,
            AttackDamage = 15,
            AttackSpeed = 0.90,
            Armor = 8,
            CritChance = 0.08,
            CritMultiplier = 1.5,
            Lifesteal = 0.15
        });

    public void Heal(double amount)
    {
        CurrentHealth = Math.Clamp(CurrentHealth + amount, 0, BaseStats.MaxHealth);
    }

    public double TakeDamage(double rawDamage, bool isTargetedByTaunt = false)
    {
        // Taunt shield block absorbs 60% of incoming damage
        double mitDamage = rawDamage;
        if (TauntDurationRemaining > 0.0)
        {
            mitDamage *= 0.40;
        }

        // Barrier absorption
        if (BarrierAbsorption > 0)
        {
            double absorbed = Math.Min(BarrierAbsorption, mitDamage);
            BarrierAbsorption -= absorbed;
            mitDamage -= absorbed;
        }

        double finalDamage = Math.Max(1.0, mitDamage * (1.0 - BaseStats.DamageReduction) - BaseStats.Armor * 0.4);
        CurrentHealth = Math.Max(0, CurrentHealth - finalDamage);
        return finalDamage;
    }
}
