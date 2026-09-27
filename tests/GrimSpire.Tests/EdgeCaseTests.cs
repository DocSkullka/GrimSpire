using GrimSpire.Core.Combat;
using GrimSpire.Core.Models;
using GrimSpire.Core.Progression;
using Xunit;

namespace GrimSpire.Tests;

public class EdgeCaseTests
{
    [Fact]
    public void DodgeChance_CannotExceedCapOf75Percent()
    {
        var stats1 = new Stats { DodgeChance = 0.50 };
        var stats2 = new Stats { DodgeChance = 0.40 };
        var combined = stats1 + stats2;

        Assert.Equal(0.75, combined.DodgeChance);
    }

    [Fact]
    public void ArmorMitigation_HugeArmor_DoesNotDropToZeroOrDivideByZero()
    {
        double multiplier = Stats.CalculateDamageMitigationMultiplier(10000);
        Assert.True(multiplier > 0.0);
        Assert.True(multiplier < 0.01);
    }

    [Fact]
    public void ItemDraft_InvalidIndex_ThrowsArgumentOutOfRangeException()
    {
        var meta = new MetaProgression();
        var manager = new TowerRunManager(meta, seed: 100);
        manager.StartNewRun();

        // Floor 1 combat
        var result = manager.ExecuteCurrentFloorCombat();
        Assert.True(result.PlayerWon);

        // Selecting out-of-range index should throw
        Assert.Throws<ArgumentOutOfRangeException>(() => manager.SelectDraftItem(99));
        Assert.Throws<ArgumentOutOfRangeException>(() => manager.SelectDraftItem(-1));
    }

    [Fact]
    public void Character_Heal_DoesNotExceedMaxHealth()
    {
        var player = new Character(new Stats { MaxHealth = 100 });
        player.CurrentHealth = 90;
        player.Heal(50);

        Assert.Equal(100, player.CurrentHealth);
    }

    [Fact]
    public void Floor10Boss_IsProperlyGeneratedWithHighStats()
    {
        var gen = new FloorGenerator(seed: 555);
        var floor10 = gen.GenerateFloor(10);

        Assert.Equal(FloorType.Boss, floor10.Type);
        var boss = floor10.Enemies.Single();
        Assert.True(boss.IsBoss);
        Assert.True(boss.Stats.MaxHealth >= 300);
        Assert.True(boss.Stats.Armor >= 20);
        Assert.True(boss.Stats.CritChance > 0);
        Assert.True(boss.GoldReward >= 150);
    }

    [Fact]
    public void RunSimulation_PlaysAutomaticallyUntilVictoryOrDefeat()
    {
        var meta = new MetaProgression();
        var manager = new TowerRunManager(meta, seed: 12345);
        manager.StartNewRun();

        int floorsCleared = 0;
        while (manager.IsRunActive && floorsCleared < 20)
        {
            var res = manager.ExecuteCurrentFloorCombat();
            if (res.PlayerWon)
            {
                floorsCleared++;
                manager.SelectDraftItem(0); // Pick 1st item
            }
        }

        Assert.True(floorsCleared >= 1);
        Assert.True(meta.PersistentGold >= 0);
    }
}
