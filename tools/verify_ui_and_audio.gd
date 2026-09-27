extends SceneTree

var game: Node2D = null
var frame_count: int = 0

func _init():
	print(">>> [TEST] Loading MainGame.tscn for UI & Audio verification...")
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
	print(">>> [TEST] Running comprehensive UI and Audio feature verifications...")
	assert(game != null, "Game node must exist")
	
	# -------------------------------------------------------------
	# 1. VERIFY AUDIO & VOLUME CONTROLS (INCLUDING AUDIOSERVER MASTER BUS)
	# -------------------------------------------------------------
	print(">>> [TEST 1] Verifying SoundManager and Volume Controls...")
	var snd = game.sound_manager
	assert(snd != null, "SoundManager must exist")
	assert(snd.music_player != null, "Ambient music player must exist")
	assert(snd.music_player.playing, "Ambient music player must be playing")
	
	# Test master volume reduction
	snd.set_master_volume(0.5)
	assert(is_equal_approx(snd.master_volume, 0.5), "Master volume should be 0.5")
	var expected_music_db = snd._calc_db(0.5 * snd.music_volume)
	assert(is_equal_approx(snd.music_player.volume_db, expected_music_db), "Music player volume_db should update immediately")
	if AudioServer.get_bus_count() > 0:
		assert(is_equal_approx(AudioServer.get_bus_volume_db(0), snd._calc_db(0.5)), "AudioServer master bus volume_db should update")
	
	# Test mute (0.0 volume)
	snd.set_master_volume(0.0)
	assert(snd.music_player.volume_db <= -79.0, "Zero volume should result in muted db (<= -79 dB)")
	if AudioServer.get_bus_count() > 0:
		assert(AudioServer.is_bus_mute(0), "AudioServer master bus should be muted at 0.0 volume")
	
	# Test SFX test sound
	snd.set_master_volume(0.8)
	snd.set_sfx_volume(0.8)
	snd.play_test_sound()
	print(">>> [TEST 1] Volume controls and AudioServer bus verified successfully!")
	
	# -------------------------------------------------------------
	# 2. VERIFY LOCALIZATION (RUSSIAN & ENGLISH & HP UNITS)
	# -------------------------------------------------------------
	print(">>> [TEST 2] Verifying Localization system...")
	var loc = game.localization
	assert(loc != null, "Localization node must exist")
	assert(loc.current_language == "ru", "Default language must be Russian ('ru')")
	
	# Test Russian strings and hp_unit
	var ru_camp_title = loc.get_string("camp_title")
	print(">>> [TEST 2] Russian camp title: ", ru_camp_title)
	assert("КРОВАВЫЙ АЛТАРЬ" in ru_camp_title, "Russian camp title must contain 'КРОВАВЫЙ АЛТАРЬ'")
	assert(loc.get_string("hp_unit") == "ОЗ", "Russian hp_unit must be 'ОЗ'")
	assert(loc.get_string("gold_unit") == "зол.", "Russian gold_unit must be 'зол.'")
	
	# Test item localization
	var test_item = {"id": "rusty_blade", "name": "Rusty Spire Cleaver", "description": "Jagged iron", "slot": "Weapon", "rarity": "Common"}
	var ru_item_name = loc.get_item_name(test_item)
	assert(ru_item_name == "Ржавый тесак Шпиля", "Item name should be translated to Russian")
	assert(loc.get_slot_name("Weapon") == "Оружие", "Weapon slot must be 'Оружие'")
	assert(loc.get_rarity_name("Legendary") == "Легендарный", "Legendary rarity must be 'Легендарный'")
	
	# Switch to English and test hp_unit
	loc.set_language("en")
	assert(loc.current_language == "en", "Language should be switched to 'en'")
	assert(loc.get_string("hp_unit") == "HP", "English hp_unit must be 'HP'!")
	assert(loc.get_string("gold_unit") == "G", "English gold_unit must be 'G'!")
	var en_item_name = loc.get_item_name(test_item)
	assert(en_item_name == "Rusty Spire Cleaver", "English item name should match")
	assert(loc.get_slot_name("Weapon") == "Weapon", "English slot should be 'Weapon'")
	
	# Switch back to Russian
	loc.set_language("ru")
	assert(loc.current_language == "ru", "Language should be back to 'ru'")
	print(">>> [TEST 2] Localization and unit definitions verified successfully!")
	
	# -------------------------------------------------------------
	# 3. VERIFY UI LAYOUT, COORDINATES, AND ZERO OVERLAPS
	# -------------------------------------------------------------
	print(">>> [TEST 3] Verifying UI layout, coordinates, and layer isolation...")
	
	# In CAMP state:
	assert(game.camp_panel.visible, "Camp panel must be visible in CAMP")
	assert(not game.battle_hud.visible, "BattleHUD MUST be hidden in CAMP")
	assert(not game.draft_modal.visible, "DraftModal MUST be hidden in CAMP")
	assert(not game.defeat_modal.visible, "DefeatModal MUST be hidden in CAMP")
	assert(game.top_hud.visible, "TopHUD must be visible in CAMP")
	
	# In BATTLE state:
	game._start_floor_battle()
	assert(game.battle_hud.visible, "BattleHUD must be visible in BATTLE")
	assert(not game.camp_panel.visible, "Camp panel must be hidden in BATTLE")
	assert(not game.draft_modal.visible, "DraftModal must be hidden in BATTLE")
	assert(not game.defeat_modal.visible, "DefeatModal must be hidden in BATTLE")
	assert(game.top_hud.visible, "TopHUD must be visible in BATTLE")
	
	# Verify NO OVERLAP in Battle HUD:
	var player_bar_r = game.player_hp_bar.offset_right
	var combat_log_panel = game.get_node("UI/BattleHUD/CombatLogPanel")
	var combat_log_l = combat_log_panel.offset_left
	var combat_log_r = combat_log_panel.offset_right
	var enemy_bar_l = game.enemy_hp_bar.offset_left
	
	print(">>> [TEST 3] Layout check: Player right=%d, CombatLog left=%d, CombatLog right=%d, Enemy left=%d" % [
		player_bar_r, combat_log_l, combat_log_r, enemy_bar_l
	])
	assert(player_bar_r <= combat_log_l, "Player panel MUST NOT overlap combat log (player_r <= log_l)")
	assert(combat_log_r <= enemy_bar_l, "Combat log MUST NOT overlap enemy panel (log_r <= enemy_l)")
	
	# Verify HP labels do NOT use gold_unit
	assert("ОЗ" in game.player_hp_label.text, "Russian player HP label must contain 'ОЗ'")
	assert(not ("зол." in game.player_hp_label.text), "Player HP label must not contain 'зол.'")
	
	# Verify dynamic language switch in battle updates ALL headers
	game.localization.set_language("en")
	assert("HP" in game.player_hp_label.text, "English player HP label must contain 'HP', not 'G'")
	assert(not game.player_hp_label.text.ends_with("G"), "English player HP label must not end with 'G'")
	assert("FLOOR 1" in game.floor_banner.text, "Floor banner must switch to English 'FLOOR 1'")
	assert("Feeble Skeleton" in game.enemy_name_label.text, "Enemy name must switch to English 'Feeble Skeleton'")
	assert("G" in game.gold_label.text, "Gold label must switch to 'G'")
	
	# Switch back to Russian
	game.localization.set_language("ru")
	assert("ЭТАЖ 1" in game.floor_banner.text, "Floor banner must switch back to Russian 'ЭТАЖ 1'")
	assert("Неупокоенный скелет" in game.enemy_name_label.text, "Enemy name must switch back to Russian")
	assert("зол." in game.gold_label.text, "Gold label must switch back to 'зол.'")
	print(">>> [TEST 3] Battle HUD dynamic localization and layout verified!")
	
	# -------------------------------------------------------------
	# 4. VERIFY COMBAT PAUSE WHEN SETTINGS MODAL IS OPEN
	# -------------------------------------------------------------
	print(">>> [TEST 4] Verifying combat pause during Settings modal...")
	game.player_attack_cooldown = 1.0
	game.enemy_attack_cooldown = 1.0
	game.settings_modal.visible = true
	game._process(0.5)
	assert(is_equal_approx(game.player_attack_cooldown, 1.0), "Player cooldown MUST NOT decrement while settings is open")
	assert(is_equal_approx(game.enemy_attack_cooldown, 1.0), "Enemy cooldown MUST NOT decrement while settings is open")
	game.settings_modal.visible = false
	game._process(0.2)
	assert(game.player_attack_cooldown < 1.0, "Cooldown should decrement after settings modal is closed")
	print(">>> [TEST 4] Combat pause during settings verified!")
	
	# -------------------------------------------------------------
	# 5. VERIFY DRAFT MODAL: NO RE-ROLL ON LANGUAGE SWITCH & TOPHUD ACCESS
	# -------------------------------------------------------------
	print(">>> [TEST 5] Verifying Draft modal card stability and TopHUD access...")
	game.enemy_data["current_health"] = 0
	game._enter_draft_state()
	assert(game.draft_modal.visible, "DraftModal must be visible in DRAFT")
	assert(not game.battle_hud.visible, "BattleHUD MUST be hidden in DRAFT")
	assert(game.top_hud.visible, "TopHUD must remain visible and accessible in DRAFT")
	assert(not game.get_node("Arena").visible, "Arena must be hidden in DRAFT to prevent sprite bleed-through")
	assert(game.draft_cards_container.get_child_count() == 3, "Draft cards container must have 3 cards")
	assert(game.draft_gear_bar.get_child_count() == 5, "Draft current gear bar must show 5 equipped slot summaries")
	
	# Capture initial draft item IDs
	var initial_item_ids = []
	for itm in game.current_draft_items:
		initial_item_ids.append(itm.get("id"))
	assert(initial_item_ids.size() == 3, "Must have 3 draft items stored")
	
	# Toggle language while in Draft state!
	game._on_toggle_lang_pressed()
	var new_item_ids = []
	for itm in game.current_draft_items:
		new_item_ids.append(itm.get("id"))
	assert(initial_item_ids == new_item_ids, "Draft items MUST NOT reroll when toggling language or refreshing!")
	assert(game.draft_cards_container.get_child_count() == 3, "Must still have 3 cards after toggle")
	
	# Toggle back to Russian
	game._on_toggle_lang_pressed()
	assert(game.localization.current_language == "ru", "Language should be Russian")
	print(">>> [TEST 5] Draft stability across language switch verified!")
	
	# -------------------------------------------------------------
	# 6. VERIFY DEFEAT SCREEN & RUN GOLD TRACKING
	# -------------------------------------------------------------
	print(">>> [TEST 6] Verifying Defeat modal and run gold tracking...")
	game.run_gold_earned = 135
	game.player_stats["current_health"] = 0
	game._enter_defeat_state()
	assert(game.defeat_modal.visible, "DefeatModal must be visible in DEFEAT")
	assert(not game.battle_hud.visible, "BattleHUD MUST be hidden in DEFEAT")
	assert(game.top_hud.visible, "TopHUD must remain visible in DEFEAT")
	assert(not game.get_node("Arena").visible, "Arena must be hidden in DEFEAT")
	print(">>> [TEST 6] Defeat summary text: ", game.defeat_summary_label.text)
	assert("+135" in game.defeat_summary_label.text, "Defeat summary MUST display the actual run gold earned (+135), not +0!")
	
	# -------------------------------------------------------------
	# 7. VERIFY SETTINGS MODAL INTERACTION
	# -------------------------------------------------------------
	print(">>> [TEST 7] Verifying Settings Modal interactive controls...")
	assert(not game.settings_modal.visible, "Settings modal initially hidden")
	game._toggle_settings_modal()
	assert(game.settings_modal.visible, "Settings modal opened via toggle")
	
	var test_vol = 60.0 if game.slider_master.value != 60.0 else 70.0
	game.slider_master.value = test_vol
	assert(is_equal_approx(game.sound_manager.master_volume, test_vol / 100.0), "Slider master should update master_volume")
	assert(game.val_master.text == ("%d%%" % int(test_vol)), "Value label should match slider")
	
	# Restore to 80%
	game.slider_master.value = 80.0
	game._toggle_settings_modal()
	assert(not game.settings_modal.visible, "Settings modal closed via toggle")
	
	print(">>> [TEST] ========================================================")
	print(">>> [TEST] ALL EXTENSIVE UI AND AUDIO VERIFICATIONS PASSED 100%!   ")
	print(">>> [TEST] ========================================================")
	quit(0)
