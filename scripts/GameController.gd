extends Node2D

enum GameState { CAMP, BATTLE, DRAFT, DEFEAT }

var state: GameState = GameState.CAMP

# References
var _sound_manager: Node
var _game_data: Node
var _save_manager: Node
var _localization: Node

var sound_manager: Node:
	get:
		if _sound_manager == null:
			_sound_manager = get_node_or_null("SoundManager")
		return _sound_manager

var game_data: Node:
	get:
		if _game_data == null:
			_game_data = get_node_or_null("GameData")
		return _game_data

var save_manager: Node:
	get:
		if _save_manager == null:
			_save_manager = get_node_or_null("SaveManager")
		return _save_manager

var localization: Node:
	get:
		if _localization == null:
			_localization = get_node_or_null("Localization")
			if _localization == null:
				var script = load("res://scripts/Localization.gd")
				if script:
					_localization = script.new()
					add_child(_localization)
		return _localization

# Visual Nodes
@onready var bg_texture = $BackgroundLayer/BackgroundTexture
@onready var ground_shadow = $BackgroundLayer/GroundShadow
@onready var player_sprite = $Arena/PlayerAnchor/PlayerSprite
@onready var player_anchor = $Arena/PlayerAnchor
@onready var enemy_anchor = $Arena/EnemyAnchor
@onready var enemy_sprite = $Arena/EnemyAnchor/EnemySprite
@onready var fx_layer = $Arena/FXLayer

# UI Nodes - Top HUD
@onready var ui_canvas = $UI
@onready var top_hud = $UI/TopHUD
@onready var floor_banner = $UI/TopHUD/FloorBanner
@onready var gold_label = $UI/TopHUD/GoldDisplay/GoldLabel
@onready var gold_icon = $UI/TopHUD/GoldDisplay/GoldIcon
@onready var btn_settings = $UI/TopHUD/LeftControls/BtnSettings
@onready var btn_lang_quick = $UI/TopHUD/LeftControls/BtnLangQuick

# UI Nodes - Battle HUD
@onready var battle_hud = $UI/BattleHUD
@onready var player_hp_bar = $UI/BattleHUD/PlayerHPBar
@onready var player_hp_label = $UI/BattleHUD/PlayerHPBar/HPLabel
@onready var player_name_label = $UI/BattleHUD/PlayerHPBar/NameLabel
@onready var equip_icons_container = $UI/BattleHUD/EquippedGearBar
@onready var player_stats_label = $UI/BattleHUD/PlayerStatsPanel/PlayerStatsLabel
@onready var combat_log = $UI/BattleHUD/CombatLogPanel/LogVBox/CombatLog
@onready var combat_log_header = $UI/BattleHUD/CombatLogPanel/LogVBox/LogHeader
@onready var enemy_hp_bar = $UI/BattleHUD/EnemyHPBar
@onready var enemy_hp_label = $UI/BattleHUD/EnemyHPBar/HPLabel
@onready var enemy_name_label = $UI/BattleHUD/EnemyHPBar/NameLabel
@onready var enemy_stats_label = $UI/BattleHUD/EnemyStatsPanel/EnemyStatsLabel
@onready var enemy_desc_label = $UI/BattleHUD/EnemyDescPanel/EnemyDescLabel

# UI Nodes - Modals
@onready var camp_panel = $UI/CampPanel
@onready var camp_title = $UI/CampPanel/VBox/Header/Title
@onready var camp_subtitle = $UI/CampPanel/VBox/Header/Subtitle
@onready var altar_gold_label = $UI/CampPanel/VBox/Header/AltarGoldLabel
@onready var upgrades_container = $UI/CampPanel/VBox/ScrollContainer/UpgradesVBox
@onready var btn_ascend = $UI/CampPanel/VBox/BtnAscend

@onready var draft_modal = $UI/DraftModal
@onready var draft_cards_container = $UI/DraftModal/VBox/CardsContainer
@onready var draft_title = $UI/DraftModal/VBox/DraftTitle
@onready var draft_subtitle = $UI/DraftModal/VBox/DraftSubtitle
@onready var draft_gear_header = $UI/DraftModal/VBox/CurrentGearHeader
@onready var draft_gear_bar = $UI/DraftModal/VBox/CurrentGearBar

@onready var defeat_modal = $UI/DefeatModal
@onready var defeat_title = $UI/DefeatModal/Panel/VBox/Title
@onready var defeat_summary_label = $UI/DefeatModal/Panel/VBox/SummaryLabel
@onready var btn_return_altar = $UI/DefeatModal/Panel/VBox/BtnReturnAltar

@onready var settings_modal = $UI/SettingsModal
@onready var settings_title = $UI/SettingsModal/Panel/VBox/SettingsTitle
@onready var lbl_master_vol = $UI/SettingsModal/Panel/VBox/LblMasterVol
@onready var slider_master = $UI/SettingsModal/Panel/VBox/HBoxMaster/SliderMaster
@onready var val_master = $UI/SettingsModal/Panel/VBox/HBoxMaster/ValMaster
@onready var lbl_sfx_vol = $UI/SettingsModal/Panel/VBox/LblSfxVol
@onready var slider_sfx = $UI/SettingsModal/Panel/VBox/HBoxSfx/SliderSfx
@onready var val_sfx = $UI/SettingsModal/Panel/VBox/HBoxSfx/ValSfx
@onready var lbl_music_vol = $UI/SettingsModal/Panel/VBox/LblMusicVol
@onready var slider_music = $UI/SettingsModal/Panel/VBox/HBoxMusic/SliderMusic
@onready var val_music = $UI/SettingsModal/Panel/VBox/HBoxMusic/ValMusic
@onready var btn_test_sound = $UI/SettingsModal/Panel/VBox/BtnTestSound
@onready var lbl_language = $UI/SettingsModal/Panel/VBox/HBoxLang/LblLanguage
@onready var btn_toggle_lang = $UI/SettingsModal/Panel/VBox/HBoxLang/BtnToggleLang
@onready var check_fullscreen = $UI/SettingsModal/Panel/VBox/CheckFullscreen
@onready var btn_close_settings = $UI/SettingsModal/Panel/VBox/BtnCloseSettings

# Game Logic Variables
var current_floor: int = 1
var player_stats: Dictionary = {}
var enemy_data: Dictionary = {}
var equipped_items: Dictionary = {} # slot -> item_dict
var current_draft_items: Array = []
var run_gold_earned: int = 0

