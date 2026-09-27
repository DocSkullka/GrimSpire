extends SceneTree

var game: Node2D = null
var frame_count: int = 0

func _init():
	print(">>> [TEST] Loading MainGame.tscn for Enhanced Gameplay verification...")
	var scene_res = load("res://scenes/MainGame.tscn")
	if scene_res == null:
		push_error("FAILED to load MainGame.tscn")
		quit(1)
		return
	
	game = scene_res.instantiate()
	root.add_child(game)

func _process(delta: float) -> bool:
	frame_count += 1
	if frame_count == 3:
		_execute_tests()
		return true
	return false

func _execute_tests():
	print(">>> [TEST] ========================================================")
	print(">>> [TEST] STARTING ENHANCED GAMEPLAY & MODULAR VISUALS VERIFICATION")
	print(">>> [TEST] ========================================================")
	assert(game != null, "Game instance must exist")
	
	# -------------------------------------------------------------
	# 1. VERIFY MODULAR PAPER-DOLL RIG & EQUIPMENT VISUALS
	# -------------------------------------------------------------
	print(">>> [TEST 1] Verifying Modular Paper-Doll Rig Nodes...")
	assert(game.weapon_sprite != null, "weapon_sprite must exist")
	assert(game.armor_overlay != null, "armor_overlay must exist")
	assert(game.helm_overlay != null, "helm_overlay must exist")
	assert(game.offhand_sprite != null, "offhand_sprite must exist")
	assert(game.accessory_aura != null, "accessory_aura must exist")
	assert(game.walk_dust != null, "walk_dust particle node must exist")
	assert(game.archway_sprite != null, "archway_sprite dungeon prop must exist")
	assert(game.chest_sprite != null, "chest_sprite loot prop must exist")
	
	# Initially unequipped -> overlays hidden
	game._update_player_visuals()
	assert(not game.weapon_sprite.visible, "Weapon overlay should be hidden when unequipped")
	assert(not game.armor_overlay.visible, "Armor overlay should be hidden when unequipped")
	assert(not game.helm_overlay.visible, "Helm overlay should be hidden when unequipped")
	assert(not game.offhand_sprite.visible, "Offhand overlay should be hidden when unequipped")
	assert(not game.accessory_aura.visible, "Accessory aura should be hidden when unequipped")
	print(">>> [TEST 1] Initial unequipped state verified!")
	
	# Equip full set of gear
	game.equipped_items["Weapon"] = {"id": "blood_scythe", "slot": "Weapon", "rarity": "Legendary", "name": "Harvester of the Damned"}
	game.equipped_items["Armor"] = {"id": "bone_carapace", "slot": "Armor", "rarity": "Uncommon", "name": "Carapace of the Unburied"}
	game.equipped_items["Helmet"] = {"id": "crown_of_thorns", "slot": "Helmet", "rarity": "Cursed", "name": "Martyr's Jagged Crown"}
	game.equipped_items["OffHand"] = {"id": "weeping_shield", "slot": "OffHand", "rarity": "Rare", "name": "Buckler of the Weeping Mother"}
	game.equipped_items["Accessory"] = {"id": "heart_of_the_spire", "slot": "Accessory", "rarity": "Legendary", "name": "Heart of the Nether Citadels"}
	
	game._update_player_visuals()
	assert(game.weapon_sprite.visible, "Weapon overlay must become visible when weapon is equipped")
	assert(game.weapon_sprite.texture != null, "Weapon texture must be set")
	assert(game.armor_overlay.visible, "Armor overlay must become visible when armor is equipped")
	assert(game.helm_overlay.visible, "Helm overlay must become visible when helmet is equipped")
	assert(game.offhand_sprite.visible, "Offhand overlay must become visible when offhand is equipped")
	assert(game.accessory_aura.visible, "Accessory aura must activate when accessory is equipped")
	print(">>> [TEST 1] Full modular paper-doll visual equipping verified successfully!")
	
	# -------------------------------------------------------------
	# 2. VERIFY SKIP & SALVAGE LOOT DRAFT (DECLINE GEAR FEATURE)
	# -------------------------------------------------------------
	print(">>> [TEST 2] Verifying Skip & Salvage Loot Draft...")
	game.current_floor = 4
	game.player_stats["max_health"] = 120
	game.player_stats["current_health"] = 60
	var hp_before_salvage = game.player_stats["current_health"]
	var gold_before_salvage = game.save_manager.save_data.get("PersistentGold", 0)
	var expected_salvage_bonus = 20 + 4 * 5 # 40 gold
	
	# Verify skip button exists
	assert(game.btn_skip_draft != null, "Skip & Salvage button must exist in Draft modal")
	
	# Execute skip draft action
	game._on_skip_draft_pressed()
	
	var gold_after_salvage = game.save_manager.save_data.get("PersistentGold", 0)
	var hp_after_salvage = game.player_stats["current_health"]
	
	print(">>> [TEST 2] Gold before: %d, after: %d (expected +%d)" % [gold_before_salvage, gold_after_salvage, expected_salvage_bonus])
	print(">>> [TEST 2] HP before: %d, after: %d" % [hp_before_salvage, hp_after_salvage])
	assert(gold_after_salvage == gold_before_salvage + expected_salvage_bonus, "Salvaging spoils must award gold")
	assert(hp_after_salvage > hp_before_salvage, "Skipping draft must grant heal boon")
	assert(game.current_floor == 5, "Floor must advance from 4 to 5 after salvage")
	assert(game.equipped_items["Weapon"].get("id") == "blood_scythe", "Equipped gear must NOT be altered or replaced")
	print(">>> [TEST 2] Skip & Salvage feature verified flawlessly!")
	
	# -------------------------------------------------------------
	# 3. VERIFY SOUL CLEAVE SPECIAL ABILITY & COMBAT SPEED
	# -------------------------------------------------------------
	print(">>> [TEST 3] Verifying Soul Gauge, Soul Cleave & Combat Speed...")
	assert(game.soul_bar != null, "soul_bar node must exist")
	assert(game.speed_btn != null, "speed_btn node must exist")
	
	# Test speed toggle
	assert(game.combat_speed == 1.0, "Initial speed is 1.0x")
	game._on_toggle_speed_pressed()
	assert(game.combat_speed == 1.5, "Next speed is 1.5x")
	game._on_toggle_speed_pressed()
	assert(game.combat_speed == 2.0, "Next speed is 2.0x")
	game._on_toggle_speed_pressed()
	assert(game.combat_speed == 1.0, "Cycles back to 1.0x")
	print(">>> [TEST 3] Combat speed toggle (1x / 1.5x / 2x) verified!")
	
	# Test Soul Bar Accumulation and Discharge
	game.player_soul = 0.0
	game.current_floor = 1
	game._start_floor_battle()
	
	# Deal attack to charge soul
	game._execute_player_attack()
	assert(game.player_soul > 0.0, "Soul gauge must increase upon attacking")
	print(">>> [TEST 3] Player soul after attack: %.1f%%" % game.player_soul)
	
	# Set to 100% and execute soul cleave
	game.player_soul = 100.0
	var enemy_hp_before = game.enemy_data["current_health"]
	game._execute_player_soul_cleave()
	assert(game.player_soul == 0.0, "Soul gauge must reset to 0.0 after Soul Cleave")
	assert(game.enemy_data["current_health"] < enemy_hp_before, "Soul Cleave must inflict massive damage")
	print(">>> [TEST 3] Soul Cleave executed! Enemy HP reduced from %d to %d" % [enemy_hp_before, game.enemy_data["current_health"]])
	
	# -------------------------------------------------------------
	# 4. VERIFY EXPANDED BESTIARY & ARMORY DATA (16 ENEMIES & 32 ITEMS)
	# -------------------------------------------------------------
	print(">>> [TEST 4] Verifying Expanded Data & Compendium...")
	var en_count = game.game_data.enemies.size()
	var it_count = game.game_data.items.size()
	print(">>> [TEST 4] Total enemies in database: %d (expected >= 16)" % en_count)
	print(">>> [TEST 4] Total items in database: %d (expected >= 32)" % it_count)
	assert(en_count >= 16, "Enemies database must have at least 16 entries")
	assert(it_count >= 32, "Items database must have at least 32 entries")
	
	# Test Floor 30 Final Boss (Valthor)
	var boss30 = game.game_data.get_enemy_for_floor(30)
	print(">>> [TEST 4] Floor 30 Final Boss: ", boss30.get("name"))
	assert(boss30.get("isBoss") == true, "Floor 30 must be Boss floor")
	assert(boss30.get("id") == "boss_valthor", "Floor 30 boss must be boss_valthor")
	
	# Test Compendium modal
	assert(game.compendium_modal != null, "Compendium modal must exist")
	game._open_compendium()
	assert(game.compendium_modal.visible, "Compendium modal should open on request")
	game.compendium_modal.visible = false
	
	# Test Main Menu modal
	assert(game.main_menu_modal != null, "Main menu modal must exist")
	game._open_main_menu()
	assert(game.main_menu_modal.visible, "Main menu modal should open on request")
	game.main_menu_modal.visible = false
	print(">>> [TEST 4] Bestiary, Armory, and Main Menu Modals verified!")
	
	# -------------------------------------------------------------
	# 5. VERIFY DUNGEON PROPS & TRAVERSAL ANIMATION
	# -------------------------------------------------------------
	print(">>> [TEST 5] Verifying Traversal Architecture & Dungeon Props...")
	assert(game.archway_sprite != null, "Archway sprite exists")
	assert(game.chest_sprite != null, "Chest sprite exists")
	assert(game.room_clear_banner != null, "Room clear banner exists")
	
	# Simulate floor battle entrance animation
	game.current_floor = 1
	game._start_floor_battle(true)
	assert(game.is_traversing == true, "Entering room with animation sets is_traversing = true")
	assert(game.walk_dust.emitting == true, "Walking dust should emit while traversing")
	
	# Advance frame to allow tween to complete or test state
	game.is_traversing = false
	game.walk_dust.emitting = false
	print(">>> [TEST 5] Walking room transition architecture verified!")
	
	print(">>> [TEST] ========================================================")
	print(">>> [TEST] ALL ENHANCED GAMEPLAY TESTS PASSED WITH 100% SUCCESS!   ")
	print(">>> [TEST] ========================================================")
	quit(0)
