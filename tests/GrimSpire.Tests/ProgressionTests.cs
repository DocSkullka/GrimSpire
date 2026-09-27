using GrimSpire.Core.Models;
using GrimSpire.Core.Progression;
using Xunit;

namespace GrimSpire.Tests;

public class ProgressionTests
{
    [Fact]
    public void FloorGenerator_Floor1_IsIntroductoryFloor()
    {
        var gen = new FloorGenerator(seed: 123);
        var floor1 = gen.GenerateFloor(1);

        Assert.Equal(1, floor1.FloorNumber);
        Assert.Equal(FloorType.Normal, floor1.Type);
        Assert.Single(floor1.Enemies);
        Assert.True(floor1.Enemies[0].Stats.MaxHealth <= 35);
        Assert.False(floor1.Enemies[0].IsBoss);
    }

    [Theory]
    [InlineData(10)]
    [InlineData(20)]
    [InlineData(30)]
    public void FloorGenerator_Every10thFloor_IsBossFloor(int floorNumber)
    {
        var gen = new FloorGenerator(seed: 999);
        var floor = gen.GenerateFloor(floorNumber);

        Assert.Equal(FloorType.Boss, floor.Type);
        Assert.Single(floor.Enemies);
        Assert.True(floor.Enemies[0].IsBoss);
        Assert.True(floor.GoldReward >= 150);
    }

    [Fact]
    public void ItemDraft_GeneratesExactlyThreeChoices()
    {
        var draftService = new ItemDraftService(seed: 456);
        var draft = draftService.GenerateDraft(currentFloor: 5);

        Assert.Equal(3, draft.Count);
        Assert.All(draft, item => Assert.False(string.IsNullOrEmpty(item.Name)));
    }

    [Fact]
    public void Character_EquipItem_UpdatesEffectiveStats()
    {
        var player = new Character(Stats.DefaultHero with { MaxHealth = 100, AttackDamage = 10 });
        var weapon = new Item
        {
            Name = "Blood Cleaver",
            Slot = ItemSlot.Weapon,
            StatBonuses = new Stats { AttackDamage = 25, CritChance = 0.10 }
        };

        player.Equip(weapon);
        var effective = player.GetEffectiveStats();

        Assert.Equal(35, effective.AttackDamage);
        Assert.Equal(0.15, effective.CritChance, 3); // 0.05 base + 0.10 item
        // Verify that equipping weapon does NOT leak unintended HP, Armor, or AttackSpeed
        Assert.Equal(100, effective.MaxHealth);
        Assert.Equal(5, effective.Armor);
        Assert.Equal(1.0, effective.AttackSpeed);
        Assert.Equal(0.05, effective.DodgeChance);
    }

    [Fact]
    public void Character_EquipReplacingItem_OverridesPreviousStats()
    {
        var player = new Character(new Stats { AttackDamage = 10 });
        var weapon1 = new Item
        {
            Name = "Sword 1",
            Slot = ItemSlot.Weapon,
            StatBonuses = new Stats { AttackDamage = 10 }
        };
        var weapon2 = new Item
        {
            Name = "Sword 2",
            Slot = ItemSlot.Weapon,
            StatBonuses = new Stats { AttackDamage = 30 }
        };

        player.Equip(weapon1);
        Assert.Equal(20, player.GetEffectiveStats().AttackDamage);

        var prev = player.Equip(weapon2);
        Assert.Equal("Sword 1", prev?.Name);
        Assert.Equal(40, player.GetEffectiveStats().AttackDamage);
    }

    [Fact]
    public void MetaProgression_RetainsGoldAndClearsEquipmentOnDeath()
    {
        var meta = new MetaProgression();
        var manager = new TowerRunManager(meta, seed: 777);
        manager.StartNewRun();

        // Equip an item
        manager.Player.Equip(new Item
        {
            Name = "Run Relic",
            Slot = ItemSlot.Accessory,
            StatBonuses = new Stats { AttackDamage = 50 }
        });
        manager.Player.GoldInRun = 120;

        // Force run end by defeat
        meta.OnRunCompleted(manager.Player.GoldInRun, manager.CurrentFloorNumber);

        Assert.Equal(120, meta.PersistentGold);

        // Buy permanent Damage upgrade
        int cost = meta.GetUpgradeCost(MetaUpgradeType.Damage);
        bool purchased = meta.PurchaseUpgrade(MetaUpgradeType.Damage);

        Assert.True(purchased);
        Assert.Equal(120 - cost, meta.PersistentGold);
        Assert.Equal(1, meta.UpgradeRanks[MetaUpgradeType.Damage]);

        // Start new run: equipment is wiped, but base stats have improved permanently!
        manager.StartNewRun();
        Assert.Empty(manager.Player.EquippedItems);
        Assert.Equal(17.5, manager.Player.BaseStats.AttackDamage); // 15 base + 2.5 rank
    }
}