var player_attack_cooldown: float = 0.0
var enemy_attack_cooldown: float = 0.0

var player_base_pos: Vector2
var enemy_base_pos: Vector2

# Textures
var tex_spire_interior: Texture2D
var tex_camp_altar: Texture2D
var tex_player_wanderer: Texture2D
var tex_enemy_skeleton: Texture2D
var tex_enemy_imp: Texture2D
var tex_enemy_knight: Texture2D
var tex_enemy_ghoul: Texture2D
var tex_enemy_cultist: Texture2D
var tex_boss_malgorath: Texture2D
var tex_boss_amalgam: Texture2D
var tex_slash: Texture2D
var tex_blood: Texture2D

var item_icons: Dictionary = {}

func _safe_load_tex(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res != null:
			return res
	var global_path = ProjectSettings.globalize_path(path)
	if FileAccess.file_exists(global_path):
		var img = Image.load_from_file(global_path)
		if img != null:
			return ImageTexture.create_from_image(img)
	return null

func _ready():
	_load_textures()
	player_base_pos = player_anchor.position
	enemy_base_pos = enemy_anchor.position
	
	_apply_ui_theming()
	_init_localization_and_settings()
	
	btn_ascend.pressed.connect(_on_ascend_pressed)
	btn_return_altar.pressed.connect(_on_return_altar_pressed)
	btn_settings.pressed.connect(_on_settings_pressed)
	btn_lang_quick.pressed.connect(_on_toggle_lang_pressed)
	btn_close_settings.pressed.connect(_on_close_settings_pressed)
	btn_toggle_lang.pressed.connect(_on_toggle_lang_pressed)
	btn_test_sound.pressed.connect(_on_test_sound_pressed)
	
	slider_master.value_changed.connect(_on_master_slider_changed)
	slider_sfx.value_changed.connect(_on_sfx_slider_changed)
	slider_music.value_changed.connect(_on_music_slider_changed)
	check_fullscreen.toggled.connect(_on_fullscreen_toggled)
	
	if localization != null:
		localization.language_changed.connect(_on_language_changed)
	
	_calculate_player_stats()
	_enter_camp_state()

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_toggle_settings_modal()

func _load_textures():
	tex_spire_interior = _safe_load_tex("res://assets/textures/spire_interior.png")
	tex_camp_altar = _safe_load_tex("res://assets/textures/camp_altar.png")
	tex_player_wanderer = _safe_load_tex("res://assets/textures/player_wanderer.png")
	tex_enemy_skeleton = _safe_load_tex("res://assets/textures/enemy_skeleton.png")
	tex_enemy_imp = _safe_load_tex("res://assets/textures/enemy_imp.png")
	tex_enemy_knight = _safe_load_tex("res://assets/textures/enemy_knight.png")
	tex_enemy_ghoul = _safe_load_tex("res://assets/textures/enemy_ghoul.png")
	if tex_enemy_ghoul == null:
		tex_enemy_ghoul = _safe_load_tex("res://assets/textures/enemy_skeleton.png")
	tex_enemy_cultist = _safe_load_tex("res://assets/textures/enemy_cultist.png")
	if tex_enemy_cultist == null:
		tex_enemy_cultist = _safe_load_tex("res://assets/textures/enemy_knight.png")
	tex_boss_malgorath = _safe_load_tex("res://assets/textures/boss_malgorath.png")
	tex_boss_amalgam = _safe_load_tex("res://assets/textures/boss_amalgam.png")
	tex_slash = _safe_load_tex("res://assets/ui/slash_effect.png")
	tex_blood = _safe_load_tex("res://assets/ui/blood_splatter.png")
	
	item_icons["Weapon"] = _safe_load_tex("res://assets/icons/icon_weapon.png")
	item_icons["Armor"] = _safe_load_tex("res://assets/icons/icon_armor.png")
	item_icons["Helmet"] = _safe_load_tex("res://assets/icons/icon_helm.png")
	item_icons["OffHand"] = _safe_load_tex("res://assets/icons/icon_shield.png")
	item_icons["Accessory"] = _safe_load_tex("res://assets/icons/icon_amulet.png")
	
	player_sprite.texture = tex_player_wanderer
	gold_icon.texture = _safe_load_tex("res://assets/ui/gold_coin.png")
	bg_texture.texture = tex_camp_altar

func _apply_ui_theming():
	# Style panels with dark gothic obsidian theme
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.06, 0.05, 0.08, 0.92)
	panel_style.border_color = Color(0.35, 0.28, 0.42, 0.75)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.corner_radius_top_left = 6
	panel_style.corner_radius_top_right = 6
	panel_style.corner_radius_bottom_left = 6
	panel_style.corner_radius_bottom_right = 6
	panel_style.content_margin_left = 10
	panel_style.content_margin_top = 10
	panel_style.content_margin_right = 10
	panel_style.content_margin_bottom = 10
	
	var combat_log_panel = $UI/BattleHUD/CombatLogPanel
	if combat_log_panel:
		combat_log_panel.add_theme_stylebox_override("panel", panel_style)
	
	var player_stats_panel = $UI/BattleHUD/PlayerStatsPanel
	if player_stats_panel:
		player_stats_panel.add_theme_stylebox_override("panel", panel_style)
	
	var enemy_stats_panel = $UI/BattleHUD/EnemyStatsPanel
	if enemy_stats_panel:
		enemy_stats_panel.add_theme_stylebox_override("panel", panel_style)
	
	var enemy_desc_panel = $UI/BattleHUD/EnemyDescPanel
	if enemy_desc_panel:
		enemy_desc_panel.add_theme_stylebox_override("panel", panel_style)
	
	var settings_box = $UI/SettingsModal/Panel
	if settings_box:
		var s_style = panel_style.duplicate()
		s_style.bg_color = Color(0.07, 0.06, 0.09, 0.98)
		s_style.border_color = Color(0.6, 0.45, 0.25, 0.85)
		s_style.border_width_left = 2
		s_style.border_width_top = 2
		s_style.border_width_right = 2
		s_style.border_width_bottom = 2
		s_style.content_margin_left = 18
		s_style.content_margin_top = 18
		s_style.content_margin_right = 18
		s_style.content_margin_bottom = 18
		settings_box.add_theme_stylebox_override("panel", s_style)
	
	var defeat_box = $UI/DefeatModal/Panel
	if defeat_box:
		var d_style = panel_style.duplicate()
		d_style.bg_color = Color(0.08, 0.04, 0.05, 0.98)
		d_style.border_color = Color(0.85, 0.2, 0.25, 0.85)
		d_style.border_width_left = 2
		d_style.border_width_top = 2
		d_style.border_width_right = 2
		d_style.border_width_bottom = 2
		defeat_box.add_theme_stylebox_override("panel", d_style)
	
	_style_hp_bar(player_hp_bar, Color(0.18, 0.65, 0.35, 1.0))
	_style_hp_bar(enemy_hp_bar, Color(0.85, 0.22, 0.22, 1.0))

