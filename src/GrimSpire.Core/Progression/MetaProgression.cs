using GrimSpire.Core.Models;

namespace GrimSpire.Core.Progression;

public enum MetaUpgradeType
{
    Health,
    Damage,
    Armor,
    AttackSpeed,
    CritChance,
    Lifesteal,
    GoldMultiplier
}

public class MetaProgression
{
    public int PersistentGold { get; set; } = 0;
    public int HighestFloorReached { get; set; } = 1;
    public int TotalRunsPlayed { get; set; } = 0;

    public Dictionary<MetaUpgradeType, int> UpgradeRanks { get; set; } = new()
    {
        { MetaUpgradeType.Health, 0 },
        { MetaUpgradeType.Damage, 0 },
        { MetaUpgradeType.Armor, 0 },
        { MetaUpgradeType.AttackSpeed, 0 },
        { MetaUpgradeType.CritChance, 0 },
        { MetaUpgradeType.Lifesteal, 0 },
        { MetaUpgradeType.GoldMultiplier, 0 }
    };

    public int GetUpgradeCost(MetaUpgradeType type)
    {
        int currentRank = UpgradeRanks[type];
        return type switch
        {
            MetaUpgradeType.Health => 50 * (currentRank + 1),
            MetaUpgradeType.Damage => 60 * (currentRank + 1),
            MetaUpgradeType.Armor => 55 * (currentRank + 1),
            MetaUpgradeType.AttackSpeed => 75 * (currentRank + 1),
            MetaUpgradeType.CritChance => 80 * (currentRank + 1),
            MetaUpgradeType.Lifesteal => 100 * (currentRank + 1),
            MetaUpgradeType.GoldMultiplier => 70 * (currentRank + 1),
            _ => 100 * (currentRank + 1)
        };
    }

    public bool CanAfford(MetaUpgradeType type) => PersistentGold >= GetUpgradeCost(type);

    public bool PurchaseUpgrade(MetaUpgradeType type)
    {
        int cost = GetUpgradeCost(type);
        if (PersistentGold < cost) return false;

        PersistentGold -= cost;
        UpgradeRanks[type]++;
        return true;
    }

    public Stats CalculateStartingStats()
    {
        var baseStats = new Stats();

        return new Stats
        {
            MaxHealth = baseStats.MaxHealth + (UpgradeRanks[MetaUpgradeType.Health] * 12.0),
            AttackDamage = baseStats.AttackDamage + (UpgradeRanks[MetaUpgradeType.Damage] * 2.5),
            Armor = baseStats.Armor + (UpgradeRanks[MetaUpgradeType.Armor] * 2.0),
            AttackSpeed = baseStats.AttackSpeed + (UpgradeRanks[MetaUpgradeType.AttackSpeed] * 0.05),
            CritChance = baseStats.CritChance + (UpgradeRanks[MetaUpgradeType.CritChance] * 0.01),
            CritMultiplier = baseStats.CritMultiplier,
            Lifesteal = baseStats.Lifesteal + (UpgradeRanks[MetaUpgradeType.Lifesteal] * 0.01),
            DodgeChance = baseStats.DodgeChance
        };
    }

    public double GetGoldMultiplier() => 1.0 + (UpgradeRanks[MetaUpgradeType.GoldMultiplier] * 0.08);

    public void OnRunCompleted(int runGold, int maxFloorReached)
    {
        TotalRunsPlayed++;
        PersistentGold += runGold;
        if (maxFloorReached > HighestFloorReached)
        {
            HighestFloorReached = maxFloorReached;
        }
    }
}
