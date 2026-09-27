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
	assert(game.state == game.GameState.CAMP, "Initial state must be CAMP")
	
	# Verify visual textures and non-sinking sprite Y positions
	game._process(0.016)
	print(">>> [TEST] Player Sprite Y position: ", game.player_sprite.position.y)
	assert(game.player_sprite.position.y < -170.0 and game.player_sprite.position.y > -190.0, "Player sprite must be anchored above ground (~ -180px)")
	assert(game.enemy_sprite.position.y < -170.0 and game.enemy_sprite.position.y > -190.0, "Enemy sprite must be anchored above ground (~ -180px)")
	
	# Verify Camp Altar background
	assert(game.bg_texture.texture != null, "Camp background texture must be set")
	print(">>> [TEST] Camp background loaded successfully: ", game.bg_texture.texture.resource_path)
	
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
	
	# Test Ascend to Floor 1
	game._on_ascend_pressed()
	print(">>> [TEST] Ascended to Floor 1. State is BATTLE: ", game.state == game.GameState.BATTLE)
	assert(game.current_floor == 1, "Current floor should be 1")
	assert(not game.enemy_data.is_empty(), "Enemy data should be populated")
	print(">>> [TEST] Facing Floor 1 enemy: ", game.enemy_data.get("name"))
	assert(game.enemy_sprite.texture == game.tex_enemy_skeleton, "Floor 1 enemy must use distinct enemy_skeleton texture")
	
	# Test Floor 2 (Spire Imp) visuals
	game.current_floor = 2
	game._start_floor_battle()
	print(">>> [TEST] Facing Floor 2 enemy: ", game.enemy_data.get("name"))
	assert(game.enemy_sprite.texture == game.tex_enemy_imp, "Floor 2 enemy must use distinct enemy_imp texture")
	
	# Test Floor 5 (Hollow Knight) visuals
	game.current_floor = 5
	game._start_floor_battle()
	print(">>> [TEST] Facing Floor 5 enemy: ", game.enemy_data.get("name"))
	assert(game.enemy_sprite.texture == game.tex_enemy_knight, "Floor 5 enemy must use distinct enemy_knight texture")
	
	# Test Floor 10 (Gargoyle Boss) visuals
	game.current_floor = 10
	game._start_floor_battle()
	print(">>> [TEST] Facing Floor 10 Boss: ", game.enemy_data.get("name"))
	assert(game.enemy_data.get("isBoss") == true, "Floor 10 must be a Boss floor")
	assert(game.enemy_sprite.texture == game.tex_boss_malgorath, "Floor 10 Boss must use distinct boss_malgorath texture")
	
	# Test Floor 20 (Flesh Amalgam Boss) visuals
	game.current_floor = 20
	game._start_floor_battle()
	print(">>> [TEST] Facing Floor 20 Boss: ", game.enemy_data.get("name"))
	assert(game.enemy_data.get("isBoss") == true, "Floor 20 must be a Boss floor")
	assert(game.enemy_sprite.texture == game.tex_boss_amalgam, "Floor 20 Boss must use distinct boss_amalgam texture")
	
	# Return to Floor 1 for combat simulation
	game.current_floor = 1
	game._start_floor_battle()
	
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
	
	# Damage player slightly to verify between-floor heal boon
	game.player_stats["current_health"] = 50
	var hp_before_draft = game.player_stats["current_health"]
	
	# Draft first item
	var items = game.game_data.get_random_items(1, 1)
	game._on_item_drafted(items[0])
	print(">>> [TEST] Item drafted. Ascended to Floor: %d, State: %d" % [game.current_floor, game.state])
	assert(game.current_floor == 2, "Floor should advance to 2")
	assert(game.player_stats["current_health"] > hp_before_draft, "Between-floor heal boon must restore HP")
	print(">>> [TEST] Between-floor heal verified. HP before: %d, HP after: %d" % [hp_before_draft, game.player_stats["current_health"]])
	
	# Test Perished / Defeat
	game.player_stats["current_health"] = 0
	game._enter_defeat_state()
	print(">>> [TEST] Player perished. State is DEFEAT: ", game.state == game.GameState.DEFEAT)
	assert(game.defeat_modal.visible, "Defeat modal should be visible")
	
	# Return to Altar
	game._on_return_altar_pressed()
	print(">>> [TEST] Returned to Altar. State is CAMP: ", game.state == game.GameState.CAMP)
	assert(game.camp_panel.visible, "Camp panel should be visible")
	assert(game.current_floor == 1, "Floor must reset to 1 on return to camp")
	assert(game.equipped_items.is_empty(), "Equipped items must be cleared on return to camp")
	
	# Verify all 6 3D models can be loaded
	var model_paths = [
		"res://assets/models/blood_altar.gltf",
		"res://assets/models/gargoyle_boss.gltf",
		"res://assets/models/enemy_skeleton.gltf",
		"res://assets/models/enemy_imp.gltf",
		"res://assets/models/enemy_knight.gltf",
		"res://assets/models/boss_amalgam.gltf"
	]
	for mp in model_paths:
		assert(ResourceLoader.exists(mp), "3D model must exist and be loadable: " + mp)
		var mdl = load(mp)
		assert(mdl != null, "Failed to load model: " + mp)
		print(">>> [TEST] Verified 3D Model resource: ", mp)
	
	print(">>> [TEST] ========================================================")
	print(">>> [TEST] ALL AUTOMATED VERIFICATIONS PASSED WITH 100% SUCCESS!   ")
	print(">>> [TEST] ========================================================")
	quit(0)