func _style_hp_bar(bar: ProgressBar, fill_color: Color):
	if bar == null:
		return
	var bg_box = StyleBoxFlat.new()
	bg_box.bg_color = Color(0.04, 0.03, 0.05, 0.85)
	bg_box.border_color = Color(0.3, 0.25, 0.35, 0.8)
	bg_box.border_width_left = 1
	bg_box.border_width_top = 1
	bg_box.border_width_right = 1
	bg_box.border_width_bottom = 1
	bg_box.corner_radius_top_left = 4
	bg_box.corner_radius_top_right = 4
	bg_box.corner_radius_bottom_left = 4
	bg_box.corner_radius_bottom_right = 4
	
	var fill_box = StyleBoxFlat.new()
	fill_box.bg_color = fill_color
	fill_box.corner_radius_top_left = 4
	fill_box.corner_radius_top_right = 4
	fill_box.corner_radius_bottom_left = 4
	fill_box.corner_radius_bottom_right = 4
	
	bar.add_theme_stylebox_override("background", bg_box)
	bar.add_theme_stylebox_override("fill", fill_box)

func _init_localization_and_settings():
	var lang = save_manager.get_language()
	if localization != null:
		localization.set_language(lang)
	
	var m_vol = save_manager.get_master_volume()
	var s_vol = save_manager.get_sfx_volume()
	var bgm_vol = save_manager.get_music_volume()
	var is_fs = save_manager.get_fullscreen()
	
	slider_master.value = m_vol * 100.0
	val_master.text = "%d%%" % int(slider_master.value)
	slider_sfx.value = s_vol * 100.0
	val_sfx.text = "%d%%" % int(slider_sfx.value)
	slider_music.value = bgm_vol * 100.0
	val_music.text = "%d%%" % int(slider_music.value)
	check_fullscreen.button_pressed = is_fs
	
	sound_manager.set_master_volume(m_vol)
	sound_manager.set_sfx_volume(s_vol)
	sound_manager.set_music_volume(bgm_vol)
	
	if is_fs:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	
	_update_localized_texts()

func _process(delta: float):
	if settings_modal != null and settings_modal.visible:
		return
	
	# Idle breathing animations anchored around -180.0
	var time = Time.get_ticks_msec() / 1000.0
	player_sprite.position.y = -180.0 + sin(time * 2.5) * 6.0
	enemy_sprite.position.y = -180.0 + cos(time * 2.8) * 7.0
	
	if state == GameState.BATTLE:
		_process_battle_loop(delta)

func _process_battle_loop(delta: float):
	if enemy_data.is_empty() or player_stats.is_empty():
		return
	
	# Cooldown decrements
	player_attack_cooldown -= delta
	enemy_attack_cooldown -= delta
	
	if player_attack_cooldown <= 0.0:
		_execute_player_attack()
		var p_spd = max(0.2, float(player_stats.get("attack_speed", 1.0)))
		player_attack_cooldown = 1.0 / p_spd
	
	if enemy_data.get("current_health", 0) > 0 and enemy_attack_cooldown <= 0.0:
		_execute_enemy_attack()
		var e_spd = max(0.2, float(enemy_data.get("attack_speed", 1.0)))
		enemy_attack_cooldown = 1.0 / e_spd

# ==============================================================================
# SETTINGS & LOCALIZATION HANDLING
# ==============================================================================

func _toggle_settings_modal():
	settings_modal.visible = not settings_modal.visible
	if settings_modal.visible:
		sound_manager.play_click()

func _on_settings_pressed():
	sound_manager.play_click()
	settings_modal.visible = true

func _on_close_settings_pressed():
	sound_manager.play_click()
	settings_modal.visible = false

func _on_test_sound_pressed():
	sound_manager.play_test_sound()

func _on_toggle_lang_pressed():
	sound_manager.play_click()
	var cur = localization.current_language if localization else "ru"
	var next_lang = "en" if cur == "ru" else "ru"
	save_manager.set_language(next_lang)
	if localization != null:
		localization.set_language(next_lang)

func _on_language_changed(_new_lang: String):
	_update_localized_texts()
	if state == GameState.CAMP:
		_refresh_camp_ui()
	elif state == GameState.BATTLE:
		_update_hud()
		_refresh_equipped_icons()
	elif state == GameState.DRAFT:
		_refresh_draft_ui()
	elif state == GameState.DEFEAT:
		_refresh_defeat_ui()

func _update_localized_texts():
	var cur = localization.current_language if localization else "ru"
	btn_lang_quick.text = "🌐 " + ("ENG" if cur == "en" else "РУС")
	btn_toggle_lang.text = "🇬🇧 English" if cur == "en" else "🇷🇺 Русский"
	
	btn_settings.text = localization.get_string("btn_settings")
	settings_title.text = localization.get_string("settings_title")
	lbl_master_vol.text = localization.get_string("master_volume")
	lbl_sfx_vol.text = localization.get_string("sfx_volume")
	lbl_music_vol.text = localization.get_string("music_volume")
	lbl_language.text = localization.get_string("language")
	check_fullscreen.text = localization.get_string("fullscreen")
	btn_test_sound.text = localization.get_string("test_sfx")
	btn_close_settings.text = localization.get_string("btn_close")
	
	camp_title.text = localization.get_string("camp_title")
	camp_subtitle.text = localization.get_string("camp_subtitle")
	btn_ascend.text = localization.get_string("btn_ascend")
	
	combat_log_header.text = localization.get_string("combat_log_header")
	player_name_label.text = localization.get_string("player_label")
	
	draft_subtitle.text = localization.get_string("draft_subtitle")
	draft_gear_header.text = localization.get_string("draft_current_gear")
	
	defeat_title.text = localization.get_string("defeat_title")
	btn_return_altar.text = localization.get_string("btn_return_altar")
	
	if gold_label != null and save_manager != null and save_manager.save_data != null:
		gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]

