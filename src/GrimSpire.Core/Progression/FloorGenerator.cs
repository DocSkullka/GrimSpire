using GrimSpire.Core.Models;

namespace GrimSpire.Core.Progression;

public enum FloorType
{
    Normal,
    Elite,
    Boss
}

public record Floor
{
    public int FloorNumber { get; init; }
    public FloorType Type { get; init; }
    public string Name { get; init; } = string.Empty;
    public List<Enemy> Enemies { get; init; } = new();
    public int GoldReward { get; init; }
}

public class FloorGenerator
{
    private readonly Random _rng;

    public FloorGenerator(int? seed = null)
    {
        _rng = seed.HasValue ? new Random(seed.Value) : new Random();
    }

    public Floor GenerateFloor(int floorNumber)
    {
        bool isBoss = floorNumber % 10 == 0;
        bool isElite = !isBoss && floorNumber > 3 && _rng.NextDouble() < 0.25;

        FloorType type = isBoss ? FloorType.Boss : (isElite ? FloorType.Elite : FloorType.Normal);
        string name = isBoss 
            ? $"Floor {floorNumber}: Chamber of the Spire Lord" 
            : (isElite ? $"Floor {floorNumber}: Corrupted Threshold" : $"Floor {floorNumber}: The Ascending Gauntlet");

        var enemies = new List<Enemy>();

        if (floorNumber == 1)
        {
            // First floor: easy introductory encounter as requested by design
            enemies.Add(new Enemy(
                name: "Feeble Skeleton",
                stats: new Stats
                {
                    MaxHealth = 30,
                    AttackDamage = 4,
                    Armor = 0,
                    AttackSpeed = 0.8,
                    CritChance = 0.0,
                    DodgeChance = 0.0
                },
                goldReward: 15,
                title: "Wretched Dust"
            ));
        }
        else if (isBoss)
        {
            enemies.Add(GenerateBoss(floorNumber));
        }
        else
        {
            // Standard or Elite Floor: 1 to 3 enemies
            int enemyCount = 1;
            if (floorNumber >= 3 && _rng.NextDouble() < 0.4) enemyCount = 2;
            if (floorNumber >= 7 && _rng.NextDouble() < 0.3) enemyCount = 3;

            for (int i = 0; i < enemyCount; i++)
            {
                enemies.Add(GenerateRegularEnemy(floorNumber, isElite, i + 1, enemyCount));
            }
        }

        int totalGold = enemies.Sum(e => e.GoldReward) + (floorNumber * 3);

        return new Floor
        {
            FloorNumber = floorNumber,
            Type = type,
            Name = name,
            Enemies = enemies,
            GoldReward = totalGold
        };
    }

    private Enemy GenerateRegularEnemy(int floorNumber, bool isElite, int index, int totalEnemies)
    {
        double scalingFactor = 1.0 + (floorNumber * 0.12);
        if (isElite) scalingFactor *= 1.45;

        string[] mobTemplates =
        {
            "Cursed Cultist",
            "Armored Ghoul",
            "Spire Imp",
            "Shadow Hound",
            "Hollow Knight",
            "Dread Wraith"
        };

        string baseName = mobTemplates[_rng.Next(mobTemplates.Length)];
        string suffix = totalEnemies > 1 ? $" #{index}" : "";
        string displayName = isElite ? $"[Elite] {baseName}{suffix}" : $"{baseName}{suffix}";

        return new Enemy(
            name: displayName,
            stats: new Stats
            {
                MaxHealth = Math.Round(35 * scalingFactor),
                AttackDamage = Math.Round(7 * scalingFactor),
                Armor = Math.Round(3 * (floorNumber * 0.15)),
                AttackSpeed = Math.Round(0.85 + (_rng.NextDouble() * 0.3), 2),
                CritChance = isElite ? 0.12 : 0.05,
                CritMultiplier = 1.5,
                DodgeChance = isElite ? 0.08 : 0.03
            },
            goldReward: (int)Math.Round((10 + floorNumber * 2) * (isElite ? 2.0 : 1.0)),
            isBoss: false,
            isElite: isElite
        );
    }

    private Enemy GenerateBoss(int floorNumber)
    {
        int bossTier = floorNumber / 10;
        double bossScaling = 1.0 + (bossTier * 1.5);

        string[] bossNames =
        {
            "Gargoyle Overseer Malgorath",
            "The Flesh Amalgam of Sorrow",
            "Valthor the Soul Extinguisher",
            "Ancient Obsidian Goliath",
            "Arch-Abomination of the Spire Peak"
        };

        string bossName = bossNames[Math.Min(bossTier - 1, bossNames.Length - 1)];

        return new Enemy(
            name: bossName,
            stats: new Stats
            {
                MaxHealth = Math.Round(220 * bossScaling),
                AttackDamage = Math.Round(18 * bossScaling),
                Armor = Math.Round(20 * bossScaling),
                AttackSpeed = 1.1,
                CritChance = 0.15,
                CritMultiplier = 1.75,
                Lifesteal = 0.10,
                DodgeChance = 0.05
            },
            goldReward: 150 * bossTier,
            isBoss: true,
            isElite: false,
            title: "Spire Overlord",
            ability: "Ground Slam & Soul Leech"
        );
    }
}
