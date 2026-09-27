namespace GrimSpire.Core.Models;

public enum ItemSlot
{
    Weapon,
    Armor,
    Helmet,
    OffHand,
    Accessory
}

public enum ItemRarity
{
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
    Cursed
}

/// <summary>
/// Equipment item obtained during tower climbing.
/// </summary>
public record Item
{
    public string Id { get; init; } = Guid.NewGuid().ToString("N");
    public string Name { get; init; } = string.Empty;
    public string Description { get; init; } = string.Empty;
    public ItemSlot Slot { get; init; }
    public ItemRarity Rarity { get; init; } = ItemRarity.Common;
    public Stats StatBonuses { get; init; } = new();
    public string SpecialEffect { get; init; } = string.Empty;

    public string GetRarityColorCode() => Rarity switch
    {
        ItemRarity.Common => "\u001b[37m", // Gray/White
        ItemRarity.Uncommon => "\u001b[32m", // Green
        ItemRarity.Rare => "\u001b[34m", // Blue
        ItemRarity.Epic => "\u001b[35m", // Purple
        ItemRarity.Legendary => "\u001b[33m", // Gold/Yellow
        ItemRarity.Cursed => "\u001b[31m", // Red
        _ => "\u001b[0m"
    };
}
