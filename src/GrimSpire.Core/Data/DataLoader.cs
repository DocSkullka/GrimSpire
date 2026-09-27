using System.Text.Json;
using System.Text.Json.Serialization;
using GrimSpire.Core.Models;

namespace GrimSpire.Core.Data;

public record ItemTemplate
{
    public string Id { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string Slot { get; init; } = string.Empty;
    public string Rarity { get; init; } = string.Empty;
    public string Description { get; init; } = string.Empty;
    public Stats Stats { get; init; } = new();

    public Item ToItem()
    {
        Enum.TryParse<ItemSlot>(Slot, true, out var itemSlot);
        Enum.TryParse<ItemRarity>(Rarity, true, out var itemRarity);

        return new Item
        {
            Id = Id,
            Name = Name,
            Slot = itemSlot,
            Rarity = itemRarity,
            Description = Description,
            StatBonuses = Stats
        };
    }
}

public record EnemyTemplate
{
    public string Id { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string Tier { get; init; } = string.Empty;
    public string Description { get; init; } = string.Empty;
    public Stats Stats { get; init; } = new();
    public int GoldReward { get; init; } = 10;
    public bool IsBoss { get; init; }

    public Enemy ToEnemy() => new(
        name: Name,
        stats: Stats,
        goldReward: GoldReward,
        isBoss: IsBoss,
        title: Tier,
        ability: Description
    );
}

public record MetaUpgradeTemplate
{
    public string Type { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string Description { get; init; } = string.Empty;
    public int BaseCost { get; init; }
    public string CostScaling { get; init; } = string.Empty;
    public string StatBonus { get; init; } = string.Empty;
}

public static class DataLoader
{
    private static readonly JsonSerializerOptions Options = new()
    {
        PropertyNameCaseInsensitive = true,
        Converters = { new JsonStringEnumConverter() }
    };

    public static List<ItemTemplate> LoadItemTemplates(string jsonPath)
    {
        if (!File.Exists(jsonPath)) return new();
        string json = File.ReadAllText(jsonPath);
        return JsonSerializer.Deserialize<List<ItemTemplate>>(json, Options) ?? new();
    }

    public static List<EnemyTemplate> LoadEnemyTemplates(string jsonPath)
    {
        if (!File.Exists(jsonPath)) return new();
        string json = File.ReadAllText(jsonPath);
        return JsonSerializer.Deserialize<List<EnemyTemplate>>(json, Options) ?? new();
    }

    public static List<MetaUpgradeTemplate> LoadMetaUpgradeTemplates(string jsonPath)
    {
        if (!File.Exists(jsonPath)) return new();
        string json = File.ReadAllText(jsonPath);
        return JsonSerializer.Deserialize<List<MetaUpgradeTemplate>>(json, Options) ?? new();
    }
}
