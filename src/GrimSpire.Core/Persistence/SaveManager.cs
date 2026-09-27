using System.Text.Json;
using System.Text.Json.Serialization;
using GrimSpire.Core.Progression;

namespace GrimSpire.Core.Persistence;

public record SaveData
{
    public int PersistentGold { get; init; }
    public int HighestFloorReached { get; init; }
    public int TotalRunsPlayed { get; init; }
    public Dictionary<string, int> UpgradeRanks { get; init; } = new();
    public DateTime LastSavedUtc { get; init; } = DateTime.UtcNow;
}

/// <summary>
/// Handles persistent storage of meta-progression, gold, and upgrades to local JSON file.
/// </summary>
public static class SaveManager
{
    public static readonly string DefaultSavePath = Path.Combine(
        AppDomain.CurrentDomain.BaseDirectory,
        "grimspire_save.json"
    );

    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        Converters = { new JsonStringEnumConverter() }
    };

    public static void Save(MetaProgression meta, string? filePath = null)
    {
        string path = filePath ?? DefaultSavePath;
        var dir = Path.GetDirectoryName(path);
        if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        var saveData = new SaveData
        {
            PersistentGold = meta.PersistentGold,
            HighestFloorReached = meta.HighestFloorReached,
            TotalRunsPlayed = meta.TotalRunsPlayed,
            UpgradeRanks = meta.UpgradeRanks.ToDictionary(k => k.Key.ToString(), v => v.Value),
            LastSavedUtc = DateTime.UtcNow
        };

        string json = JsonSerializer.Serialize(saveData, JsonOptions);
        File.WriteAllText(path, json);
    }

    public static MetaProgression Load(string? filePath = null)
    {
        string path = filePath ?? DefaultSavePath;
        if (!File.Exists(path))
        {
            return new MetaProgression();
        }

        try
        {
            string json = File.ReadAllText(path);
            var saveData = JsonSerializer.Deserialize<SaveData>(json, JsonOptions);
            if (saveData == null)
            {
                return new MetaProgression();
            }

            var meta = new MetaProgression
            {
                PersistentGold = saveData.PersistentGold,
                HighestFloorReached = Math.Max(1, saveData.HighestFloorReached),
                TotalRunsPlayed = saveData.TotalRunsPlayed
            };

            foreach (var kvp in saveData.UpgradeRanks)
            {
                if (Enum.TryParse<MetaUpgradeType>(kvp.Key, out var type))
                {
                    meta.UpgradeRanks[type] = kvp.Value;
                }
            }

            return meta;
        }
        catch
        {
            return new MetaProgression();
        }
    }
}
