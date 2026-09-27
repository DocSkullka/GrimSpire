using GrimSpire.Core.Combat;
using GrimSpire.Core.Models;
using GrimSpire.Core.Persistence;
using GrimSpire.Core.Progression;

namespace GrimSpire.Cli;

public static class Program
{
    private static MetaProgression Meta = SaveManager.Load();

    public static void Main(string[] args)
    {
        Console.OutputEncoding = System.Text.Encoding.UTF8;
        PrintBanner();

        if (args.Contains("--simulate") || args.Contains("-s"))
        {
            RunBalanceSimulation();
            return;
        }

        bool exit = false;
        while (!exit)
        {
            Console.WriteLine("\n==============================================");
            Console.WriteLine("                THE BASE CAMP                 ");
            Console.WriteLine("==============================================");
            Console.WriteLine($"Persistent Gold: \u001b[33m{Meta.PersistentGold} Gold\u001b[0m");
            Console.WriteLine($"Highest Floor Reached: \u001b[36mFloor {Meta.HighestFloorReached}\u001b[0m");
            Console.WriteLine($"Total Runs Attempted: {Meta.TotalRunsPlayed}");
            Console.WriteLine("----------------------------------------------");
            Console.WriteLine(" [1] Enter the Spire (Ascend the Tower)");
            Console.WriteLine(" [2] The Blood Altar (Permanent Meta Upgrades)");
            Console.WriteLine(" [3] Run Automated Balance Simulation (50 Runs)");
            Console.WriteLine(" [4] View Base Stats");
            Console.WriteLine(" [0] Exit");
            Console.Write("\nChoose an action: ");

            string? choice = Console.ReadLine()?.Trim();
            switch (choice)
            {
                case "1":
                    PlayTowerRun();
                    break;
                case "2":
                    OpenBloodAltar();
                    break;
                case "3":
                    RunBalanceSimulation();
                    break;
                case "4":
                    ShowCurrentBaseStats();
                    break;
                case "0":
                    exit = true;
                    SaveManager.Save(Meta);
                    Console.WriteLine("\nProgress saved. The Spire will await your return...");
                    break;
                default:
                    Console.WriteLine("Invalid choice.");
                    break;
            }
        }
    }

