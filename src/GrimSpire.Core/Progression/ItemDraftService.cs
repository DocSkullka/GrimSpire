using GrimSpire.Core.Models;

namespace GrimSpire.Core.Progression;

/// <summary>
/// Generates 3 random items for drafting after clearing each tower floor.
/// </summary>
public class ItemDraftService
{
    private readonly Random _rng;

    public ItemDraftService(int? seed = null)
    {
        _rng = seed.HasValue ? new Random(seed.Value) : new Random();
    }

    public List<Item> GenerateDraft(int currentFloor)
    {
        var draft = new List<Item>();
        for (int i = 0; i < 3; i++)
        {
            var slot = (ItemSlot)_rng.Next(Enum.GetValues<ItemSlot>().Length);
            var rarity = RollRarity(currentFloor);
            draft.Add(CreateRandomItem(slot, rarity, currentFloor));
        }
        return draft;
    }

    private ItemRarity RollRarity(int floor)
    {
        double roll = _rng.NextDouble();
        // Floor scaling shifts probabilities towards higher tiers
        double legendaryChance = Math.Min(0.08, 0.01 + (floor * 0.005));
        double epicChance = Math.Min(0.20, 0.04 + (floor * 0.012));
        double rareChance = Math.Min(0.35, 0.15 + (floor * 0.02));
        double uncommonChance = Math.Min(0.40, 0.35 + (floor * 0.01));

        if (roll < legendaryChance) return ItemRarity.Legendary;
        roll -= legendaryChance;
        if (roll < epicChance) return ItemRarity.Epic;
        roll -= epicChance;
        if (roll < rareChance) return ItemRarity.Rare;
        roll -= rareChance;
        if (roll < uncommonChance) return ItemRarity.Uncommon;

        // Small chance of cursed item on floors 5+
        if (floor >= 5 && _rng.NextDouble() < 0.06)
        {
            return ItemRarity.Cursed;
        }

        return ItemRarity.Common;
    }

    private Item CreateRandomItem(ItemSlot slot, ItemRarity rarity, int floor)
    {
        double statMultiplier = rarity switch
        {
            ItemRarity.Common => 1.0,
            ItemRarity.Uncommon => 1.4,
            ItemRarity.Rare => 1.9,
            ItemRarity.Epic => 2.6,
            ItemRarity.Legendary => 3.5,
            ItemRarity.Cursed => 4.2,
            _ => 1.0
        };

        double floorBonus = 1.0 + (floor * 0.08);
        double finalMultiplier = statMultiplier * floorBonus;

        return slot switch
        {
            ItemSlot.Weapon => GenerateWeapon(rarity, finalMultiplier),
            ItemSlot.Armor => GenerateArmor(rarity, finalMultiplier),
            ItemSlot.Helmet => GenerateHelmet(rarity, finalMultiplier),
            ItemSlot.OffHand => GenerateOffHand(rarity, finalMultiplier),
            ItemSlot.Accessory => GenerateAccessory(rarity, finalMultiplier),
            _ => GenerateWeapon(rarity, finalMultiplier)
        };
    }

    private Item GenerateWeapon(ItemRarity rarity, double mult)
    {
        string[] prefixes = { "Rusty", "Honed", "Bleeding", "Serrated", "Gothic", "Eldritch" };
        string[] bases = { "Broadsword", "Cleaver", "War-Scythe", "Flanged Mace", "Spike Rapier" };

        string name = $"{prefixes[_rng.Next(prefixes.Length)]} {bases[_rng.Next(bases.Length)]}";
        
        return new Item
        {
            Name = name,
            Slot = ItemSlot.Weapon,
            Rarity = rarity,
            Description = $"Inflicts deadly wounds. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                AttackDamage = Math.Round(8 * mult),
                AttackSpeed = Math.Round(0.1 * mult, 2),
                CritChance = rarity >= ItemRarity.Rare ? 0.08 : 0.02,
                Lifesteal = rarity == ItemRarity.Cursed ? 0.15 : (rarity >= ItemRarity.Epic ? 0.05 : 0.0)
            },
            SpecialEffect = rarity >= ItemRarity.Epic ? "Sundering Strike: Hits reduce enemy defense" : ""
        };
    }

    private Item GenerateArmor(ItemRarity rarity, double mult)
    {
        string[] bases = { "Plated Hauberk", "Bone Carapace", "Cuirass of Despair", "Ironmail Vest" };
        string name = $"{bases[_rng.Next(bases.Length)]}";

        return new Item
        {
            Name = name,
            Slot = ItemSlot.Armor,
            Rarity = rarity,
            Description = $"Protects against vicious blows. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                Armor = Math.Round(6 * mult),
                MaxHealth = Math.Round(35 * mult)
            },
            SpecialEffect = rarity >= ItemRarity.Epic ? "Retaliation: Thorns damage to attackers" : ""
        };
    }

    private Item GenerateHelmet(ItemRarity rarity, double mult)
    {
        string[] bases = { "Iron Sallet", "Executioner's Hood", "Horned Bascinet", "Death Mask" };
        string name = $"{bases[_rng.Next(bases.Length)]}";

        return new Item
        {
            Name = name,
            Slot = ItemSlot.Helmet,
            Rarity = rarity,
            Description = $"Shields the mind and head. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                Armor = Math.Round(3 * mult),
                MaxHealth = Math.Round(20 * mult),
                CritChance = rarity >= ItemRarity.Rare ? 0.06 : 0.0
            }
        };
    }

    private Item GenerateOffHand(ItemRarity rarity, double mult)
    {
        string[] bases = { "Spiked Buckler", "Tome of Blood Rites", "Grim Aegis", "Skull Lantern" };
        string name = $"{bases[_rng.Next(bases.Length)]}";

        return new Item
        {
            Name = name,
            Slot = ItemSlot.OffHand,
            Rarity = rarity,
            Description = $"Secondary equipment yielding balance in combat. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                Armor = Math.Round(4 * mult),
                DodgeChance = Math.Round(0.04 * mult, 2),
                AttackDamage = Math.Round(3 * mult)
            }
        };
    }

    private Item GenerateAccessory(ItemRarity rarity, double mult)
    {
        string[] bases = { "Bloodstone Ring", "Amulet of the Tormented", "Signet of Greed", "Cursed Band" };
        string name = $"{bases[_rng.Next(bases.Length)]}";

        return new Item
        {
            Name = name,
            Slot = ItemSlot.Accessory,
            Rarity = rarity,
            Description = $"Mystic trinket channeling ancient tower energies. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                CritChance = Math.Round(0.05 * mult, 2),
                CritMultiplier = Math.Round(0.3 * mult, 2),
                Lifesteal = Math.Round(0.04 * mult, 2)
            }
        };
    }
}