func _on_master_slider_changed(val: float):
	val_master.text = "%d%%" % int(val)
	var linear = val / 100.0
	save_manager.set_master_volume(linear)
	sound_manager.set_master_volume(linear)

func _on_sfx_slider_changed(val: float):
	val_sfx.text = "%d%%" % int(val)
	var linear = val / 100.0
	save_manager.set_sfx_volume(linear)
	sound_manager.set_sfx_volume(linear)

func _on_music_slider_changed(val: float):
	val_music.text = "%d%%" % int(val)
	var linear = val / 100.0
	save_manager.set_music_volume(linear)
	sound_manager.set_music_volume(linear)

func _on_fullscreen_toggled(button_pressed: bool):
	save_manager.set_fullscreen(button_pressed)
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# ==============================================================================
# STATE TRANSITIONS
# ==============================================================================

func _enter_camp_state():
	state = GameState.CAMP
	bg_texture.texture = tex_camp_altar
	camp_panel.visible = true
	draft_modal.visible = false
	defeat_modal.visible = false
	battle_hud.visible = false
	top_hud.visible = true
	$Arena.visible = false
	
	floor_banner.text = ""
	_refresh_camp_ui()

func _refresh_camp_ui():
	var gold = save_manager.save_data.get("PersistentGold", 0)
	var max_floor = save_manager.save_data.get("HighestFloorReached", 1)
	altar_gold_label.text = localization.get_string("camp_gold_record") % [gold, max_floor]
	gold_label.text = "%d %s" % [gold, localization.get_string("gold_unit")]
	
	# Populate upgrade items
	for child in upgrades_container.get_children():
		upgrades_container.remove_child(child)
		child.queue_free()
	
	for upg in game_data.meta_upgrades:
		var type_name = upg.get("type", "")
		var rank = save_manager.get_upgrade_rank(type_name)
		var base_cost = int(upg.get("baseCost", 50))
		var cost = base_cost * (rank + 1)
		
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(700, 60)
		
		var p_style = StyleBoxFlat.new()
		p_style.bg_color = Color(0.08, 0.06, 0.10, 0.88)
		p_style.border_color = Color(0.35, 0.28, 0.40, 0.6)
		p_style.border_width_left = 1
		p_style.border_width_top = 1
		p_style.border_width_right = 1
		p_style.border_width_bottom = 1
		p_style.corner_radius_top_left = 6
		p_style.corner_radius_top_right = 6
		p_style.corner_radius_bottom_left = 6
		p_style.corner_radius_bottom_right = 6
		p_style.content_margin_left = 14
		p_style.content_margin_top = 8
		p_style.content_margin_right = 14
		p_style.content_margin_bottom = 8
		panel.add_theme_stylebox_override("panel", p_style)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 16)
		panel.add_child(hbox)
		
		var upg_name = localization.get_upgrade_name(type_name, upg.get("name", ""))
		var upg_bonus = localization.get_upgrade_bonus(type_name, upg.get("statBonus", ""))
		var upg_desc = localization.get_upgrade_description(type_name, upg.get("description", ""))
		
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)
		
		var lbl_title = Label.new()
		lbl_title.text = "%s  [%s %d] — %s" % [upg_name, localization.get_string("rank"), rank, upg_bonus]
		lbl_title.add_theme_font_size_override("font_size", 14)
		lbl_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.4))
		info_vbox.add_child(lbl_title)
		
		var lbl_desc = Label.new()
		lbl_desc.text = upg_desc
		lbl_desc.add_theme_font_size_override("font_size", 11)
		lbl_desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
		info_vbox.add_child(lbl_desc)
		
		var btn_upg = Button.new()
		btn_upg.custom_minimum_size = Vector2(170, 38)
		btn_upg.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn_upg.text = localization.get_string("upgrade_btn") % cost
		btn_upg.disabled = (gold < cost)
		btn_upg.pressed.connect(func(): _on_buy_upgrade(type_name, cost))
		hbox.add_child(btn_upg)
		
		upgrades_container.add_child(panel)

func _on_buy_upgrade(type_name: String, cost: int):
	if save_manager.spend_gold(cost):
		save_manager.increment_upgrade_rank(type_name)
		sound_manager.play_coin()
		_calculate_player_stats()
		_refresh_camp_ui()

func _on_ascend_pressed():
	sound_manager.play_click()
	current_floor = 1
	run_gold_earned = 0
	equipped_items.clear()
	_calculate_player_stats()
	_start_floor_battle()

func _start_floor_battle():
	state = GameState.BATTLE
	bg_texture.texture = tex_spire_interior
	camp_panel.visible = false
	draft_modal.visible = false
	defeat_modal.visible = false
	battle_hud.visible = true
	top_hud.visible = true
	$Arena.visible = true
	
	player_anchor.position = player_base_pos
	enemy_anchor.position = enemy_base_pos
	player_sprite.modulate = Color(1, 1, 1, 1)
	enemy_sprite.modulate = Color(1, 1, 1, 1)
	
	enemy_data = game_data.get_enemy_for_floor(current_floor)
	_setup_enemy_visuals()
	
	# Attack timers
	player_attack_cooldown = 0.5
	enemy_attack_cooldown = 1.0
	
	# HUD Setup
	var is_boss = enemy_data.get("isBoss", false)
	var e_name = localization.get_enemy_name(enemy_data.get("id", ""), enemy_data.get("name", ""))
	if is_boss:
		floor_banner.text = localization.get_string("boss_floor_banner") % [current_floor, e_name.to_upper()]
	else:
		floor_banner.text = localization.get_string("floor_banner") % [current_floor, e_name.to_upper()]
	
	gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]
	
	player_name_label.text = localization.get_string("player_label")
	enemy_name_label.text = e_name
	
	_update_hud()
	_refresh_equipped_icons()
	_log("[color=#c0a060]%s[/color]" % [localization.get_string("log_floor_entered") % [current_floor, e_name]])