    private static void PlayTowerRun()
    {
        Console.Clear();
        PrintBanner();
        Console.WriteLine("\n\u001b[35m>>> You step into the gloomy archway of the Grim Spire... <<<\u001b[0m\n");

        var manager = new TowerRunManager(Meta);
        manager.StartNewRun();

        while (manager.IsRunActive)
        {
            var floor = manager.CurrentFloor!;
            Console.WriteLine("------------------------------------------------------------------");
            if (floor.Type == FloorType.Boss)
            {
                Console.WriteLine($"\u001b[41m\u001b[37m[BOSS FLOOR {floor.FloorNumber}] {floor.Name.ToUpper()}\u001b[0m");
            }
            else if (floor.Type == FloorType.Elite)
            {
                Console.WriteLine($"\u001b[33m[ELITE FLOOR {floor.FloorNumber}] {floor.Name}\u001b[0m");
            }
            else
            {
                Console.WriteLine($"\u001b[36m[FLOOR {floor.FloorNumber}] {floor.Name}\u001b[0m");
            }

            Console.WriteLine($"Enemies encountered: {string.Join(", ", floor.Enemies.Select(e => $"{e.Name} (HP: {e.CurrentHealth})"))}");
            var pStats = manager.Player.GetEffectiveStats();
            Console.WriteLine($"Your Status: HP {Math.Round(manager.Player.CurrentHealth, 1)}/{pStats.MaxHealth} | ATK {pStats.AttackDamage} | ARM {pStats.Armor} | SPD {pStats.AttackSpeed} | CRIT {pStats.CritChance:P0}");
            Console.WriteLine("Press Enter to engage combat...");
            Console.ReadLine();

            var result = manager.ExecuteCurrentFloorCombat();

            // Print battle highlight events
            foreach (var ev in result.Events.TakeLast(6))
            {
                Console.WriteLine($"  [{ev.TimestampSeconds:0.0}s] {ev.Message}");
            }

            Console.WriteLine($"Combat Duration: {result.DurationSeconds}s | Damage Dealt: {result.TotalDamageDealt} | Damage Taken: {result.TotalDamageTaken}");

            if (result.PlayerWon)
            {
                Console.WriteLine($"\n\u001b[32m✔ Floor Cleared! Gained {floor.GoldReward} Gold (Total Run Gold: {manager.Player.GoldInRun})\u001b[0m");

                // Item Draft
                var draft = manager.CurrentDraftOptions!;
                Console.WriteLine("\n\u001b[33m--- LOOT DROP: Choose 1 of 3 Equipment items ---\u001b[0m");
                for (int i = 0; i < draft.Count; i++)
                {
                    var item = draft[i];
                    Console.WriteLine($" [{i + 1}] {item.GetRarityColorCode()}[{item.Rarity}] {item.Name}\u001b[0m ({item.Slot})");
                    Console.WriteLine($"     {FormatItemStats(item.StatBonuses)}");
                    if (!string.IsNullOrEmpty(item.SpecialEffect))
                    {
                        Console.WriteLine($"     \u001b[35mSpecial: {item.SpecialEffect}\u001b[0m");
                    }
                }

                int chosenIndex = -1;
                while (chosenIndex < 0 || chosenIndex >= draft.Count)
                {
                    Console.Write("Equip item (1, 2, or 3): ");
                    var input = Console.ReadLine()?.Trim();
                    if (int.TryParse(input, out int parsed) && parsed >= 1 && parsed <= 3)
                    {
                        chosenIndex = parsed - 1;
                    }
                }

                var equipped = manager.SelectDraftItem(chosenIndex);
                Console.WriteLine($"\nEquipped \u001b[32m{equipped.Name}\u001b[0m! Restored some health. Moving to Floor {manager.CurrentFloorNumber}...\n");
            }
            else
            {
                Console.WriteLine($"\n\u001b[31m☠ YOU DIED on Floor {floor.FloorNumber}...\u001b[0m");
                Console.WriteLine($"All equipment gathered on this run was lost into the abyss.");
                Console.WriteLine($"Gold salvaged and permanently brought to camp: \u001b[33m+{manager.Player.GoldInRun} Gold\u001b[0m\n");
                SaveManager.Save(Meta);
                Console.WriteLine("Press Enter to return to Camp...");
                Console.ReadLine();
                break;
            }
        }
    }

    private static void OpenBloodAltar()
    {
        bool inAltar = true;
        while (inAltar)
        {
            Console.WriteLine("\n==============================================");
            Console.WriteLine("         THE BLOOD ALTAR (META UPGRADES)      ");
            Console.WriteLine("==============================================");
            Console.WriteLine($"Your Gold: \u001b[33m{Meta.PersistentGold} Gold\u001b[0m\n");

            var upgrades = Enum.GetValues<MetaUpgradeType>();
            for (int i = 0; i < upgrades.Length; i++)
            {
                var type = upgrades[i];
                int rank = Meta.UpgradeRanks[type];
                int cost = Meta.GetUpgradeCost(type);
                string afford = Meta.CanAfford(type) ? "\u001b[32m[Affordable]\u001b[0m" : "\u001b[31m[Too Expensive]\u001b[0m";
                Console.WriteLine($" [{i + 1}] {type,-14} (Rank {rank,2}) - Cost: {cost,4}g {afford}");
            }
            Console.WriteLine(" [0] Return to Base Camp");
            Console.Write("\nSelect upgrade to purchase: ");

            var input = Console.ReadLine()?.Trim();
            if (input == "0")
            {
                inAltar = false;
            }
            else if (int.TryParse(input, out int idx) && idx >= 1 && idx <= upgrades.Length)
            {
                var chosen = upgrades[idx - 1];
                if (Meta.PurchaseUpgrade(chosen))
                {
                    SaveManager.Save(Meta);
                    Console.WriteLine($"\u001b[32m✔ Purchased Rank {Meta.UpgradeRanks[chosen]} of {chosen}!\u001b[0m");
                }
                else
                {
                    Console.WriteLine("\u001b[31m✘ Not enough gold!\u001b[0m");
                }
            }
        }
    }

