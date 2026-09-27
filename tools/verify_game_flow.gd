extends SceneTree

var game: Node2D = null
var frame_count: int = 0

func _init():
	print(">>> [TEST] Loading MainGame.tscn...")
	var scene_res = load("res://scenes/MainGame.tscn")
	if scene_res == null:
		push_error("FAILED to load MainGame.tscn")
		quit(1)
		return
	
	game = scene_res.instantiate()
	root.add_child(game)
	print(">>> [TEST] Scene added to root. Waiting for _ready()...")

func _process(delta: float) -> bool:
	frame_count += 1
	if frame_count == 3:
		_execute_tests()
		return true
	return false

func _execute_tests():
	print(">>> [TEST] Starting automated game loop integration test...")
	assert(game != null, "Game node must exist")
	print(">>> [TEST] Initial state is CAMP: ", game.state == game.GameState.CAMP)
	
	# Give 150 gold for testing
	game.save_manager.add_gold(150)
	game._refresh_camp_ui()
	print(">>> [TEST] Added gold. Current persistent gold: %d" % game.save_manager.save_data.get("PersistentGold", 0))
	
	# Test Upgrade purchase
	var initial_rank = game.save_manager.get_upgrade_rank("Health")
	game._on_buy_upgrade("Health", 50)
	var new_rank = game.save_manager.get_upgrade_rank("Health")
	print(">>> [TEST] Upgraded Health rank from %d to %d" % [initial_rank, new_rank])
	assert(new_rank == initial_rank + 1, "Upgrade should increment rank")
	
	# Test Ascend
	game._on_ascend_pressed()
	print(">>> [TEST] Ascended to Floor 1. State is BATTLE: ", game.state == game.GameState.BATTLE)
	assert(game.current_floor == 1, "Current floor should be 1")
	assert(not game.enemy_data.is_empty(), "Enemy data should be populated")
	print(">>> [TEST] Facing enemy: ", game.enemy_data.get("name"))
	
	# Simulate 15 combat updates (1.5 seconds of game time)
	for i in range(15):
		game._process_battle_loop(0.1)
	
	print(">>> [TEST] Combat ticks executed. Player HP: %d, Enemy HP: %d" % [
		game.player_stats.get("current_health"),
		game.enemy_data.get("current_health")
	])
	
	# Defeat enemy directly to test draft modal
	game.enemy_data["current_health"] = 0
	game._enter_draft_state()
	print(">>> [TEST] Enemy defeated. State is DRAFT: ", game.state == game.GameState.DRAFT)
	var card_count = game.draft_cards_container.get_child_count()
	print(">>> [TEST] Draft cards count: %d" % card_count)
	assert(card_count == 3, "Draft modal must present 3 item choices")
	
	# Draft first item
	var items = game.game_data.get_random_items(1, 1)
	game._on_item_drafted(items[0])
	print(">>> [TEST] Item drafted. Ascended to Floor: %d, State: %d" % [game.current_floor, game.state])
	assert(game.current_floor == 2, "Floor should advance to 2")
	
	# Test Perished / Defeat
	game.player_stats["current_health"] = 0
	game._enter_defeat_state()
	print(">>> [TEST] Player perished. State is DEFEAT: ", game.state == game.GameState.DEFEAT)
	assert(game.defeat_modal.visible, "Defeat modal should be visible")
	
	# Return to Altar
	game._on_return_altar_pressed()
	print(">>> [TEST] Returned to Altar. State is CAMP: ", game.state == game.GameState.CAMP)
	assert(game.camp_panel.visible, "Camp panel should be visible")
	
	print(">>> [TEST] ========================================================")
	print(">>> [TEST] ALL AUTOMATED VERIFICATIONS PASSED WITH 100% SUCCESS!   ")
	print(">>> [TEST] ========================================================")
	quit(0)
