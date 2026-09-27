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
        var allSlots = Enum.GetValues<ItemSlot>().OrderBy(_ => _rng.Next()).ToList();
        
        for (int i = 0; i < 3; i++)
        {
            // Pick diverse slots when possible
            var slot = i < allSlots.Count ? allSlots[i] : (ItemSlot)_rng.Next(allSlots.Count);
            var rarity = RollRarity(currentFloor);
            draft.Add(CreateRandomItem(slot, rarity, currentFloor));
        }
        return draft;
    }

    private ItemRarity RollRarity(int floor)
    {
        double commonWeight = Math.Max(5.0, 50.0 - (floor * 1.5));
        double uncommonWeight = Math.Max(10.0, 30.0 + (floor * 0.5));
        double rareWeight = Math.Max(10.0, 15.0 + (floor * 1.0));
        double epicWeight = Math.Min(30.0, 4.0 + (floor * 0.8));
        double legendaryWeight = Math.Min(15.0, 1.0 + (floor * 0.4));
        double cursedWeight = floor >= 5 ? 8.0 : 0.0;

        double totalWeight = commonWeight + uncommonWeight + rareWeight + epicWeight + legendaryWeight + cursedWeight;
        double roll = _rng.NextDouble() * totalWeight;

        if (roll < cursedWeight) return ItemRarity.Cursed;
        roll -= cursedWeight;
        if (roll < legendaryWeight) return ItemRarity.Legendary;
        roll -= legendaryWeight;
        if (roll < epicWeight) return ItemRarity.Epic;
        roll -= epicWeight;
        if (roll < rareWeight) return ItemRarity.Rare;
        roll -= rareWeight;
        if (roll < uncommonWeight) return ItemRarity.Uncommon;

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
        string[] prefixes = rarity == ItemRarity.Cursed
            ? new[] { "Blood-Drinking", "Soul-Severing", "Abyssal", "Doomed" }
            : new[] { "Rusty", "Honed", "Bleeding", "Serrated", "Gothic", "Eldritch" };
        string[] bases = { "Broadsword", "Cleaver", "War-Scythe", "Flanged Mace", "Spike Rapier" };

        string name = $"{prefixes[_rng.Next(prefixes.Length)]} {bases[_rng.Next(bases.Length)]}";
        bool isCursed = rarity == ItemRarity.Cursed;
        
        return new Item
        {
            Name = name,
            Slot = ItemSlot.Weapon,
            Rarity = rarity,
            Description = isCursed ? $"Immense lethality at the cost of vulnerability." : $"Inflicts deadly wounds. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                AttackDamage = Math.Round(8 * mult),
                AttackSpeed = Math.Round(0.1 * mult, 2),
                Armor = isCursed ? -Math.Round(3 * mult) : 0,
                CritChance = rarity >= ItemRarity.Rare ? 0.08 : 0.02,
                Lifesteal = isCursed ? 0.15 : (rarity >= ItemRarity.Epic ? 0.05 : 0.0)
            },
            SpecialEffect = isCursed ? "Curse: -Armor, +Massive DMG & Lifesteal" : (rarity >= ItemRarity.Epic ? "Sundering Strike: Hits reduce enemy defense" : "")
        };
    }

    private Item GenerateArmor(ItemRarity rarity, double mult)
    {
        string[] bases = rarity == ItemRarity.Cursed
            ? new[] { "Flayed Flesh Carapace", "Torture Rack Mail", "Shrine-Robber's Hauberk" }
            : new[] { "Plated Hauberk", "Bone Carapace", "Cuirass of Despair", "Ironmail Vest" };
        string name = $"{bases[_rng.Next(bases.Length)]}";
        bool isCursed = rarity == ItemRarity.Cursed;

        return new Item
        {
            Name = name,
            Slot = ItemSlot.Armor,
            Rarity = rarity,
            Description = isCursed ? "Immense bulk but encumbers your movement." : $"Protects against vicious blows. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                Armor = Math.Round(6 * mult),
                MaxHealth = Math.Round(35 * mult),
                DodgeChance = isCursed ? -0.05 : 0.0
            },
            SpecialEffect = isCursed ? "Curse: -5% Dodge, +Colossal Health" : (rarity >= ItemRarity.Epic ? "Retaliation: Thorns damage to attackers" : "")
        };
    }

    private Item GenerateHelmet(ItemRarity rarity, double mult)
    {
        string[] bases = rarity == ItemRarity.Cursed
            ? new[] { "Crown of Thorns", "Executioner's Blindfold", "Gilded Skull of Torment" }
            : new[] { "Iron Sallet", "Executioner's Hood", "Horned Bascinet", "Death Mask" };
        string name = $"{bases[_rng.Next(bases.Length)]}";
        bool isCursed = rarity == ItemRarity.Cursed;

        return new Item
        {
            Name = name,
            Slot = ItemSlot.Helmet,
            Rarity = rarity,
            Description = isCursed ? "Pierces the skull granting bloodlust." : $"Shields the mind and head. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                Armor = isCursed ? 0 : Math.Round(3 * mult),
                MaxHealth = isCursed ? -Math.Round(15 * mult) : Math.Round(20 * mult),
                AttackDamage = isCursed ? Math.Round(10 * mult) : 0,
                CritChance = isCursed ? 0.15 : (rarity >= ItemRarity.Rare ? 0.06 : 0.0)
            },
            SpecialEffect = isCursed ? "Curse: -Max HP, +Bonus ATK & Crit" : ""
        };
    }

    private Item GenerateOffHand(ItemRarity rarity, double mult)
    {
        string[] bases = { "Spiked Buckler", "Tome of Blood Rites", "Grim Aegis", "Skull Lantern" };
        string name = $"{bases[_rng.Next(bases.Length)]}";
        bool isCursed = rarity == ItemRarity.Cursed;

        return new Item
        {
            Name = name,
            Slot = ItemSlot.OffHand,
            Rarity = rarity,
            Description = isCursed ? "Unholy focus that drains your defenses." : $"Secondary equipment yielding balance in combat. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                Armor = isCursed ? -Math.Round(4 * mult) : Math.Round(4 * mult),
                DodgeChance = Math.Round(0.04 * mult, 2),
                AttackDamage = Math.Round((isCursed ? 8 : 3) * mult)
            },
            SpecialEffect = isCursed ? "Curse: -Armor, +Heavy Offhand DMG" : ""
        };
    }

    private Item GenerateAccessory(ItemRarity rarity, double mult)
    {
        string[] bases = { "Bloodstone Ring", "Amulet of the Tormented", "Signet of Greed", "Cursed Band" };
        string name = $"{bases[_rng.Next(bases.Length)]}";
        bool isCursed = rarity == ItemRarity.Cursed;

        return new Item
        {
            Name = name,
            Slot = ItemSlot.Accessory,
            Rarity = rarity,
            Description = isCursed ? "Leaches the wearer's vitality for dark power." : $"Mystic trinket channeling ancient tower energies. Tier scaling: {mult:F1}x",
            StatBonuses = new Stats
            {
                CritChance = Math.Round(0.05 * mult, 2),
                CritMultiplier = Math.Round(0.3 * mult, 2),
                Lifesteal = Math.Round((isCursed ? 0.12 : 0.04) * mult, 2),
                MaxHealth = isCursed ? -Math.Round(20 * mult) : 0
            },
            SpecialEffect = isCursed ? "Curse: -Max HP, +Greatly increased Lifesteal" : ""
        };
    }
}
