using GrimSpire.Core.Data;
using GrimSpire.Core.Models;
using GrimSpire.Core.Persistence;
using GrimSpire.Core.Progression;
using Xunit;

namespace GrimSpire.Tests;

public class PersistenceAndDataTests
{
    [Fact]
    public void SaveManager_SaveAndLoad_AccuratelyPreservesProgress()
    {
        string tempPath = Path.Combine(Path.GetTempPath(), $"grimspire_test_save_{Guid.NewGuid():N}.json");

        try
        {
            var meta = new MetaProgression
            {
                PersistentGold = 450,
                HighestFloorReached = 14,
                TotalRunsPlayed = 6
            };
            meta.UpgradeRanks[MetaUpgradeType.Damage] = 3;
            meta.UpgradeRanks[MetaUpgradeType.Health] = 2;
            meta.UpgradeRanks[MetaUpgradeType.GoldMultiplier] = 1;

            SaveManager.Save(meta, tempPath);
            Assert.True(File.Exists(tempPath));

            var loaded = SaveManager.Load(tempPath);
            Assert.Equal(450, loaded.PersistentGold);
            Assert.Equal(14, loaded.HighestFloorReached);
            Assert.Equal(6, loaded.TotalRunsPlayed);
            Assert.Equal(3, loaded.UpgradeRanks[MetaUpgradeType.Damage]);
            Assert.Equal(2, loaded.UpgradeRanks[MetaUpgradeType.Health]);
            Assert.Equal(1, loaded.UpgradeRanks[MetaUpgradeType.GoldMultiplier]);
        }
        finally
        {
            if (File.Exists(tempPath))
            {
                File.Delete(tempPath);
            }
        }
    }

    [Fact]
    public void SaveManager_MissingFile_ReturnsDefaultMetaProgression()
    {
        string nonExistentPath = Path.Combine(Path.GetTempPath(), $"non_existent_{Guid.NewGuid():N}.json");
        var meta = SaveManager.Load(nonExistentPath);

        Assert.NotNull(meta);
        Assert.Equal(0, meta.PersistentGold);
        Assert.Equal(1, meta.HighestFloorReached);
        Assert.Equal(0, meta.TotalRunsPlayed);
    }

    [Fact]
    public void DataLoader_LoadsItemTemplates_FromDataFile()
    {
        string itemsPath = Path.GetFullPath(@"D:\GrimSpire\data\items.json");
        Assert.True(File.Exists(itemsPath));

        var items = DataLoader.LoadItemTemplates(itemsPath);
        Assert.NotEmpty(items);
        Assert.True(items.Count >= 5);

        var first = items[0].ToItem();
        Assert.False(string.IsNullOrEmpty(first.Name));
        Assert.True(first.StatBonuses.AttackDamage > 0);
        // Verify bonus items do not pollute with base hero health
        Assert.Equal(0, first.StatBonuses.MaxHealth);
    }

    [Fact]
    public void DataLoader_LoadsEnemyTemplates_FromDataFile()
    {
        string enemiesPath = Path.GetFullPath(@"D:\GrimSpire\data\enemies.json");
        Assert.True(File.Exists(enemiesPath));

        var enemies = DataLoader.LoadEnemyTemplates(enemiesPath);
        Assert.NotEmpty(enemies);
        Assert.Contains(enemies, e => e.IsBoss);

        var boss = enemies.First(e => e.IsBoss).ToEnemy();
        Assert.True(boss.IsBoss);
        Assert.True(boss.Stats.MaxHealth >= 300);
    }

    [Fact]
    public void DataLoader_LoadsMetaUpgradeTemplates_FromDataFile()
    {
        string upgradesPath = Path.GetFullPath(@"D:\GrimSpire\data\meta_upgrades.json");
        Assert.True(File.Exists(upgradesPath));

        var upgrades = DataLoader.LoadMetaUpgradeTemplates(upgradesPath);
        Assert.NotEmpty(upgrades);
        Assert.Contains(upgrades, u => u.Type == "Health");
    }
}