func _setup_enemy_visuals():
	var enemy_id = enemy_data.get("id", "")
	var is_boss = enemy_data.get("isBoss", false)
	
	if is_boss:
		if current_floor >= 20:
			enemy_sprite.texture = tex_boss_amalgam
			enemy_sprite.scale = Vector2(0.95, 0.95)
		else:
			enemy_sprite.texture = tex_boss_malgorath
			enemy_sprite.scale = Vector2(1.0, 1.0)
	elif enemy_id == "feeble_skeleton" or current_floor == 1:
		enemy_sprite.texture = tex_enemy_skeleton
		enemy_sprite.scale = Vector2(0.85, 0.85)
	elif enemy_id == "spire_imp" or current_floor <= 4:
		enemy_sprite.texture = tex_enemy_imp
		enemy_sprite.scale = Vector2(0.8, 0.8)
	elif enemy_id == "hollow_knight" or current_floor >= 5:
		enemy_sprite.texture = tex_enemy_knight
		enemy_sprite.scale = Vector2(0.85, 0.85)
	else:
		enemy_sprite.texture = tex_enemy_skeleton
		enemy_sprite.scale = Vector2(0.85, 0.85)
	
	enemy_sprite.modulate = Color(1, 1, 1, 1)

# ==============================================================================
# COMBAT EXECUTION
# ==============================================================================

func _execute_player_attack():
	# Lunge animation
	var tw = create_tween()
	tw.tween_property(player_anchor, "position:x", player_base_pos.x + 80, 0.08)
	tw.tween_property(player_anchor, "position:x", player_base_pos.x, 0.12)
	
	sound_manager.play_slash()
	_spawn_fx_slash(enemy_anchor.position + Vector2(0, -100))
	
	var res = game_data.calculate_damage(player_stats, enemy_data)
	var e_name = localization.get_enemy_name(enemy_data.get("id", ""), enemy_data.get("name", "Enemy"))
	if res.dodged:
		_spawn_floating_text(enemy_anchor.position + Vector2(0, -140), localization.get_string("float_dodge"), Color(0.4, 0.8, 1.0))
		_log(localization.get_string("log_enemy_dodge") % e_name)
		return
	
	var dmg = res.damage
	var is_crit = res.is_crit
	var lifesteal = res.lifesteal
	
	enemy_data["current_health"] = max(0, enemy_data["current_health"] - dmg)
	
	# Visual hit response
	_shake_node(enemy_anchor, 8.0 if is_crit else 4.0)
	_flash_node(enemy_sprite, Color(2, 0.5, 0.5, 1))
	_spawn_blood_burst(enemy_anchor.position + Vector2(0, -100))
	
	if is_crit:
		sound_manager.play_crit()
		_spawn_floating_text(enemy_anchor.position + Vector2(0, -140), localization.get_string("float_crit") % dmg, Color(1.0, 0.85, 0.1), 1.4)
		_log(localization.get_string("log_player_crit") % [e_name, dmg])
	else:
		sound_manager.play_hit()
		_spawn_floating_text(enemy_anchor.position + Vector2(0, -140), "-%d" % dmg, Color(1.0, 0.4, 0.4))
		_log(localization.get_string("log_player_hit") % [e_name, dmg])
	
	if lifesteal > 0:
		player_stats["current_health"] = min(player_stats["max_health"], player_stats["current_health"] + lifesteal)
		_spawn_floating_text(player_anchor.position + Vector2(0, -140), localization.get_string("float_hp") % lifesteal, Color(0.3, 1.0, 0.4))
	
	_update_hud()
	
	if enemy_data["current_health"] <= 0:
		_on_enemy_defeated()

func _execute_enemy_attack():
	# Enemy lunges
	var tw = create_tween()
	tw.tween_property(enemy_anchor, "position:x", enemy_base_pos.x - 80, 0.08)
	tw.tween_property(enemy_anchor, "position:x", enemy_base_pos.x, 0.12)
	
	sound_manager.play_slash()
	_spawn_fx_slash(player_anchor.position + Vector2(0, -100), true)
	
	var res = game_data.calculate_damage(enemy_data, player_stats)
	var e_name = localization.get_enemy_name(enemy_data.get("id", ""), enemy_data.get("name", "Enemy"))
	if res.dodged:
		_spawn_floating_text(player_anchor.position + Vector2(0, -140), localization.get_string("float_dodge"), Color(0.4, 0.8, 1.0))
		_log(localization.get_string("log_player_dodge") % e_name)
		return
	
	var dmg = res.damage
	player_stats["current_health"] = max(0, player_stats["current_health"] - dmg)
	
	_shake_node(player_anchor, 6.0)
	_flash_node(player_sprite, Color(2, 0.4, 0.4, 1))
	_spawn_blood_burst(player_anchor.position + Vector2(0, -100))
	sound_manager.play_hit()
	
	_spawn_floating_text(player_anchor.position + Vector2(0, -140), "-%d" % dmg, Color(1.0, 0.2, 0.2))
	_log(localization.get_string("log_enemy_hit") % [e_name, dmg])
	
	_update_hud()
	
	if player_stats["current_health"] <= 0:
		_on_player_perished()

func _on_enemy_defeated():
	sound_manager.play_coin()
	var base_gold = int(enemy_data.get("gold_reward", 15))
	var gold_mult = float(player_stats.get("gold_multiplier", 1.0))
	var total_gold = int(round(base_gold * gold_mult))
	
	run_gold_earned += total_gold
	save_manager.add_gold(total_gold)
	save_manager.record_run_completion(current_floor)
	gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]
	
	var e_name = localization.get_enemy_name(enemy_data.get("id", ""), enemy_data.get("name", ""))
	_log(localization.get_string("log_enemy_defeated") % [e_name, total_gold])
	
	# Death fade of enemy
	var tw = create_tween()
	tw.tween_property(enemy_sprite, "modulate:a", 0.0, 0.4)
	tw.tween_callback(_enter_draft_state)

func _on_player_perished():
	sound_manager.play_death()
	_log(localization.get_string("log_player_died"))
	
	# Player dissolution
	var tw = create_tween()
	tw.tween_property(player_sprite, "modulate", Color(0.2, 0.05, 0.05, 0.0), 0.6)
	tw.tween_callback(_enter_defeat_state)

# ==============================================================================
# DRAFT MODAL (REWARD CHOICES)
# ==============================================================================

func _enter_draft_state():
	state = GameState.DRAFT
	# HIDE combat UI completely to prevent overlaps!
	battle_hud.visible = false
	top_hud.visible = true
	$Arena.visible = false
	defeat_modal.visible = false
	draft_modal.visible = true
	floor_banner.text = ""
	gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]
	current_draft_items = game_data.get_random_items(3, current_floor)
	_refresh_draft_ui()

