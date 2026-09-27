using GrimSpire.Core.Models;

namespace GrimSpire.Core.Progression;

public record FusionResult
{
    public bool Success { get; init; }
    public Item? UpgradedItem { get; init; }
    public string Message { get; init; } = string.Empty;
}

public static class ItemFusionService
{
    /// <summary>
    /// Fuses two items of the same slot/type into an evolved higher-tier relic.
    /// Tier 1 + Tier 1 => Tier 2 (Tempered / +60% stats, +10% bonus perk)
    /// Tier 2 + Tier 1 => Tier 3 (Masterwork Void-Forged / +140% stats, +20% bonus perk)
    /// </summary>
    public static FusionResult FuseItems(Item baseItem, Item duplicateItem)
    {
        if (baseItem.Slot != duplicateItem.Slot)
        {
            return new FusionResult
            {
                Success = false,
                Message = "Items must occupy the same equipment slot to fuse."
            };
        }

        int currentTier = 1;
        if (baseItem.Name.Contains("[Tier III]")) currentTier = 3;
        else if (baseItem.Name.Contains("[Tier II]")) currentTier = 2;

        if (currentTier >= 3)
        {
            return new FusionResult
            {
                Success = false,
                Message = "Item is already at maximum Tier III evolution."
            };
        }

        int newTier = currentTier + 1;
        double multiplier = newTier == 2 ? 1.6 : 2.4;

        string cleanName = baseItem.Name.Replace(" [Tier II]", "").Replace(" [Tier III]", "");
        string newName = $"{cleanName} [Tier { (newTier == 2 ? "II" : "III") }]";

        var upgradedStats = new Stats
        {
            MaxHealth = Math.Round(baseItem.StatBonuses.MaxHealth * multiplier),
            AttackDamage = Math.Round(baseItem.StatBonuses.AttackDamage * multiplier),
            Armor = Math.Round(baseItem.StatBonuses.Armor * multiplier),
            AttackSpeed = Math.Round(baseItem.StatBonuses.AttackSpeed * (newTier == 2 ? 1.15 : 1.30), 2),
            CritChance = Math.Round(baseItem.StatBonuses.CritChance * (newTier == 2 ? 1.25 : 1.50), 2),
            CritMultiplier = Math.Round(baseItem.StatBonuses.CritMultiplier * (newTier == 2 ? 1.20 : 1.40), 2),
            Lifesteal = Math.Round(baseItem.StatBonuses.Lifesteal * (newTier == 2 ? 1.25 : 1.50), 2),
            DodgeChance = Math.Round(baseItem.StatBonuses.DodgeChance * (newTier == 2 ? 1.20 : 1.40), 2),
            GoldMultiplier = Math.Round(baseItem.StatBonuses.GoldMultiplier * (newTier == 2 ? 1.25 : 1.50), 2),
            DamageReduction = Math.Round(baseItem.StatBonuses.DamageReduction * (newTier == 2 ? 1.20 : 1.40), 2)
        };

        var fusedItem = baseItem with
        {
            Id = Guid.NewGuid().ToString("N"),
            Name = newName,
            StatBonuses = upgradedStats,
            Description = $"{baseItem.Description} (Fused to Tier {newTier}: augmented power).",
            SpecialEffect = newTier == 2 ? "+10% Sanguine Cleave bonus" : "+25% Void Echo burst"
        };

        return new FusionResult
        {
            Success = true,
            UpgradedItem = fusedItem,
            Message = $"Successfully forged {newName}!"
        };
    }

    /// <summary>
    /// Generates smart loot draft excluding direct redundant duplicates.
    /// </summary>
    public static List<Item> GenerateSmartDraft(
        IReadOnlyCollection<Item> currentEquipped,
        IReadOnlyList<Item> catalog,
        int count,
        Random? rng = null)
    {
        var random = rng ?? new Random();
        if (catalog.Count <= count) return catalog.ToList();

        var equippedIds = new HashSet<string>(currentEquipped.Select(i => i.Id));
        var equippedNames = new HashSet<string>(currentEquipped.Select(i => i.Name));

        // Prioritize items that are NOT direct duplicates of equipped items
        var pool = catalog.Where(i => !equippedNames.Contains(i.Name)).ToList();
        if (pool.Count < count)
        {
            pool = catalog.ToList();
        }

        var shuffled = pool.OrderBy(_ => random.Next()).ToList();
        var selected = new List<Item>();
        var usedSlots = new HashSet<ItemSlot>();

        // Diversity first: prefer different slots
        foreach (var item in shuffled)
        {
            if (!usedSlots.Contains(item.Slot))
            {
                selected.Add(item);
                usedSlots.Add(item.Slot);
                if (selected.Count >= count) break;
            }
        }

        // Fill remaining
        if (selected.Count < count)
        {
            foreach (var item in shuffled)
            {
                if (!selected.Any(s => s.Id == item.Id))
                {
                    selected.Add(item);
                    if (selected.Count >= count) break;
                }
            }
        }

        return selected;
    }
}
