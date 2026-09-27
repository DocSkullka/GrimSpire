using GrimSpire.Core.Models;
using Xunit;

namespace GrimSpire.Tests;

public class StatsTests
{
    [Fact]
    public void ArmorMitigation_ZeroArmor_ReturnsNoMitigation()
    {
        double multiplier = Stats.CalculateDamageMitigationMultiplier(0);
        Assert.Equal(1.0, multiplier);
    }

    [Fact]
    public void ArmorMitigation_100Armor_ReturnsFiftyPercentReduction()
    {
        double multiplier = Stats.CalculateDamageMitigationMultiplier(100);
        Assert.Equal(0.5, multiplier);
    }

    [Fact]
    public void ArmorMitigation_NegativeArmor_ReturnsNoMitigation()
    {
        double multiplier = Stats.CalculateDamageMitigationMultiplier(-20);
        Assert.Equal(1.0, multiplier);
    }

    [Fact]
    public void StatsAddition_CombinesCorrectlyAndClampsValues()
    {
        var a = new Stats
        {
            MaxHealth = 100,
            AttackDamage = 15,
            Armor = 10,
            CritChance = 0.50,
            DodgeChance = 0.60
        };

        var b = new Stats
        {
            MaxHealth = 50,
            AttackDamage = 10,
            Armor = 5,
            CritChance = 0.60, // Should clamp to 1.0
            DodgeChance = 0.30 // Should clamp to max 0.75
        };

        var result = a + b;
        Assert.Equal(150, result.MaxHealth);
        Assert.Equal(25, result.AttackDamage);
        Assert.Equal(15, result.Armor);
        Assert.Equal(1.0, result.CritChance);
        Assert.Equal(0.75, result.DodgeChance);
    }
}