    private static void RunBalanceSimulation()
    {
        Console.WriteLine("\n[Running 50 headless Monte-Carlo tower runs...]");
        int totalGoldEarned = 0;
        int maxFloor = 1;
        int bossKills = 0;
        var floorDistribution = new Dictionary<int, int>();

        for (int r = 0; r < 50; r++)
        {
            var manager = new TowerRunManager(Meta, seed: 1000 + r);
            manager.StartNewRun();

            while (manager.IsRunActive && manager.CurrentFloorNumber <= 50)
            {
                var result = manager.ExecuteCurrentFloorCombat();
                if (result.PlayerWon)
                {
                    if (manager.CurrentFloor!.Type == FloorType.Boss)
                    {
                        bossKills++;
                    }
                    // Auto-pick highest rarity item
                    var draft = manager.CurrentDraftOptions!;
                    int bestIdx = 0;
                    for (int i = 1; i < draft.Count; i++)
                    {
                        if (draft[i].Rarity > draft[bestIdx].Rarity) bestIdx = i;
                    }
                    manager.SelectDraftItem(bestIdx);
                }
            }

            int finalFloor = manager.Player.HighestFloorReached;
            totalGoldEarned += manager.Player.GoldInRun;
            if (finalFloor > maxFloor) maxFloor = finalFloor;

            floorDistribution[finalFloor] = floorDistribution.GetValueOrDefault(finalFloor, 0) + 1;
        }

        Console.WriteLine("\n--- SIMULATION RESULTS (50 RUNS) ---");
        Console.WriteLine($"Highest Floor Reached: Floor {maxFloor}");
        Console.WriteLine($"Bosses Vanquished: {bossKills}");
        Console.WriteLine($"Average Gold per Run: {totalGoldEarned / 50}g");
        Console.WriteLine("\nFloor Reached Distribution:");
        foreach (var kvp in floorDistribution.OrderBy(k => k.Key))
        {
            string bar = new('#', kvp.Value);
            Console.WriteLine($"  Floor {kvp.Key,2}: {bar} ({kvp.Value} runs)");
        }
    }

    private static void ShowCurrentBaseStats()
    {
        var s = Meta.CalculateStartingStats();
        Console.WriteLine("\n--- PERMANENT STARTING ATTRIBUTES ---");
        Console.WriteLine($"Max Health:      {s.MaxHealth}");
        Console.WriteLine($"Attack Damage:   {s.AttackDamage}");
        Console.WriteLine($"Armor:           {s.Armor}");
        Console.WriteLine($"Attack Speed:    {s.AttackSpeed} hits/sec");
        Console.WriteLine($"Crit Chance:     {s.CritChance:P0}");
        Console.WriteLine($"Crit Multiplier: {s.CritMultiplier:F1}x");
        Console.WriteLine($"Lifesteal:       {s.Lifesteal:P0}");
        Console.WriteLine($"Dodge Chance:    {s.DodgeChance:P0}");
        Console.WriteLine($"Gold Multiplier: {Meta.GetGoldMultiplier():F2}x");
    }

    private static string FormatItemStats(Stats s)
    {
        var parts = new List<string>();
        if (s.AttackDamage > 0) parts.Add($"+{s.AttackDamage} DMG");
        if (s.MaxHealth > 0) parts.Add($"+{s.MaxHealth} HP");
        if (s.Armor > 0) parts.Add($"+{s.Armor} ARM");
        if (s.AttackSpeed > 0) parts.Add($"+{s.AttackSpeed:0.00} SPD");
        if (s.CritChance > 0) parts.Add($"+{s.CritChance:P0} CRIT");
        if (s.Lifesteal > 0) parts.Add($"+{s.Lifesteal:P0} LIFESTEAL");
        if (s.DodgeChance > 0) parts.Add($"+{s.DodgeChance:P0} DODGE");
        return string.Join(" | ", parts);
    }

    private static void PrintBanner()
    {
        Console.ForegroundColor = ConsoleColor.DarkRed;
        Console.WriteLine(@"
 ╦═╗╦═╗╦╔╦╗╔═╗╔═╗╦╦═╗╔═╗
 ║ ╦╠╦╝║║║║╚═╗╠═╝║╠╦╝║╣ 
 ╩═╝╩╚═╩╩ ╩╚═╝╩  ╩╩╚═╚═╝
 === ASCENT OF THE CURSED ===");
        Console.ResetColor();
    }
}
