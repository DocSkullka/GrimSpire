namespace GrimSpire.Core.Models;

/// <summary>
/// Hostile creature residing in the Spire.
/// </summary>
public class Enemy
{
    public string Id { get; init; } = Guid.NewGuid().ToString("N");
    public string Name { get; init; } = "Hollow Husk";
    public string Title { get; init; } = string.Empty;
    public Stats Stats { get; init; } = new();
    public double CurrentHealth { get; set; }
    public bool IsBoss { get; init; } = false;
    public bool IsElite { get; init; } = false;
    public int GoldReward { get; init; } = 10;
    public string SpecialAbility { get; init; } = string.Empty;

    public Enemy()
    {
        Stats = new Stats
        {
            MaxHealth = 30,
            AttackDamage = 5,
            Armor = 0,
            AttackSpeed = 1.0,
            CritChance = 0.05,
            CritMultiplier = 1.5,
            DodgeChance = 0.05
        };
        CurrentHealth = Stats.MaxHealth;
    }

    public Enemy(string name, Stats stats, int goldReward = 10, bool isBoss = false, bool isElite = false, string title = "", string ability = "")
    {
        Name = name;
        Stats = stats with
        {
            MaxHealth = stats.MaxHealth > 0 ? stats.MaxHealth : 30,
            AttackDamage = stats.AttackDamage > 0 ? stats.AttackDamage : 5,
            AttackSpeed = stats.AttackSpeed > 0 ? stats.AttackSpeed : 1.0,
            CritMultiplier = stats.CritMultiplier > 0 ? stats.CritMultiplier : 1.5
        };
        CurrentHealth = Stats.MaxHealth;
        GoldReward = goldReward;
        IsBoss = isBoss;
        IsElite = isElite;
        Title = title;
        SpecialAbility = ability;
    }

    public Enemy Clone() => new(Name, Stats, GoldReward, IsBoss, IsElite, Title, SpecialAbility);
}
