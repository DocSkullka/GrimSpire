namespace GrimSpire.Core.Models;

/// <summary>
/// The player character who ascends the Spire.
/// </summary>
public class Character
{
    public string Name { get; set; } = "Cursed Wanderer";
    public Stats BaseStats { get; set; } = Stats.DefaultHero;
    public double CurrentHealth { get; set; }
    public int GoldInRun { get; set; } = 0;
    public int HighestFloorReached { get; set; } = 1;

    public Dictionary<ItemSlot, Item> EquippedItems { get; } = new();

    public Character(Stats? initialStats = null)
    {
        BaseStats = initialStats ?? Stats.DefaultHero;
        CurrentHealth = BaseStats.MaxHealth;
    }

    /// <summary>
    /// Computes total stats combining base attributes and all equipped gear.
    /// </summary>
    public Stats GetEffectiveStats()
    {
        var total = BaseStats;
        foreach (var item in EquippedItems.Values)
        {
            total += item.StatBonuses;
        }
        return total;
    }

    public Item? Equip(Item item)
    {
        EquippedItems.TryGetValue(item.Slot, out var previous);
        EquippedItems[item.Slot] = item;
        
        var effective = GetEffectiveStats();
        double hpGain = item.StatBonuses.MaxHealth - (previous?.StatBonuses.MaxHealth ?? 0);
        if (hpGain > 0)
        {
            CurrentHealth += hpGain;
        }

        if (CurrentHealth > effective.MaxHealth)
        {
            CurrentHealth = effective.MaxHealth;
        }

        return previous;
    }

    public Item? Unequip(ItemSlot slot)
    {
        if (EquippedItems.Remove(slot, out var item))
        {
            var maxHp = GetEffectiveStats().MaxHealth;
            if (CurrentHealth > maxHp)
            {
                CurrentHealth = maxHp;
            }
            return item;
        }
        return null;
    }

    public void Heal(double amount)
    {
        var maxHp = GetEffectiveStats().MaxHealth;
        CurrentHealth = Math.Clamp(CurrentHealth + amount, 0, maxHp);
    }

    public void ResetForRun(Stats newBaseStats)
    {
        BaseStats = newBaseStats;
        EquippedItems.Clear();
        CurrentHealth = BaseStats.MaxHealth;
        GoldInRun = 0;
        HighestFloorReached = 1;
    }
}
