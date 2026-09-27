using GrimSpire.Core.Models;
using GrimSpire.Core.Progression;
using Xunit;

namespace GrimSpire.Tests;

public class PartyAndFusionTests
{
    [Fact]
    public void PartyMember_FactoryMethods_CreateCorrectRolesAndStats()
    {
        var hero = PartyMember.CreateHero();
        var tank = PartyMember.CreateTank();
        var thief = PartyMember.CreateThief();
        var cleric = PartyMember.CreateCleric();

        Assert.Equal(PartyRole.Hero, hero.Role);
        Assert.Equal(PartyRole.Tank, tank.Role);
        Assert.Equal(PartyRole.Thief, thief.Role);
        Assert.Equal(PartyRole.Cleric, cleric.Role);

        Assert.True(tank.BaseStats.Armor > hero.BaseStats.Armor, "Tank should have higher base armor");
        Assert.True(thief.BaseStats.CritChance > 0.30, "Thief should have high crit chance");
        Assert.True(thief.BaseStats.GoldMultiplier > 0.30, "Thief should have gold find bonus");
        Assert.True(cleric.BaseStats.Lifesteal > 0.10, "Cleric should have occult lifesteal");
    }

    [Fact]
    public void Tank_Taunt_MitigatesDamageSignificantly()
    {
        var tankNormal = PartyMember.CreateTank();
        var tankTaunting = PartyMember.CreateTank();
        tankTaunting.TauntDurationRemaining = 4.0;

        double dmgNormal = tankNormal.TakeDamage(100.0);
        double dmgTaunting = tankTaunting.TakeDamage(100.0);

        Assert.True(dmgTaunting < dmgNormal * 0.6, "Taunt stance with shield block should mitigate at least 40% of damage");
    }

    [Fact]
    public void Cleric_Heal_CapsAtMaxHealth()
    {
        var hero = PartyMember.CreateHero();
        hero.CurrentHealth = 50.0;
        hero.Heal(200.0);

        Assert.Equal(hero.BaseStats.MaxHealth, hero.CurrentHealth);
    }

    [Fact]
    public void ItemFusion_Tier1PlusTier1_ProducesTier2WithMultipliedStats()
    {
        var sword1 = new Item
        {
            Name = "Rusty Cleaver",
            Slot = ItemSlot.Weapon,
            StatBonuses = new Stats { AttackDamage = 20, CritChance = 0.10 }
        };

        var sword2 = new Item
        {
            Name = "Rusty Cleaver",
            Slot = ItemSlot.Weapon,
            StatBonuses = new Stats { AttackDamage = 20, CritChance = 0.10 }
        };

        var result = ItemFusionService.FuseItems(sword1, sword2);
        Assert.True(result.Success);
        Assert.NotNull(result.UpgradedItem);
        Assert.Contains("[Tier II]", result.UpgradedItem.Name);
        Assert.True(result.UpgradedItem.StatBonuses.AttackDamage > 25, "Tier II attack damage should be boosted by ~1.6x");
    }

    [Fact]
    public void ItemFusion_Tier2PlusTier1_ProducesTier3()
    {
        var tier2Sword = new Item
        {
            Name = "Rusty Cleaver [Tier II]",
            Slot = ItemSlot.Weapon,
            StatBonuses = new Stats { AttackDamage = 32, CritChance = 0.12 }
        };

        var baseSword = new Item
        {
            Name = "Rusty Cleaver",
            Slot = ItemSlot.Weapon,
            StatBonuses = new Stats { AttackDamage = 20, CritChance = 0.10 }
        };

        var result = ItemFusionService.FuseItems(tier2Sword, baseSword);
        Assert.True(result.Success);
        Assert.Contains("[Tier III]", result.UpgradedItem!.Name);
    }

    [Fact]
    public void ItemFusion_DifferentSlots_FailsGracefully()
    {
        var weapon = new Item { Name = "Blade", Slot = ItemSlot.Weapon };
        var shield = new Item { Name = "Buckler", Slot = ItemSlot.OffHand };

        var result = ItemFusionService.FuseItems(weapon, shield);
        Assert.False(result.Success);
    }

    [Fact]
    public void SmartDraft_ExcludesDirectEquippedDuplicates()
    {
        var equippedWeapon = new Item { Id = "eq_1", Name = "Dusk Dagger", Slot = ItemSlot.Weapon };
        var catalog = new List<Item>
        {
            new() { Id = "cat_1", Name = "Dusk Dagger", Slot = ItemSlot.Weapon },
            new() { Id = "cat_2", Name = "Headsman's Crescent", Slot = ItemSlot.Weapon },
            new() { Id = "cat_3", Name = "Black Guard Cuirass", Slot = ItemSlot.Armor },
            new() { Id = "cat_4", Name = "Spire Sentry Helm", Slot = ItemSlot.Helmet },
            new() { Id = "cat_5", Name = "Spiked Wall of the Bulwark", Slot = ItemSlot.OffHand }
        };

        var draft = ItemFusionService.GenerateSmartDraft(new[] { equippedWeapon }, catalog, 3);
        Assert.Equal(3, draft.Count);
        Assert.DoesNotContain(draft, item => item.Name == "Dusk Dagger");
    }
}
