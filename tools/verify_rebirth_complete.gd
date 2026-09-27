extends SceneTree

var game: Node2D = null
var frame_count: int = 0

func _init():
	print(">>> [REBIRTH TEST] Loading MainGame.tscn for GrimSpire Rebirth verification...")
	var scene_res = load("res://scenes/MainGame.tscn")
	if scene_res == null:
		push_error("FAILED to load MainGame.tscn")
		quit(1)
		return
	
	game = scene_res.instantiate()
	root.add_child(game)
	print(">>> [REBIRTH TEST] Scene added to root. Awaiting frames...")

func _process(delta: float) -> bool:
	frame_count += 1
	if frame_count == 4:
		_execute_rebirth_tests()
		return true
	return false

func _execute_rebirth_tests():
	print(">>> ================================================================")
	print(">>> STARTING COMPREHENSIVE GRIMSPIRE REBIRTH INTEGRATION TESTS")
	print(">>> ================================================================")
	assert(game != null, "Game instance must exist")
	
	# -------------------------------------------------------------
	# PHASE 1: 3D Scene Architecture & 2.5D Camera
	# -------------------------------------------------------------
	print(">>> [TEST 1] Verifying Phase 1: 3D Viewport & 2.5D Camera Setup...")
	assert(game.rebirth_3d != null, "rebirth_3d manager must be instantiated")
	assert(game.rebirth_3d.sub_viewport != null, "SubViewport must exist")
	assert(game.rebirth_3d.cam_3d != null, "Camera3D must exist")
	assert(game.rebirth_3d.cam_3d.fov >= 40.0 and game.rebirth_3d.cam_3d.fov <= 50.0, "2.5D camera FOV must be ~44°")
	print(">>> [TEST 1] Camera FOV: %.1f, rotation: %s" % [game.rebirth_3d.cam_3d.fov, str(game.rebirth_3d.cam_3d.rotation_degrees)])
	
	# Environment nodes
	assert(game.rebirth_3d.camp_group != null, "CampGroup 3D node must exist")
	assert(game.rebirth_3d.iron_gate != null, "IronGate 3D node must exist")
	assert(game.rebirth_3d.elevator != null, "Elevator 3D node must exist")
	assert(game.rebirth_3d.chest != null, "Chest 3D node must exist")
	print(">>> [TEST 1] Phase 1: 3D Scene Architecture & Camera verified successfully!")
	
	# -------------------------------------------------------------
	# PHASE 2: 3D Skeletal Characters & Party Rigging
	# -------------------------------------------------------------
	print(">>> [TEST 2] Verifying Phase 2: 3D Party Characters & Rigs...")
	var expected_roles = ["bulwark", "wanderer", "nightshade", "bloodweaver"]
	for r in expected_roles:
		assert(game.rebirth_3d.party_models.has(r), "3D Model must exist for " + r)
		assert(game.rebirth_3d.party_models[r] != null, "3D Model instance must not be null for " + r)
		assert(game.rebirth_3d.party_anims.has(r), "AnimationPlayer must exist for " + r)
		print(">>> [TEST 2] Verified 3D rigged character: %s with animation player" % r)
	
	# Verify party HUD
	assert(game.party_hud_container != null, "party_hud_container must exist")
	assert(game.party_hp_bars.size() == 4, "Party HUD must have 4 HP bars")
	print(">>> [TEST 2] Phase 2: Skeletal Characters & Rigs verified successfully!")
	
	# -------------------------------------------------------------
	# PHASE 3: Squad Combat Controller & Role Synergies
	# -------------------------------------------------------------
	print(">>> [TEST 3] Verifying Phase 3: Squad Combat Controller & Synergies...")
	game.current_floor = 1
	game._start_floor_battle()
	assert(game.state == game.GameState.BATTLE, "Game state must be BATTLE")
	
	# Test Tank Taunt & Shield Block Mitigation (-60%)
	var tank = game.party_members["bulwark"]
	tank["active"] = true
	tank["taunt_cooldown"] = 0.0
	tank["taunt_timer"] = 0.0
	var initial_tank_hp = tank["current_hp"]
	
	# Process tick to trigger taunt
	game._process_battle_loop(0.05)
	assert(tank["taunt_timer"] > 0.0, "Bulwark taunt must be active after triggering")
	print(">>> [TEST 3] Tank Taunt active timer: %.2f" % tank["taunt_timer"])
	
	# Simulate enemy attack while taunt is active
	var hero_hp_before = game.player_stats["current_health"]
	game.enemy_attack_cooldown = 0.0
	game._execute_enemy_attack()
	assert(tank["current_hp"] < initial_tank_hp, "Tank must absorb mitigated damage during Taunt")
	assert(game.player_stats["current_health"] == hero_hp_before, "Hero must NOT take damage when Tank is taunting")
	print(">>> [TEST 3] Tank absorbed damage: HP %d -> %d. Hero HP untouched at %d" % [initial_tank_hp, tank["current_hp"], hero_hp_before])
	
	# Test Cleric Blood Mending
	var cleric = game.party_members["bloodweaver"]
	cleric["active"] = true
	cleric["heal_cooldown"] = 0.0
	tank["current_hp"] = 150 # Set wounded HP to trigger Blood Mending
	var tank_damaged_hp = tank["current_hp"]
	# Process tick to trigger Cleric heal
	game._process_battle_loop(0.05)
	assert(tank["current_hp"] > tank_damaged_hp, "Cleric must heal lowest HP companion (Tank)")
	print(">>> [TEST 3] Cleric healed Tank: HP %d -> %d" % [tank_damaged_hp, tank["current_hp"]])
	
	# Test Thief Backstab & Crit Strike
	var thief = game.party_members["nightshade"]
	thief["active"] = true
	thief["backstab_cooldown"] = 0.0
	game.enemy_data["current_health"] = 250
	game.enemy_data["max_health"] = 250
	var enemy_hp_before_backstab = game.enemy_data["current_health"]
	game._process_battle_loop(0.05)
	assert(game.enemy_data["current_health"] < enemy_hp_before_backstab, "Thief Backstab must deal massive critical strike")
	print(">>> [TEST 3] Thief Backstab executed! Enemy HP: %d -> %d" % [enemy_hp_before_backstab, game.enemy_data["current_health"]])
	
	# Test Hero Soul Cleave
	game.player_soul = 100.0
	game.player_attack_cooldown = 0.0
	var enemy_hp_before_cleave = game.enemy_data["current_health"]
	game._process_battle_loop(0.05)
	assert(game.player_soul == 0.0, "Hero Soul Cleave must consume 100 soul")
	print(">>> [TEST 3] Phase 3: Squad Combat Controller verified successfully!")
	
	# -------------------------------------------------------------
	# PHASE 4: Locked Chests, Thief Lockpicking, Smart Loot & Item Fusion
	# -------------------------------------------------------------
	print(">>> [TEST 4] Verifying Phase 4: Chests, Thief Lockpicking, Smart Loot & Item Fusion...")
	assert(game.chest_modal != null, "chest_modal must exist")
	assert(game.chest_btn_thief != null, "chest_btn_thief button must exist")
	
	# Test chest modal visibility when Thief is active
	game.party_members["nightshade"]["active"] = true
	game._show_treasure_chest_modal()
	assert(game.chest_modal.visible == true, "Chest modal must be visible")
	assert(game.chest_btn_thief.visible == true, "Thief lockpick option must be visible when Thief is active")
	print(">>> [TEST 4] Chest modal and Thief lockpick option verified!")
	
	# Test Thief lockpick execution
	game._on_thief_lockpick_pressed()
	assert(game.chest_modal.visible == false, "Chest modal must close upon lockpicking")
	assert(game.state == game.GameState.DRAFT, "Lockpicking must transition to DRAFT state")
	print(">>> [TEST 4] Thief lockpick opened chest and entered DRAFT successfully!")
	
	# Test Smart Loot (no duplicates)
	game.equipped_items.clear()
	var test_weapon = {"id": "iron_broadsword", "name": "Iron Broadsword", "slot": "Weapon", "tier": 1, "rarity": "Common", "stats": {"AttackDamage": 15}}
	game.equipped_items["Weapon"] = test_weapon
	var smart_items = game.game_data.get_smart_draft_items(3, 1, game.equipped_items)
	assert(smart_items.size() == 3, "Smart draft must return 3 items")
	var dup_found = false
	for itm in smart_items:
		if itm.get("name") == "Iron Broadsword" and not itm.get("is_fusion", false):
			dup_found = true
	assert(not dup_found, "Smart draft must not offer exact equipped duplicate without fusion")
	print(">>> [TEST 4] Smart loot diversity verified!")
	
	# Test Item Fusion
	var base_item = {"id": "relic_sun", "name": "Sun Amulet", "slot": "Accessory", "tier": 1, "rarity": "Rare", "stats": {"MaxHealth": 20, "AttackDamage": 5}}
	var sac_item = {"id": "relic_sun_dup", "name": "Sun Amulet", "slot": "Accessory", "tier": 1, "rarity": "Rare", "stats": {"MaxHealth": 20, "AttackDamage": 5}}
	var fused_tier2 = game.game_data.fuse_items(base_item, sac_item)
	assert(fused_tier2["tier"] == 2, "Fused item must advance to Tier 2")
	assert(fused_tier2["stats"]["MaxHealth"] > 20, "Fused stats must scale up (MaxHealth > 20)")
	assert(fused_tier2["stats"]["AttackDamage"] > 5, "Fused stats must scale up (AttackDamage > 5)")
	print(">>> [TEST 4] Item Fusion Tier 1 -> Tier 2 verified: MaxHealth %d, Damage %d" % [fused_tier2["stats"]["MaxHealth"], fused_tier2["stats"]["AttackDamage"]])
	
	var fused_tier3 = game.game_data.fuse_items(fused_tier2, sac_item)
	assert(fused_tier3["tier"] == 3, "Fused item must advance to Tier 3")
	assert(fused_tier3["stats"]["MaxHealth"] > fused_tier2["stats"]["MaxHealth"], "Tier 3 stats must exceed Tier 2")
	print(">>> [TEST 4] Item Fusion Tier 2 -> Tier 3 verified: MaxHealth %d, Damage %d" % [fused_tier3["stats"]["MaxHealth"], fused_tier3["stats"]["AttackDamage"]])
	
	# Test Thief +35% gold find passive in _on_enemy_defeated
	var gold_before_kill = game.save_manager.save_data.get("PersistentGold", 0)
	game.enemy_data = {"id": "enemy_test", "name": "Test Beast", "gold_reward": 100, "current_health": 0}
	game.party_members["nightshade"]["active"] = true
	game._on_enemy_defeated()
	var gold_gain = game.save_manager.save_data.get("PersistentGold", 0) - gold_before_kill
	# 100 gold * 1.35 = 135
	assert(gold_gain >= 135, "Thief passive must award 35% bonus gold")
	print(">>> [TEST 4] Thief +35% gold find passive verified: earned ", gold_gain, " gold")
	
	# -------------------------------------------------------------
	# PHASE 5: Dark Medieval Lo-Fi / Dungeon Synth Music Engine
	# -------------------------------------------------------------
	print(">>> [TEST 5] Verifying Phase 5: Dark Medieval Lo-Fi Audio Engine...")
	var sm = game.sound_manager
	assert(sm != null, "SoundManager must exist")
	assert(sm.bgm_camp != null, "Camp theme BGM stream must exist")
	assert(sm.bgm_combat != null, "Combat theme BGM stream must exist")
	assert(sm.bgm_camp.format == AudioStreamWAV.FORMAT_16_BITS, "Camp BGM must be 16-bit format")
	assert(sm.bgm_combat.format == AudioStreamWAV.FORMAT_16_BITS, "Combat BGM must be 16-bit format")
	assert(sm.bgm_camp.mix_rate == 22050, "Camp BGM mix rate must be 22050 Hz")
	assert(sm.bgm_combat.mix_rate == 22050, "Combat BGM mix rate must be 22050 Hz")
	print(">>> [TEST 5] Verified 16-bit 22050 Hz audio stream specifications")
	
	# Test Rebirth SFX streams
	var sfx_list = [
		sm.sfx_lockpick, sm.sfx_gate, sm.sfx_elevator,
		sm.sfx_taunt, sm.sfx_heal, sm.sfx_backstab, sm.sfx_fusion
	]
	for sfx in sfx_list:
		assert(sfx != null, "Rebirth SFX stream must not be null")
		assert(sfx.format == AudioStreamWAV.FORMAT_16_BITS, "SFX must be 16-bit")
	print(">>> [TEST 5] All 7 Rebirth SFX streams verified!")
	
	# Test camp and combat playback switches
	sm.play_camp_theme()
	assert(sm.current_music_mode == "camp", "Music mode must switch to camp")
	sm.play_combat_theme()
	assert(sm.current_music_mode == "combat", "Music mode must switch to combat")
	print(">>> [TEST 5] Music stream switching verified!")
	
	print(">>> ================================================================")
	print(">>> ALL GRIMSPIRE REBIRTH INTEGRATION TESTS PASSED 100% SUCCESSFULLY!")
	print(">>> ================================================================")
	quit(0)
