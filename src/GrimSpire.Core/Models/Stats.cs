namespace GrimSpire.Core.Models;

/// <summary>
/// Immutable combat attributes for characters and enemies.
/// Supports additive combination via operator +.
/// </summary>
public record Stats
{
    public double MaxHealth { get; init; } = 100;
    public double AttackDamage { get; init; } = 15;
    public double Armor { get; init; } = 5;
    public double AttackSpeed { get; init; } = 1.0; // Attacks per second
    public double CritChance { get; init; } = 0.05; // 5% default
    public double CritMultiplier { get; init; } = 1.5; // 150% critical damage
    public double Lifesteal { get; init; } = 0.0; // Percentage of damage restored as HP
    public double DodgeChance { get; init; } = 0.05; // 5% chance to evade physical attack

    public static Stats operator +(Stats a, Stats b) => new()
    {
        MaxHealth = Math.Max(1, a.MaxHealth + b.MaxHealth),
        AttackDamage = Math.Max(1, a.AttackDamage + b.AttackDamage),
        Armor = Math.Max(0, a.Armor + b.Armor),
        AttackSpeed = Math.Clamp(a.AttackSpeed + b.AttackSpeed, 0.2, 5.0),
        CritChance = Math.Clamp(a.CritChance + b.CritChance, 0.0, 1.0),
        CritMultiplier = Math.Max(1.0, a.CritMultiplier + (b.CritMultiplier > 1.0 ? b.CritMultiplier - 1.0 : b.CritMultiplier)),
        Lifesteal = Math.Clamp(a.Lifesteal + b.Lifesteal, 0.0, 1.0),
        DodgeChance = Math.Clamp(a.DodgeChance + b.DodgeChance, 0.0, 0.75)
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
