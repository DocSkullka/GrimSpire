namespace GrimSpire.Core.Models;

/// <summary>
/// Immutable combat attributes for characters and enemies.
/// Supports additive combination via operator +.
/// </summary>
public record Stats
{
    public double MaxHealth { get; init; } = 0;
    public double AttackDamage { get; init; } = 0;
    public double Armor { get; init; } = 0;
    public double AttackSpeed { get; init; } = 0;
    public double CritChance { get; init; } = 0;
    public double CritMultiplier { get; init; } = 0;
    public double Lifesteal { get; init; } = 0;
    public double DodgeChance { get; init; } = 0;
    public double DamageReduction { get; init; } = 0;
    public double GoldMultiplier { get; init; } = 0;

    /// <summary>
    /// Default starting attributes for an un-upgraded fresh adventurer.
    /// </summary>
    public static Stats DefaultHero => new()
    {
        MaxHealth = 100,
        AttackDamage = 15,
        Armor = 5,
        AttackSpeed = 1.0,
        CritChance = 0.05,
        CritMultiplier = 1.5,
        Lifesteal = 0.0,
        DodgeChance = 0.05,
        DamageReduction = 0.0,
        GoldMultiplier = 0.0
    };

    public static Stats operator +(Stats a, Stats b) => new()
    {
        MaxHealth = Math.Max(0, a.MaxHealth + b.MaxHealth),
        AttackDamage = Math.Max(0, a.AttackDamage + b.AttackDamage),
        Armor = Math.Max(0, a.Armor + b.Armor),
        AttackSpeed = Math.Clamp(a.AttackSpeed + b.AttackSpeed, 0.0, 10.0),
        CritChance = Math.Clamp(a.CritChance + b.CritChance, 0.0, 1.0),
        CritMultiplier = Math.Max(0.0, a.CritMultiplier + b.CritMultiplier),
        Lifesteal = Math.Clamp(a.Lifesteal + b.Lifesteal, 0.0, 1.0),
        DodgeChance = Math.Clamp(a.DodgeChance + b.DodgeChance, 0.0, 0.75),
        DamageReduction = Math.Clamp(a.DamageReduction + b.DamageReduction, 0.0, 0.80),
        GoldMultiplier = Math.Max(0.0, a.GoldMultiplier + b.GoldMultiplier)
    };

    /// <summary>
    /// Computes damage multiplier after armor reduction.
    /// Formula: 100 / (100 + armor). Armor 100 -> 50% damage reduction.
    /// </summary>
    public static double CalculateDamageMitigationMultiplier(double armor)
    {
        if (armor <= 0) return 1.0;
        return 100.0 / (100.0 + armor);
    }
}