func _refresh_draft_ui():
	draft_title.text = localization.get_string("draft_title") % current_floor
	draft_subtitle.text = localization.get_string("draft_subtitle")
	draft_gear_header.text = localization.get_string("draft_current_gear")
	
	# Populate current equipped items row for reference
	for child in draft_gear_bar.get_children():
		draft_gear_bar.remove_child(child)
		child.queue_free()
	
	for slot in ["Weapon", "Armor", "Helmet", "OffHand", "Accessory"]:
		var itm = equipped_items.get(slot, null)
		var slot_box = PanelContainer.new()
		slot_box.custom_minimum_size = Vector2(160, 42)
		
		var b_style = StyleBoxFlat.new()
		b_style.bg_color = Color(0.06, 0.05, 0.08, 0.9)
		b_style.border_color = _get_rarity_color(itm.get("rarity", "Common")) if itm else Color(0.25, 0.22, 0.3)
		b_style.border_width_left = 1
		b_style.border_width_top = 1
		b_style.border_width_right = 1
		b_style.border_width_bottom = 1
		b_style.corner_radius_top_left = 4
		b_style.corner_radius_top_right = 4
		b_style.corner_radius_bottom_left = 4
		b_style.corner_radius_bottom_right = 4
		slot_box.add_theme_stylebox_override("panel", b_style)
		
		var h = HBoxContainer.new()
		h.add_theme_constant_override("separation", 6)
		slot_box.add_child(h)
		
		var icon_tex = item_icons.get(slot, null)
		if icon_tex:
			var tr = TextureRect.new()
			tr.texture = icon_tex
			tr.custom_minimum_size = Vector2(28, 28)
			tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			if itm:
				tr.modulate = _get_rarity_color(itm.get("rarity", "Common"))
			else:
				tr.modulate = Color(0.4, 0.4, 0.45, 0.5)
			h.add_child(tr)
		
		var lbl = Label.new()
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl.add_theme_font_size_override("font_size", 11)
		var slot_disp = localization.get_slot_name(slot)
		if itm:
			var itm_disp = localization.get_item_name(itm)
			lbl.text = "%s:\n%s" % [slot_disp, itm_disp]
			lbl.add_theme_color_override("font_color", _get_rarity_color(itm.get("rarity", "Common")))
		else:
			lbl.text = "%s:\n[%s]" % [slot_disp, localization.get_string("slot_empty_hint")]
			lbl.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
		h.add_child(lbl)
		
		draft_gear_bar.add_child(slot_box)
	
	# Populate 3 draft cards
	for child in draft_cards_container.get_children():
		draft_cards_container.remove_child(child)
		child.queue_free()
	
	if current_draft_items.is_empty():
		current_draft_items = game_data.get_random_items(3, current_floor)
	
	for item in current_draft_items:
		var card = _create_draft_card(item)
		draft_cards_container.add_child(card)

func _create_draft_card(item: Dictionary) -> Control:
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(280, 420)
	
	var slot = item.get("slot", "Weapon")
	var rarity = item.get("rarity", "Common")
	var rarity_color = _get_rarity_color(rarity)
	
	# Card Styled Background
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.08, 0.07, 0.11, 0.98)
	card_style.border_color = rarity_color
	card_style.border_width_left = 2
	card_style.border_width_top = 2
	card_style.border_width_right = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left = 8
	card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8
	card_style.corner_radius_bottom_right = 8
	card_style.content_margin_left = 14
	card_style.content_margin_top = 12
	card_style.content_margin_right = 14
	card_style.content_margin_bottom = 14
	container.add_theme_stylebox_override("panel", card_style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	container.add_child(vbox)
	
	# Rarity & Slot Header
	var rarity_disp = localization.get_rarity_name(rarity).to_upper()
	var slot_disp = localization.get_slot_name(slot).to_upper()
	var lbl_slot = Label.new()
	lbl_slot.text = "[ %s • %s ]" % [rarity_disp, slot_disp]
	lbl_slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_slot.modulate = rarity_color
	lbl_slot.add_theme_font_size_override("font_size", 12)
	vbox.add_child(lbl_slot)
	
	# Icon Frame
	var icon_box = PanelContainer.new()
	icon_box.custom_minimum_size = Vector2(80, 80)
	icon_box.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var icon_style = StyleBoxFlat.new()
	icon_style.bg_color = Color(0.04, 0.03, 0.05, 0.9)
	icon_style.border_color = rarity_color.lerp(Color(0.2, 0.2, 0.2), 0.4)
	icon_style.border_width_left = 1
	icon_style.border_width_top = 1
	icon_style.border_width_right = 1
	icon_style.border_width_bottom = 1
	icon_style.corner_radius_top_left = 6
	icon_style.corner_radius_top_right = 6
	icon_style.corner_radius_bottom_left = 6
	icon_style.corner_radius_bottom_right = 6
	icon_box.add_theme_stylebox_override("panel", icon_style)
	
	var icon_tex = item_icons.get(slot, null)
	if icon_tex:
		var tex_rect = TextureRect.new()
		tex_rect.texture = icon_tex
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.custom_minimum_size = Vector2(68, 68)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.modulate = rarity_color
		icon_box.add_child(tex_rect)
	vbox.add_child(icon_box)
	
	# Name
	var itm_name = localization.get_item_name(item)
	var lbl_name = Label.new()
	lbl_name.text = itm_name
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_name.add_theme_font_size_override("font_size", 15)
	lbl_name.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85))
	vbox.add_child(lbl_name)
	
	# Description
	var itm_desc = localization.get_item_description(item)
	var lbl_desc = Label.new()
	lbl_desc.text = itm_desc
	lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.modulate = Color(0.72, 0.72, 0.78, 1)
	lbl_desc.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_desc)
	
	# Stats breakdown
	var stats_text = ""
	var s = item.get("stats", {})
	for k in s.keys():
		var val = s[k]
		stats_text += localization.format_stat(k, val) + "\n"
	
	var lbl_stats = Label.new()
	lbl_stats.text = stats_text.strip_edges()
	lbl_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_stats.modulate = Color(0.35, 0.95, 0.55, 1)
	lbl_stats.add_theme_font_size_override("font_size", 12)
	vbox.add_child(lbl_stats)
	
	# Slot Replacement Info
	var cur_equipped = equipped_items.get(slot, null)
	var lbl_replace = Label.new()
	lbl_replace.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_replace.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_replace.add_theme_font_size_override("font_size", 11)
	if cur_equipped:
		var cur_name = localization.get_item_name(cur_equipped)
		lbl_replace.text = localization.get_string("replaces_slot") % cur_name
		lbl_replace.add_theme_color_override("font_color", Color(1.0, 0.65, 0.35))
	else:
		lbl_replace.text = "[ %s ]" % localization.get_string("slot_empty_hint")
		lbl_replace.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
	vbox.add_child(lbl_replace)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	var btn_select = Button.new()
	btn_select.text = localization.get_string("equip_relic")
	btn_select.custom_minimum_size = Vector2(0, 40)
	btn_select.add_theme_font_size_override("font_size", 13)
	btn_select.pressed.connect(func(): _on_item_drafted(item))
	vbox.add_child(btn_select)
	
	return container

