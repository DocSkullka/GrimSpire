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

    [Fact]
    public void AttackSpeed_ZeroOrNegative_HandledSafelyWithoutInfiniteLoop()
    {
        var player = new Character(new Stats { MaxHealth = 100, AttackDamage = 10, AttackSpeed = -5.0 });
        var enemy = new Enemy("Slug", new Stats { MaxHealth = 20, AttackDamage = 1, AttackSpeed = 0.0 });

        var engine = new CombatEngine(seed: 42);
        var result = engine.SimulateBattle(player, new List<Enemy> { enemy });

        // Battle should resolve safely, clamped to at least 0.1 attack speed without hanging
        Assert.True(result.DurationSeconds > 0);
        Assert.True(result.PlayerWon || result.PlayerEndingHealth == 0);
    }

    [Fact]
    public void Combat_Timeout_TriggersDefeatBySpireMiasma()
    {
        // Two immortal tanks with 0 damage will reach 120s timeout
        var player = new Character(new Stats { MaxHealth = 1000, AttackDamage = 0, AttackSpeed = 1.0 });
        var enemy = new Enemy("Obsidian Wall", new Stats { MaxHealth = 1000, AttackDamage = 0, AttackSpeed = 1.0 });

        var engine = new CombatEngine(seed: 42);
        var result = engine.SimulateBattle(player, new List<Enemy> { enemy });

        Assert.False(result.PlayerWon);
        Assert.Equal(0, player.CurrentHealth);
        Assert.Contains(result.Events, e => e.Source.Contains("Miasma"));
    }

    [Fact]
    public void Combat_ExtremeMultiEnemy_Handles15EnemiesSimultaneously()
    {
        var player = new Character(new Stats { MaxHealth = 1500, AttackDamage = 80, AttackSpeed = 2.0, Armor = 30 });
        var swarm = Enumerable.Range(1, 15)
            .Select(i => new Enemy($"Swarm #{i}", new Stats { MaxHealth = 40, AttackDamage = 8, AttackSpeed = 0.8 }))
            .ToList();

        var engine = new CombatEngine(seed: 123);
        var result = engine.SimulateBattle(player, swarm);

        Assert.True(result.PlayerWon);
        Assert.True(result.TotalDamageDealt >= 40 * 15);
        Assert.All(swarm, enemy => Assert.Equal(0, enemy.CurrentHealth));
    }

    [Fact]
    public void Combat_DraftPending_ThrowsInvalidOperationExceptionOnSubsequentCombat()
    {
        var meta = new MetaProgression();
        var manager = new TowerRunManager(meta, seed: 100);
        manager.StartNewRun();

        var firstResult = manager.ExecuteCurrentFloorCombat();
        Assert.True(firstResult.PlayerWon);
        Assert.NotNull(manager.CurrentDraftOptions);

        // Attempting to fight again without picking draft must throw
        Assert.Throws<InvalidOperationException>(() => manager.ExecuteCurrentFloorCombat());
    }

    [Fact]
    public void Character_ResetForRun_ResetsHighestFloorReached()
    {
        var player = new Character();
        player.HighestFloorReached = 17;

        player.ResetForRun(Stats.DefaultHero);
        Assert.Equal(1, player.HighestFloorReached);
    }

    [Fact]
    public void ItemDraft_CursedItems_IncludeMeaningfulTradeoffs()
    {
        var draftService = new ItemDraftService(seed: 9999);
        // Force sample high floor drafts until cursed items appear
        List<Item> cursedItems = new();
        for (int f = 10; f <= 50; f++)
        {
            var draft = draftService.GenerateDraft(f);
            cursedItems.AddRange(draft.Where(i => i.Rarity == ItemRarity.Cursed));
            if (cursedItems.Count >= 3) break;
        }

        Assert.NotEmpty(cursedItems);
        // Ensure at least one cursed item exhibits a negative penalty stat
        Assert.Contains(cursedItems, i => 
            i.StatBonuses.Armor < 0 || 
            i.StatBonuses.MaxHealth < 0 || 
            i.StatBonuses.DodgeChance < 0);
    }
}
