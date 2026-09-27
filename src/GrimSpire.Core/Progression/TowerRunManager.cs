using GrimSpire.Core.Combat;
using GrimSpire.Core.Models;

namespace GrimSpire.Core.Progression;

public class TowerRunManager
{
    public Character Player { get; }
    public MetaProgression Meta { get; }
    public FloorGenerator FloorGen { get; }
    public CombatEngine Combat { get; }
    public ItemDraftService ItemDraft { get; }

    public int CurrentFloorNumber { get; private set; } = 1;
    public Floor? CurrentFloor { get; private set; }
    public List<Item>? CurrentDraftOptions { get; private set; }
    public bool IsRunActive { get; private set; } = false;

    public TowerRunManager(MetaProgression? meta = null, int? seed = null)
    {
        Meta = meta ?? new MetaProgression();
        Player = new Character(Meta.CalculateStartingStats());
        FloorGen = new FloorGenerator(seed);
        Combat = new CombatEngine(seed);
        ItemDraft = new ItemDraftService(seed);
    }

    public void StartNewRun()
    {
        CurrentFloorNumber = 1;
        var startingStats = Meta.CalculateStartingStats();
        Player.ResetForRun(startingStats);
        IsRunActive = true;
        CurrentFloor = FloorGen.GenerateFloor(CurrentFloorNumber);
        CurrentDraftOptions = null;
    }

    public CombatResult ExecuteCurrentFloorCombat()
    {
        if (!IsRunActive || CurrentFloor == null)
        {
            throw new InvalidOperationException("Run is not active or floor not generated.");
        }

        var result = Combat.SimulateBattle(Player, CurrentFloor.Enemies);

        if (result.PlayerWon)
        {
            // Floor cleared!
            int earnedGold = (int)Math.Round(CurrentFloor.GoldReward * Meta.GetGoldMultiplier());
            Player.GoldInRun += earnedGold;
            Player.HighestFloorReached = CurrentFloorNumber;

            // Generate 3 draft choices for the player
            CurrentDraftOptions = ItemDraft.GenerateDraft(CurrentFloorNumber);
        }
        else
        {
            // Player defeated -> End run, bank gold to meta
            IsRunActive = false;
            Meta.OnRunCompleted(Player.GoldInRun, CurrentFloorNumber);
        }

        return result;
    }

    public Item SelectDraftItem(int index)
    {
        if (CurrentDraftOptions == null || index < 0 || index >= CurrentDraftOptions.Count)
        {
            throw new ArgumentOutOfRangeException(nameof(index), "Invalid draft choice index.");
        }

        var selected = CurrentDraftOptions[index];
        Player.Equip(selected);

        // Advance to next floor
        CurrentDraftOptions = null;
        CurrentFloorNumber++;
        CurrentFloor = FloorGen.GenerateFloor(CurrentFloorNumber);

        // Moderate heal between floors (25% max HP)
        var maxHp = Player.GetEffectiveStats().MaxHealth;
        Player.Heal(maxHp * 0.25);

        return selected;
    }
}