func _get_rarity_color(rarity: String) -> Color:
	match rarity:
		"Common": return Color(0.85, 0.85, 0.88)
		"Uncommon": return Color(0.3, 0.88, 0.45)
		"Rare": return Color(0.35, 0.65, 1.0)
		"Epic": return Color(0.8, 0.4, 0.98)
		"Legendary": return Color(1.0, 0.78, 0.2)
		"Cursed": return Color(0.95, 0.25, 0.35)
		_: return Color(0.85, 0.85, 0.88)

func _on_item_drafted(item: Dictionary):
	current_draft_items.clear()
	sound_manager.play_equip()
	var slot = item.get("slot", "Weapon")
	equipped_items[slot] = item
	
	current_floor += 1
	_calculate_player_stats()
	
	# Moderate heal between floors (25% max HP)
	var max_hp = player_stats.get("max_health", 100)
	var heal_amt = int(round(max_hp * 0.25))
	player_stats["current_health"] = min(max_hp, player_stats.get("current_health", max_hp) + heal_amt)
	
	var itm_name = localization.get_item_name(item)
	var slot_name = localization.get_slot_name(slot)
	_log(localization.get_string("log_equipped") % [itm_name, slot_name])
	_log(localization.get_string("log_heal_boon") % heal_amt)
	
	_start_floor_battle()

# ==============================================================================
# DEFEAT MODAL
# ==============================================================================

func _enter_defeat_state():
	state = GameState.DEFEAT
	# HIDE combat UI completely!
	battle_hud.visible = false
	top_hud.visible = true
	$Arena.visible = false
	draft_modal.visible = false
	defeat_modal.visible = true
	floor_banner.text = ""
	gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]
	_refresh_defeat_ui()

func _refresh_defeat_ui():
	var gold = save_manager.save_data.get("PersistentGold", 0)
	var max_floor = save_manager.save_data.get("HighestFloorReached", 1)
	defeat_title.text = localization.get_string("defeat_title")
	defeat_summary_label.text = localization.get_string("defeat_summary") % [current_floor, max_floor, run_gold_earned, gold]
	btn_return_altar.text = localization.get_string("btn_return_altar")

func _on_return_altar_pressed():
	sound_manager.play_click()
	current_floor = 1
	run_gold_earned = 0
	equipped_items.clear()
	_calculate_player_stats()
	_enter_camp_state()

# ==============================================================================
# STAT CALCULATIONS & PERSISTENCE
# ==============================================================================

func _calculate_player_stats():
	var hp_rank = save_manager.get_upgrade_rank("Health")
	var dmg_rank = save_manager.get_upgrade_rank("Damage")
	var arm_rank = save_manager.get_upgrade_rank("Armor")
	var spd_rank = save_manager.get_upgrade_rank("AttackSpeed")
	var crit_rank = save_manager.get_upgrade_rank("CritChance")
	var ls_rank = save_manager.get_upgrade_rank("Lifesteal")
	var gold_rank = save_manager.get_upgrade_rank("GoldMultiplier")
	
	var max_hp = 100 + (hp_rank * 12)
	var dmg = 12 + int(dmg_rank * 2.5)
	var arm = 5 + int(arm_rank * 2.0)
	var spd = 1.0 + (spd_rank * 0.05)
	var crit = 0.05 + (crit_rank * 0.01)
	var crit_mult = 1.5
	var ls = 0.0 + (ls_rank * 0.01)
	var dodge = 0.0
	var gold_mult = 1.0 + (gold_rank * 0.08)
	
	# Add equipment bonuses
	for slot in equipped_items.keys():
		var itm = equipped_items[slot]
		var s = itm.get("stats", {})
		max_hp += int(s.get("MaxHealth", 0))
		dmg += int(s.get("AttackDamage", 0))
		arm += int(s.get("Armor", 0))
		spd += float(s.get("AttackSpeed", 0.0))
		crit += float(s.get("CritChance", 0.0))
		crit_mult += float(s.get("CritMultiplier", 0.0))
		ls += float(s.get("Lifesteal", 0.0))
		dodge += float(s.get("DodgeChance", 0.0))
	
	var cur_hp = player_stats.get("current_health", max_hp)
	cur_hp = min(max_hp, cur_hp)
	if current_floor == 1 or state == GameState.CAMP:
		cur_hp = max_hp
	
	player_stats = {
		"max_health": max_hp,
		"current_health": cur_hp,
		"attack_damage": dmg,
		"armor": arm,
		"attack_speed": spd,
		"crit_chance": crit,
		"crit_multiplier": crit_mult,
		"lifesteal": ls,
		"dodge_chance": dodge,
		"gold_multiplier": gold_mult
	}

func _update_hud():
	if player_stats.is_empty() or enemy_data.is_empty():
		return
	
	var is_boss = enemy_data.get("isBoss", false)
	var e_name = localization.get_enemy_name(enemy_data.get("id", ""), enemy_data.get("name", ""))
	if is_boss:
		floor_banner.text = localization.get_string("boss_floor_banner") % [current_floor, e_name.to_upper()]
	else:
		floor_banner.text = localization.get_string("floor_banner") % [current_floor, e_name.to_upper()]
	
	gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]
	enemy_name_label.text = e_name
	player_name_label.text = localization.get_string("player_label")
	
	var p_cur = player_stats.get("current_health", 0)
	var p_max = player_stats.get("max_health", 100)
	player_hp_bar.max_value = p_max
	player_hp_bar.value = p_cur
	player_hp_label.text = "%d / %d %s" % [p_cur, p_max, localization.get_string("hp_unit", "HP")]
	
	var p_dmg = player_stats.get("attack_damage", 0)
	var p_arm = player_stats.get("armor", 0)
	var p_spd = player_stats.get("attack_speed", 1.0)
	var p_crit = int(round(player_stats.get("crit_chance", 0.05) * 100))
	var p_crit_m = player_stats.get("crit_multiplier", 1.5)
	var p_ls = int(round(player_stats.get("lifesteal", 0.0) * 100))
	var p_dg = int(round(player_stats.get("dodge_chance", 0.0) * 100))
	
	player_stats_label.text = localization.get_string("player_stats_fmt") % [
		p_dmg, p_arm, p_spd, p_crit, p_crit_m, p_ls, p_dg
	]
	
	var e_cur = enemy_data.get("current_health", 0)
	var e_max = enemy_data.get("max_health", 100)
	enemy_hp_bar.max_value = e_max
	enemy_hp_bar.value = e_cur
	enemy_hp_label.text = "%d / %d %s" % [e_cur, e_max, localization.get_string("hp_unit", "HP")]
	
	var e_dmg = enemy_data.get("attack_damage", 0)
	var e_arm = enemy_data.get("armor", 0)
	var e_spd = enemy_data.get("attack_speed", 1.0)
	var e_gold = enemy_data.get("gold_reward", 15)
	
	enemy_stats_label.text = localization.get_string("enemy_stats_fmt") % [
		e_dmg, e_arm, e_spd, e_gold
	]
	
	var e_id = enemy_data.get("id", "")
	enemy_desc_label.text = localization.get_enemy_description(e_id, enemy_data.get("description", ""))

func _refresh_equipped_icons():
	for child in equip_icons_container.get_children():
		equip_icons_container.remove_child(child)
		child.queue_free()
	
	for slot in ["Weapon", "Armor", "Helmet", "OffHand", "Accessory"]:
		var itm = equipped_items.get(slot, null)
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(48, 48)
		
		var b_style = StyleBoxFlat.new()
		b_style.bg_color = Color(0.06, 0.05, 0.08, 0.9)
		b_style.border_color = _get_rarity_color(itm.get("rarity", "Common")) if itm else Color(0.28, 0.24, 0.35, 0.7)
		b_style.border_width_left = 1
		b_style.border_width_top = 1
		b_style.border_width_right = 1
		b_style.border_width_bottom = 1
		b_style.corner_radius_top_left = 4
		b_style.corner_radius_top_right = 4
		b_style.corner_radius_bottom_left = 4
		b_style.corner_radius_bottom_right = 4
		slot_panel.add_theme_stylebox_override("panel", b_style)
		
		var tex_rect = TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(40, 40)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		var slot_disp = localization.get_slot_name(slot)
		if itm:
			tex_rect.texture = item_icons.get(slot, null)
			tex_rect.modulate = _get_rarity_color(itm.get("rarity", "Common"))
			var itm_name = localization.get_item_name(itm)
			var itm_desc = localization.get_item_description(itm)
			slot_panel.tooltip_text = "%s (%s)\n%s" % [itm_name, slot_disp, itm_desc]
		else:
			tex_rect.texture = item_icons.get(slot, null)
			tex_rect.modulate = Color(0.3, 0.3, 0.35, 0.35)
			slot_panel.tooltip_text = localization.get_string("empty_slot_tooltip") % slot_disp
		
		slot_panel.add_child(tex_rect)
		equip_icons_container.add_child(slot_panel)

# ==============================================================================
# VISUAL EFFECTS (SHAKE, FLASH, FLOATING NUMBERS, PARTICLES)
# ==============================================================================

func _shake_node(node: Node2D, intensity: float):
	var orig = player_base_pos if node == player_anchor else (enemy_base_pos if node == enemy_anchor else node.position)
	var tw = create_tween()
	for i in range(4):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tw.tween_property(node, "position", orig + offset, 0.03)
	tw.tween_property(node, "position", orig, 0.03)

func _flash_node(sprite: CanvasItem, color: Color):
	var orig = sprite.modulate
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", color, 0.05)
	tw.tween_property(sprite, "modulate", orig, 0.15)

func _spawn_fx_slash(pos: Vector2, flipped: bool = false):
	var s = Sprite2D.new()
	s.texture = tex_slash
	s.position = pos
	s.scale = Vector2(1.2, 1.2)
	s.flip_h = flipped
	s.modulate = Color(1.5, 1.2, 0.8, 1.0)
	fx_layer.add_child(s)
	
	var tw = create_tween()
	tw.tween_property(s, "scale", Vector2(1.8, 1.8), 0.15)
	tw.parallel().tween_property(s, "modulate:a", 0.0, 0.15)
	tw.tween_callback(s.queue_free)

func _spawn_blood_burst(pos: Vector2):
	for i in range(3):
		var s = Sprite2D.new()
		s.texture = tex_blood
		s.position = pos + Vector2(randf_range(-30, 30), randf_range(-30, 30))
		s.scale = Vector2(randf_range(0.4, 0.7), randf_range(0.4, 0.7))
		s.rotation = randf_range(0, TAU)
		fx_layer.add_child(s)
		
		var target_pos = s.position + Vector2(randf_range(-40, 40), randf_range(20, 60))
		var tw = create_tween()
		tw.tween_property(s, "position", target_pos, 0.3)
		tw.parallel().tween_property(s, "modulate:a", 0.0, 0.35)
		tw.tween_callback(s.queue_free)

func _spawn_floating_text(pos: Vector2, text: String, color: Color, scale_mult: float = 1.0):
	var lbl = Label.new()
	lbl.text = text
	lbl.position = pos + Vector2(randf_range(-20, 20), randf_range(-10, 10))
	lbl.modulate = color
	lbl.add_theme_font_size_override("font_size", int(20 * scale_mult))
	fx_layer.add_child(lbl)
	
	var tw = create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y - 50, 0.6).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.6)
	tw.tween_callback(lbl.queue_free)

func _log(bbcode: String):
	combat_log.append_text(bbcode + "\n")
	var v_scroll = combat_log.get_v_scroll_bar()
	if v_scroll:
		v_scroll.value = v_scroll.max_value
