extends Node2D

enum GameState { CAMP, BATTLE, DRAFT, DEFEAT, MENU, COMPENDIUM }

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
var combat_speed: float = 1.0 # 1.0, 1.5, 2.0
var player_soul: float = 0.0 # 0.0 to 100.0 (Soul Cleave ability)
var is_traversing: bool = false

var player_base_pos: Vector2 = Vector2(490, 480)
var enemy_base_pos: Vector2 = Vector2(790, 480)
var player_combo_step: int = 0
var is_hitstopped: bool = false

# Textures
var tex_spire_interior: Texture2D
var tex_camp_altar: Texture2D
var tex_player_wanderer: Texture2D
var tex_enemy_skeleton: Texture2D
var tex_enemy_imp: Texture2D
var tex_enemy_knight: Texture2D
var tex_enemy_ghoul: Texture2D
var tex_enemy_cultist: Texture2D
var tex_enemy_shade: Texture2D
var tex_enemy_executioner: Texture2D
var tex_enemy_inquisitor: Texture2D
var tex_enemy_crypt_lich: Texture2D
var tex_enemy_infernal_colossus: Texture2D
var tex_enemy_obsidian_gargoyle: Texture2D
var tex_enemy_plague_abomination: Texture2D
var tex_enemy_void_stalker: Texture2D
var tex_boss_malgorath: Texture2D
var tex_boss_amalgam: Texture2D
var tex_boss_valthor: Texture2D
var tex_slash: Texture2D
var tex_blood: Texture2D
var tex_archway: Texture2D
var tex_chest: Texture2D
var tex_parry_spark: Texture2D
var tex_heavy_slash: Texture2D
var tex_ground_shadow: Texture2D

var tex_gear_weapons: Dictionary = {}
var tex_gear_helms: Dictionary = {}
var tex_gear_armors: Dictionary = {}
var tex_gear_offhands: Dictionary = {}

var item_icons: Dictionary = {}

# Dynamic Modular Rig Nodes
var player_shadow: CanvasItem
var armor_overlay: Sprite2D
var helm_overlay: Sprite2D
var offhand_anchor: Marker2D
var offhand_sprite: Sprite2D
var weapon_anchor: Marker2D
var weapon_sprite: Sprite2D
var accessory_aura: Node2D
var walk_dust: CPUParticles2D

var enemy_shadow: CanvasItem
var telegraph_glow: Polygon2D
var enemy_walk_dust: CPUParticles2D
var archway_sprite: Sprite2D
var chest_sprite: Sprite2D

# Dynamic UI Additions
var soul_bar: ProgressBar
var soul_label: Label
var speed_btn: Button
var room_clear_banner: PanelContainer
var room_clear_label: Label
var btn_skip_draft: Button
var main_menu_modal: Control
var compendium_modal: Control

# Rebirth 3D & Squad Controller
var rebirth_3d: Node = null
var party_members: Dictionary = {}
var party_hud_container: VBoxContainer = null
var party_hp_bars: Dictionary = {}
var party_labels: Dictionary = {}
var party_modal: Control = null
var chest_modal: Control = null
var chest_btn_thief: Button = null

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
	player_base_pos = Vector2(490, 480)
	enemy_base_pos = Vector2(790, 480)
	player_anchor.position = player_base_pos
	enemy_anchor.position = enemy_base_pos
	
	_init_rebirth_party()
	_init_rebirth_3d()
	_build_modular_rigs()
	_build_enhanced_ui()
	_build_party_hud()
	_build_party_modal()
	_build_chest_modal()
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
	if main_menu_modal != null:
		main_menu_modal.visible = true

func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if compendium_modal != null and compendium_modal.visible:
				compendium_modal.visible = false
			elif main_menu_modal != null and main_menu_modal.visible:
				main_menu_modal.visible = false
			else:
				_toggle_settings_modal()

func _load_textures():
	tex_spire_interior = _safe_load_tex("res://assets/textures/spire_interior.png")
	tex_camp_altar = _safe_load_tex("res://assets/textures/camp_altar.png")
	tex_player_wanderer = _safe_load_tex("res://assets/textures/player_wanderer.png")
	tex_enemy_skeleton = _safe_load_tex("res://assets/textures/enemy_skeleton.png")
	tex_enemy_imp = _safe_load_tex("res://assets/textures/enemy_imp.png")
	tex_enemy_knight = _safe_load_tex("res://assets/textures/enemy_knight.png")
	tex_enemy_ghoul = _safe_load_tex("res://assets/textures/enemy_ghoul.png")
	tex_enemy_cultist = _safe_load_tex("res://assets/textures/enemy_cultist.png")
	tex_enemy_shade = _safe_load_tex("res://assets/textures/enemy_shade.png")
	tex_enemy_executioner = _safe_load_tex("res://assets/textures/enemy_executioner.png")
	tex_enemy_inquisitor = _safe_load_tex("res://assets/textures/enemy_inquisitor.png")
	tex_enemy_crypt_lich = _safe_load_tex("res://assets/textures/enemy_crypt_lich.png")
	tex_enemy_infernal_colossus = _safe_load_tex("res://assets/textures/enemy_infernal_colossus.png")
	tex_enemy_obsidian_gargoyle = _safe_load_tex("res://assets/textures/enemy_obsidian_gargoyle.png")
	tex_enemy_plague_abomination = _safe_load_tex("res://assets/textures/enemy_plague_abomination.png")
	tex_enemy_void_stalker = _safe_load_tex("res://assets/textures/enemy_void_stalker.png")
	tex_boss_malgorath = _safe_load_tex("res://assets/textures/boss_malgorath.png")
	tex_boss_amalgam = _safe_load_tex("res://assets/textures/boss_amalgam.png")
	tex_boss_valthor = _safe_load_tex("res://assets/textures/boss_valthor.png")
	tex_slash = _safe_load_tex("res://assets/ui/slash_effect.png")
	tex_blood = _safe_load_tex("res://assets/ui/blood_splatter.png")
	tex_archway = _safe_load_tex("res://assets/ui/dungeon_archway.png")
	tex_chest = _safe_load_tex("res://assets/ui/treasure_chest.png")
	tex_parry_spark = _safe_load_tex("res://assets/ui/parry_spark.png")
	tex_heavy_slash = _safe_load_tex("res://assets/ui/heavy_slash_arc.png")
	tex_ground_shadow = _safe_load_tex("res://assets/ui/ground_shadow_ellipse.png")
	
	# Modular Gear Textures
	tex_gear_weapons["cleaver"] = _safe_load_tex("res://assets/gear/weapon_cleaver.png")
	tex_gear_weapons["axe"] = _safe_load_tex("res://assets/gear/weapon_axe.png")
	tex_gear_weapons["scythe"] = _safe_load_tex("res://assets/gear/weapon_scythe.png")
	tex_gear_weapons["greatsword"] = _safe_load_tex("res://assets/gear/weapon_greatsword.png")
	tex_gear_weapons["dagger"] = _safe_load_tex("res://assets/gear/weapon_dagger.png")
	tex_gear_weapons["mace"] = _safe_load_tex("res://assets/gear/weapon_mace.png")
	
	tex_gear_helms["sallet"] = _safe_load_tex("res://assets/gear/helm_sallet.png")
	tex_gear_helms["crown_thorns"] = _safe_load_tex("res://assets/gear/helm_crown_thorns.png")
	tex_gear_helms["hood"] = _safe_load_tex("res://assets/gear/helm_hood.png")
	tex_gear_helms["inquisitor"] = _safe_load_tex("res://assets/gear/helm_inquisitor.png")
	
	tex_gear_armors["carapace"] = _safe_load_tex("res://assets/gear/armor_carapace.png")
	tex_gear_armors["cuirass"] = _safe_load_tex("res://assets/gear/armor_cuirass.png")
	tex_gear_armors["robes"] = _safe_load_tex("res://assets/gear/armor_robes.png")
	
	tex_gear_offhands["weeping"] = _safe_load_tex("res://assets/gear/offhand_weeping.png")
	tex_gear_offhands["grimoire"] = _safe_load_tex("res://assets/gear/offhand_grimoire.png")
	tex_gear_offhands["buckler"] = _safe_load_tex("res://assets/gear/offhand_buckler.png")
	
	# Slot Icons
	item_icons["Weapon"] = _safe_load_tex("res://assets/icons/icon_weapon.png")
	item_icons["Armor"] = _safe_load_tex("res://assets/icons/icon_armor.png")
	item_icons["Helmet"] = _safe_load_tex("res://assets/icons/icon_helm.png")
	item_icons["OffHand"] = _safe_load_tex("res://assets/icons/icon_shield.png")
	item_icons["Accessory"] = _safe_load_tex("res://assets/icons/icon_amulet.png")
	
	player_sprite.texture = tex_player_wanderer
	gold_icon.texture = _safe_load_tex("res://assets/ui/gold_coin.png")
	bg_texture.texture = tex_camp_altar

func _build_modular_rigs():
	# 1. Dungeon Props in Arena
	var arena = $Arena
	archway_sprite = Sprite2D.new()
	archway_sprite.texture = tex_archway
	archway_sprite.position = Vector2(1180, 390)
	archway_sprite.scale = Vector2(0.85, 0.85)
	archway_sprite.z_index = -1
	arena.add_child(archway_sprite)
	
	chest_sprite = Sprite2D.new()
	chest_sprite.texture = tex_chest
	chest_sprite.position = Vector2(640, 480)
	chest_sprite.scale = Vector2(0.85, 0.85)
	chest_sprite.visible = false
	arena.add_child(chest_sprite)
	
	# 2. Player Rig Additions
	if tex_ground_shadow != null:
		var p_sh = Sprite2D.new()
		p_sh.texture = tex_ground_shadow
		p_sh.position = Vector2(0, 5)
		p_sh.scale = Vector2(0.55, 0.45)
		p_sh.modulate = Color(0.04, 0.02, 0.05, 0.75)
		player_shadow = p_sh
	else:
		var p_poly = Polygon2D.new()
		var s_pts = PackedVector2Array()
		for i in range(16):
			var ang = float(i) / 16.0 * TAU
			s_pts.append(Vector2(cos(ang) * 55.0, sin(ang) * 14.0))
		p_poly.polygon = s_pts
		p_poly.color = Color(0.02, 0.01, 0.03, 0.55)
		p_poly.position = Vector2(0, 5)
		player_shadow = p_poly
	player_anchor.add_child(player_shadow)
	player_anchor.move_child(player_shadow, 0)
	
	accessory_aura = Node2D.new()
	accessory_aura.position = Vector2(0, -170)
	accessory_aura.visible = false
	player_anchor.add_child(accessory_aura)
	for i in range(3):
		var mote = Polygon2D.new()
		var m_pts = PackedVector2Array([Vector2(-4, -4), Vector2(4, -4), Vector2(4, 4), Vector2(-4, 4)])
		mote.polygon = m_pts
		mote.color = Color(1.0, 0.4, 0.5, 0.9)
		var rad = float(i) / 3.0 * TAU
		mote.position = Vector2(cos(rad) * 45.0, sin(rad) * 45.0)
		accessory_aura.add_child(mote)
	
	armor_overlay = Sprite2D.new()
	armor_overlay.position = Vector2(0, -165)
	armor_overlay.scale = Vector2(0.50, 0.50)
	armor_overlay.visible = false
	player_anchor.add_child(armor_overlay)
	
	helm_overlay = Sprite2D.new()
	helm_overlay.position = Vector2(0, -265)
	helm_overlay.scale = Vector2(0.48, 0.48)
	helm_overlay.visible = false
	player_anchor.add_child(helm_overlay)
	
	offhand_anchor = Marker2D.new()
	offhand_anchor.position = Vector2(-35, -160)
	player_anchor.add_child(offhand_anchor)
	
	offhand_sprite = Sprite2D.new()
	offhand_sprite.scale = Vector2(0.45, 0.45)
	offhand_sprite.visible = false
	offhand_anchor.add_child(offhand_sprite)
	
	weapon_anchor = Marker2D.new()
	weapon_anchor.position = Vector2(30, -155)
	player_anchor.add_child(weapon_anchor)
	
	weapon_sprite = Sprite2D.new()
	weapon_sprite.position = Vector2(10, -45)
	weapon_sprite.scale = Vector2(0.55, 0.55)
	weapon_sprite.visible = false
	weapon_anchor.add_child(weapon_sprite)
	
	walk_dust = CPUParticles2D.new()
	walk_dust.position = Vector2(0, 5)
	walk_dust.emitting = false
	walk_dust.amount = 12
	walk_dust.lifetime = 0.45
	walk_dust.direction = Vector2(-1, -0.3)
	walk_dust.spread = 35.0
	walk_dust.initial_velocity_min = 20.0
	walk_dust.initial_velocity_max = 50.0
	walk_dust.gravity = Vector2(0, 15)
	walk_dust.scale_amount_min = 2.5
	walk_dust.scale_amount_max = 5.0
	walk_dust.color = Color(0.4, 0.35, 0.3, 0.4)
	player_anchor.add_child(walk_dust)
	
	# 3. Enemy Rig Additions
	if tex_ground_shadow != null:
		var e_sh = Sprite2D.new()
		e_sh.texture = tex_ground_shadow
		e_sh.position = Vector2(0, 5)
		e_sh.scale = Vector2(0.55, 0.45)
		e_sh.modulate = Color(0.04, 0.02, 0.05, 0.75)
		enemy_shadow = e_sh
	else:
		var e_poly = Polygon2D.new()
		var e_pts = PackedVector2Array()
		for i in range(16):
			var ang = float(i) / 16.0 * TAU
			e_pts.append(Vector2(cos(ang) * 55.0, sin(ang) * 14.0))
		e_poly.polygon = e_pts
		e_poly.color = Color(0.02, 0.01, 0.03, 0.55)
		e_poly.position = Vector2(0, 5)
		enemy_shadow = e_poly
	enemy_anchor.add_child(enemy_shadow)
	enemy_anchor.move_child(enemy_shadow, 0)
	
	telegraph_glow = Polygon2D.new()
	var t_pts = PackedVector2Array([Vector2(-15, -4), Vector2(15, -4), Vector2(0, 12)])
	telegraph_glow.polygon = t_pts
	telegraph_glow.color = Color(1.0, 0.2, 0.2, 0.9)
	telegraph_glow.position = Vector2(0, -260)
	telegraph_glow.visible = false
	enemy_anchor.add_child(telegraph_glow)
	
	enemy_walk_dust = CPUParticles2D.new()
	enemy_walk_dust.position = Vector2(0, 5)
	enemy_walk_dust.emitting = false
	enemy_walk_dust.amount = 10
	enemy_walk_dust.lifetime = 0.4
	enemy_walk_dust.direction = Vector2(1, -0.3)
	enemy_walk_dust.spread = 35.0
	enemy_walk_dust.initial_velocity_min = 20.0
	enemy_walk_dust.initial_velocity_max = 45.0
	enemy_walk_dust.gravity = Vector2(0, 15)
	enemy_walk_dust.scale_amount_min = 2.0
	enemy_walk_dust.scale_amount_max = 4.5
	enemy_walk_dust.color = Color(0.4, 0.35, 0.3, 0.4)
	enemy_anchor.add_child(enemy_walk_dust)

func _build_enhanced_ui():
	# 1. Soul Cleave Bar in BattleHUD
	soul_bar = ProgressBar.new()
	soul_bar.custom_minimum_size = Vector2(320, 14)
	soul_bar.position = Vector2(40, 518)
	soul_bar.max_value = 100.0
	soul_bar.value = 0.0
	soul_bar.show_percentage = false
	
	var sb_bg = StyleBoxFlat.new()
	sb_bg.bg_color = Color(0.04, 0.03, 0.06, 0.9)
	sb_bg.border_color = Color(0.3, 0.15, 0.4, 0.8)
	sb_bg.border_width_left = 1
	sb_bg.border_width_top = 1
	sb_bg.border_width_right = 1
	sb_bg.border_width_bottom = 1
	sb_bg.corner_radius_top_left = 3
	sb_bg.corner_radius_top_right = 3
	sb_bg.corner_radius_bottom_left = 3
	sb_bg.corner_radius_bottom_right = 3
	
	var sb_fill = StyleBoxFlat.new()
	sb_fill.bg_color = Color(0.75, 0.25, 0.95, 1.0)
	sb_fill.corner_radius_top_left = 3
	sb_fill.corner_radius_top_right = 3
	sb_fill.corner_radius_bottom_left = 3
	sb_fill.corner_radius_bottom_right = 3
	
	soul_bar.add_theme_stylebox_override("background", sb_bg)
	soul_bar.add_theme_stylebox_override("fill", sb_fill)
	battle_hud.add_child(soul_bar)
	
	soul_label = Label.new()
	soul_label.position = Vector2(40, 517)
	soul_label.custom_minimum_size = Vector2(320, 14)
	soul_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	soul_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	soul_label.add_theme_font_size_override("font_size", 10)
	soul_label.add_theme_color_override("font_color", Color(1.0, 0.9, 1.0))
	soul_label.text = "⚡ ДУША: 0%"
	battle_hud.add_child(soul_label)
	
	# 2. Combat Speed Toggle Button & Pause Menu Button in BattleHUD
	speed_btn = Button.new()
	speed_btn.custom_minimum_size = Vector2(100, 34)
	speed_btn.position = Vector2(1140, 68)
	speed_btn.text = "⏩ 1.0x"
	speed_btn.add_theme_font_size_override("font_size", 12)
	speed_btn.pressed.connect(_on_toggle_speed_pressed)
	battle_hud.add_child(speed_btn)
	
	var btn_battle_menu = Button.new()
	btn_battle_menu.custom_minimum_size = Vector2(100, 34)
	btn_battle_menu.position = Vector2(1030, 68)
	btn_battle_menu.text = "⏸ МЕНЮ"
	btn_battle_menu.add_theme_font_size_override("font_size", 12)
	btn_battle_menu.pressed.connect(_toggle_settings_modal)
	battle_hud.add_child(btn_battle_menu)
	
	# 3. Room Clear Banner
	room_clear_banner = PanelContainer.new()
	room_clear_banner.custom_minimum_size = Vector2(420, 54)
	room_clear_banner.position = Vector2(430, 160)
	room_clear_banner.visible = false
	var r_style = StyleBoxFlat.new()
	r_style.bg_color = Color(0.08, 0.06, 0.12, 0.95)
	r_style.border_color = Color(1.0, 0.8, 0.25, 0.9)
	r_style.border_width_left = 2
	r_style.border_width_top = 2
	r_style.border_width_right = 2
	r_style.border_width_bottom = 2
	r_style.corner_radius_top_left = 8
	r_style.corner_radius_top_right = 8
	r_style.corner_radius_bottom_left = 8
	r_style.corner_radius_bottom_right = 8
	room_clear_banner.add_theme_stylebox_override("panel", r_style)
	
	room_clear_label = Label.new()
	room_clear_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_clear_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	room_clear_label.add_theme_font_size_override("font_size", 20)
	room_clear_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	room_clear_label.text = "⚔ КОМНАТА ОЧИЩЕНА! ⚔"
	room_clear_banner.add_child(room_clear_label)
	battle_hud.add_child(room_clear_banner)
	
	# 4. Skip & Salvage Button in DraftModal (below cards container)
	var draft_vbox = $UI/DraftModal/VBox
	var skip_center = CenterContainer.new()
	draft_vbox.add_child(skip_center)
	
	var skip_vbox = VBoxContainer.new()
	skip_vbox.add_theme_constant_override("separation", 4)
	skip_center.add_child(skip_vbox)
	
	btn_skip_draft = Button.new()
	btn_skip_draft.custom_minimum_size = Vector2(420, 46)
	btn_skip_draft.text = "💰 ПРОПУСТИТЬ И ПЕРЕПЛАВИТЬ (+30 ЗОЛ.)"
	btn_skip_draft.add_theme_font_size_override("font_size", 14)
	btn_skip_draft.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	btn_skip_draft.pressed.connect(_on_skip_draft_pressed)
	skip_vbox.add_child(btn_skip_draft)
	
	var lbl_skip_hint = Label.new()
	lbl_skip_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_skip_hint.add_theme_font_size_override("font_size", 11)
	lbl_skip_hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	lbl_skip_hint.text = "Оставить текущее снаряжение без изменений и забрать чистое золото."
	skip_vbox.add_child(lbl_skip_hint)
	
	# 5. Camp Navigation & Buttons
	var camp_vbox = $UI/CampPanel/VBox
	var camp_nav_hbox = HBoxContainer.new()
	camp_nav_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	camp_nav_hbox.add_theme_constant_override("separation", 10)
	camp_vbox.add_child(camp_nav_hbox)
	
	var btn_camp_party = Button.new()
	btn_camp_party.custom_minimum_size = Vector2(200, 36)
	btn_camp_party.text = "👥 СПУТНИКИ (4)"
	btn_camp_party.add_theme_font_size_override("font_size", 12)
	btn_camp_party.pressed.connect(_open_party_modal)
	camp_nav_hbox.add_child(btn_camp_party)
	
	var btn_camp_compendium = Button.new()
	btn_camp_compendium.custom_minimum_size = Vector2(200, 36)
	btn_camp_compendium.text = "📖 БЕСТИАРИЙ"
	btn_camp_compendium.add_theme_font_size_override("font_size", 12)
	btn_camp_compendium.pressed.connect(_open_compendium)
	camp_nav_hbox.add_child(btn_camp_compendium)
	
	var btn_camp_menu = Button.new()
	btn_camp_menu.custom_minimum_size = Vector2(410, 30)
	btn_camp_menu.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_camp_menu.text = "🏛 ГЛАВНОЕ МЕНЮ"
	btn_camp_menu.add_theme_font_size_override("font_size", 12)
	btn_camp_menu.pressed.connect(_open_main_menu)
	camp_vbox.add_child(btn_camp_menu)
	
	# 6. TopHUD Menu Button
	var left_ctrls = $UI/TopHUD/LeftControls
	var btn_top_menu = Button.new()
	btn_top_menu.custom_minimum_size = Vector2(100, 36)
	btn_top_menu.text = "🏛 МЕНЮ"
	btn_top_menu.add_theme_font_size_override("font_size", 13)
	btn_top_menu.pressed.connect(_open_main_menu)
	left_ctrls.add_child(btn_top_menu)
	left_ctrls.move_child(btn_top_menu, 0)
	
	# 7. Gothic Main Menu Modal
	_build_main_menu_modal()
	
	# 8. Bestiary & Armory Compendium Modal
	_build_compendium_modal()

func _build_main_menu_modal():
	main_menu_modal = Control.new()
	main_menu_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_menu_modal.visible = false
	
	var dimmer = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.02, 0.015, 0.03, 0.98)
	main_menu_modal.add_child(dimmer)
	
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_menu_modal.add_child(center)
	
	var menu_panel = PanelContainer.new()
	menu_panel.custom_minimum_size = Vector2(520, 480)
	var m_style = StyleBoxFlat.new()
	m_style.bg_color = Color(0.07, 0.05, 0.09, 0.98)
	m_style.border_color = Color(0.8, 0.65, 0.3, 0.9)
	m_style.border_width_left = 2
	m_style.border_width_top = 2
	m_style.border_width_right = 2
	m_style.border_width_bottom = 2
	m_style.corner_radius_top_left = 8
	m_style.corner_radius_top_right = 8
	m_style.corner_radius_bottom_left = 8
	m_style.corner_radius_bottom_right = 8
	m_style.content_margin_left = 24
	m_style.content_margin_top = 24
	m_style.content_margin_right = 24
	m_style.content_margin_bottom = 24
	menu_panel.add_theme_stylebox_override("panel", m_style)
	center.add_child(menu_panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	menu_panel.add_child(vbox)
	
	var title = Label.new()
	title.text = "GRIMSPIRE: ASCENT OF THE CURSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title)
	
	var subtitle = Label.new()
	subtitle.text = "Мрачный Автобатлер • Восхождение Проклятого"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 13)
	subtitle.add_theme_color_override("font_color", Color(0.8, 0.75, 0.85))
	vbox.add_child(subtitle)
	
	var sep = HSeparator.new()
	vbox.add_child(sep)
	
	var b_ascend = Button.new()
	b_ascend.text = "⚔ НАЧАТЬ ВОСХОЖДЕНИЕ"
	b_ascend.custom_minimum_size = Vector2(0, 48)
	b_ascend.add_theme_font_size_override("font_size", 15)
	b_ascend.pressed.connect(func():
		main_menu_modal.visible = false
		_on_ascend_pressed()
	)
	vbox.add_child(b_ascend)
	
	var b_camp = Button.new()
	b_camp.text = "🩸 КРОВАВЫЙ АЛТАРЬ (ЛАГЕРЬ)"
	b_camp.custom_minimum_size = Vector2(0, 44)
	b_camp.add_theme_font_size_override("font_size", 14)
	b_camp.pressed.connect(func():
		main_menu_modal.visible = false
		_enter_camp_state()
	)
	vbox.add_child(b_camp)
	
	var b_comp = Button.new()
	b_comp.text = "📖 БЕСТИАРИЙ И АРСЕНАЛ"
	b_comp.custom_minimum_size = Vector2(0, 44)
	b_comp.add_theme_font_size_override("font_size", 14)
	b_comp.pressed.connect(func():
		main_menu_modal.visible = false
		_open_compendium()
	)
	vbox.add_child(b_comp)
	
	var b_settings = Button.new()
	b_settings.text = "⚙ НАСТРОЙКИ"
	b_settings.custom_minimum_size = Vector2(0, 44)
	b_settings.add_theme_font_size_override("font_size", 14)
	b_settings.pressed.connect(func():
		_toggle_settings_modal()
	)
	vbox.add_child(b_settings)
	
	var b_quit = Button.new()
	b_quit.text = "🚪 ВЫХОД ИЗ ИГРЫ"
	b_quit.custom_minimum_size = Vector2(0, 40)
	b_quit.add_theme_font_size_override("font_size", 13)
	b_quit.pressed.connect(func(): get_tree().quit())
	vbox.add_child(b_quit)
	
	ui_canvas.add_child(main_menu_modal)

func _build_compendium_modal():
	compendium_modal = Control.new()
	compendium_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	compendium_modal.visible = false
	
	var dimmer = ColorRect.new()
	dimmer.set_anchors_preset(Control.PRESET_FULL_RECT)
	dimmer.color = Color(0.02, 0.015, 0.03, 0.96)
	compendium_modal.add_child(dimmer)
	
	var panel = PanelContainer.new()
	panel.offset_left = 60.0
	panel.offset_top = 40.0
	panel.offset_right = 1220.0
	panel.offset_bottom = 680.0
	
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.07, 0.05, 0.09, 0.98)
	p_style.border_color = Color(0.8, 0.65, 0.3, 0.9)
	p_style.border_width_left = 2
	p_style.border_width_top = 2
	p_style.border_width_right = 2
	p_style.border_width_bottom = 2
	p_style.corner_radius_top_left = 8
	p_style.corner_radius_top_right = 8
	p_style.corner_radius_bottom_left = 8
	p_style.corner_radius_bottom_right = 8
	p_style.content_margin_left = 20
	p_style.content_margin_top = 18
	p_style.content_margin_right = 20
	p_style.content_margin_bottom = 18
	panel.add_theme_stylebox_override("panel", p_style)
	compendium_modal.add_child(panel)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)
	
	var header_hbox = HBoxContainer.new()
	vbox.add_child(header_hbox)
	
	var title = Label.new()
	title.text = "📖 БЕСТИАРИЙ И АРСЕНАЛ ШПИЛЯ"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	header_hbox.add_child(title)
	
	var btn_close = Button.new()
	btn_close.text = "✖ ЗАКРЫТЬ"
	btn_close.custom_minimum_size = Vector2(120, 36)
	btn_close.pressed.connect(func(): compendium_modal.visible = false)
	header_hbox.add_child(btn_close)
	
	var tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(tabs)
	
	# Tab 1: Enemies
	var scroll_en = ScrollContainer.new()
	scroll_en.name = "💀 Монстры Шпиля (16)"
	var grid_en = GridContainer.new()
	grid_en.columns = 2
	grid_en.add_theme_constant_override("h_separation", 14)
	grid_en.add_theme_constant_override("v_separation", 14)
	grid_en.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_en.add_child(grid_en)
	tabs.add_child(scroll_en)
	
	for e in game_data.enemies:
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(510, 80)
		var c_box = HBoxContainer.new()
		c_box.add_theme_constant_override("separation", 12)
		card.add_child(c_box)
		
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(64, 64)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var e_id = e.get("id", "")
		icon.texture = _get_enemy_texture_for_id(e_id)
		c_box.add_child(icon)
		
		var info = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c_box.add_child(info)
		
		var e_name = localization.get_enemy_name(e_id, e.get("name", ""))
		var lbl_t = Label.new()
		lbl_t.text = "%s [%s]" % [e_name, e.get("tier", "")]
		lbl_t.add_theme_font_size_override("font_size", 13)
		lbl_t.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4) if e.get("isBoss") else Color(1.0, 0.9, 0.7))
		info.add_child(lbl_t)
		
		var st = e.get("stats", {})
		var lbl_s = Label.new()
		lbl_s.text = "ОЗ: %d | Урон: %d | Броня: %d | Скор.: %.2f" % [
			st.get("MaxHealth", 50), st.get("AttackDamage", 10), st.get("Armor", 0), st.get("AttackSpeed", 1.0)
		]
		lbl_s.add_theme_font_size_override("font_size", 10)
		lbl_s.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
		info.add_child(lbl_s)
		
		var lbl_d = Label.new()
		lbl_d.text = localization.get_enemy_description(e_id, e.get("description", ""))
		lbl_d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_d.add_theme_font_size_override("font_size", 10)
		lbl_d.add_theme_color_override("font_color", Color(0.65, 0.65, 0.7))
		info.add_child(lbl_d)
		
		grid_en.add_child(card)
	
	# Tab 2: Items
	var scroll_it = ScrollContainer.new()
	scroll_it.name = "🗡 Реликвии и Арсенал (32)"
	var grid_it = GridContainer.new()
	grid_it.columns = 2
	grid_it.add_theme_constant_override("h_separation", 14)
	grid_it.add_theme_constant_override("v_separation", 14)
	grid_it.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_it.add_child(grid_it)
	tabs.add_child(scroll_it)
	
	for itm in game_data.items:
		var card = PanelContainer.new()
		card.custom_minimum_size = Vector2(510, 80)
		var c_box = HBoxContainer.new()
		c_box.add_theme_constant_override("separation", 12)
		card.add_child(c_box)
		
		var slot = itm.get("slot", "Weapon")
		var rarity = itm.get("rarity", "Common")
		var r_color = _get_rarity_color(rarity)
		
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(64, 64)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = item_icons.get(slot, null)
		icon.modulate = r_color
		c_box.add_child(icon)
		
		var info = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		c_box.add_child(info)
		
		var itm_name = localization.get_item_name(itm)
		var slot_disp = localization.get_slot_name(slot)
		var rar_disp = localization.get_rarity_name(rarity)
		var lbl_t = Label.new()
		lbl_t.text = "%s  [%s • %s]" % [itm_name, rar_disp, slot_disp]
		lbl_t.add_theme_font_size_override("font_size", 13)
		lbl_t.add_theme_color_override("font_color", r_color)
		info.add_child(lbl_t)
		
		var s_text = ""
		var s_dict = itm.get("stats", {})
		for k in s_dict.keys():
			s_text += localization.format_stat(k, s_dict[k]) + "  "
		var lbl_s = Label.new()
		lbl_s.text = s_text.strip_edges()
		lbl_s.add_theme_font_size_override("font_size", 10)
		lbl_s.add_theme_color_override("font_color", Color(0.4, 0.95, 0.6))
		info.add_child(lbl_s)
		
		var lbl_d = Label.new()
		lbl_d.text = localization.get_item_description(itm)
		lbl_d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_d.add_theme_font_size_override("font_size", 10)
		lbl_d.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
		info.add_child(lbl_d)
		
		grid_it.add_child(card)
	
	ui_canvas.add_child(compendium_modal)

# ==============================================================================
# REBIRTH 3D & SQUAD PARTY MANAGEMENT
# ==============================================================================

func _init_rebirth_party():
	party_members = {
		"bulwark": {
			"id": "bulwark", "name": "The Bulwark", "role": "Tank", "role_title": "ТАНК",
			"unlocked": true, "active": true,
			"max_hp": 220, "current_hp": 220, "armor": 28, "damage": 16, "speed": 0.75,
			"taunt_timer": 0.0, "taunt_cooldown": 7.5, "cooldown": 0.0
		},
		"wanderer": {
			"id": "wanderer", "name": "The Wanderer", "role": "Hero", "role_title": "ГЕРОЙ",
			"unlocked": true, "active": true,
			"max_hp": 120, "current_hp": 120, "armor": 8, "damage": 20, "speed": 1.0,
			"soul_gauge": 0.0, "cooldown": 0.0
		},
		"nightshade": {
			"id": "nightshade", "name": "The Nightshade", "role": "Thief", "role_title": "ВОР",
			"unlocked": true, "active": true,
			"max_hp": 100, "current_hp": 100, "armor": 6, "damage": 28, "speed": 1.45,
			"crit_chance": 0.38, "crit_multiplier": 2.2, "backstab_cooldown": 5.5, "cooldown": 0.0
		},
		"bloodweaver": {
			"id": "bloodweaver", "name": "The Bloodweaver", "role": "Cleric", "role_title": "ХИЛЕР",
			"unlocked": true, "active": true,
			"max_hp": 95, "current_hp": 95, "armor": 8, "damage": 15, "speed": 0.9,
			"heal_cooldown": 6.5, "cooldown": 0.0
		}
	}
	if save_manager:
		for role in party_members:
			var st = save_manager.get_companion_state(role)
			party_members[role]["unlocked"] = st.get("unlocked", true)
			party_members[role]["active"] = st.get("active", true)

func _init_rebirth_3d():
	var script = load("res://scripts/Rebirth3DManager.gd")
	if script:
		rebirth_3d = script.new()
		add_child(rebirth_3d)
		rebirth_3d.setup_3d_world(self)
		for role in party_members:
			rebirth_3d.set_companion_active(role, party_members[role]["active"])
		bg_texture.visible = false
		ground_shadow.visible = false
		player_anchor.visible = false
		enemy_anchor.visible = false
		player_sprite.visible = false
		enemy_sprite.visible = false
		if archway_sprite: archway_sprite.visible = false
		if chest_sprite: chest_sprite.visible = false

func _build_party_hud():
	if battle_hud == null: return
	party_hud_container = VBoxContainer.new()
	party_hud_container.position = Vector2(32, 475)
	party_hud_container.custom_minimum_size = Vector2(330, 115)
	party_hud_container.add_theme_constant_override("separation", 3)
	battle_hud.add_child(party_hud_container)

	if player_hp_bar:
		player_hp_bar.visible = false

	if equip_icons_container:
		equip_icons_container.position = Vector2(32, 598)
	var stats_p = battle_hud.get_node_or_null("PlayerStatsPanel")
	if stats_p:
		stats_p.position = Vector2(32, 646)
		stats_p.custom_minimum_size = Vector2(330, 48)

	var roles = [
		{"id": "bulwark", "icon": "🛡", "col": Color(0.3, 0.7, 1.0)},
		{"id": "wanderer", "icon": "⚔", "col": Color(1.0, 0.85, 0.3)},
		{"id": "nightshade", "icon": "🗡", "col": Color(0.2, 0.9, 0.4)},
		{"id": "bloodweaver", "icon": "🩸", "col": Color(0.9, 0.25, 0.35)}
	]

	for r in roles:
		var r_id = r["id"]
		var row = HBoxContainer.new()
		row.custom_minimum_size = Vector2(320, 22)
		row.add_theme_constant_override("separation", 6)
		party_hud_container.add_child(row)

		var lbl = Label.new()
		lbl.custom_minimum_size = Vector2(140, 20)
		lbl.add_theme_font_size_override("font_size", 11)
		lbl.add_theme_color_override("font_color", r["col"])
		row.add_child(lbl)
		party_labels[r_id] = lbl

		var bar = ProgressBar.new()
		bar.custom_minimum_size = Vector2(170, 16)
		bar.show_percentage = false
		bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		_style_hp_bar(bar, r["col"])
		row.add_child(bar)
		party_hp_bars[r_id] = bar

func _update_party_hud():
	for r_id in party_members:
		var m = party_members[r_id]
		var is_act = m.get("active", true)
		if party_labels.has(r_id) and party_labels[r_id] != null:
			var lbl: Label = party_labels[r_id]
			lbl.visible = is_act
			if r_id == "bulwark":
				lbl.text = "🛡 Танк: %d/%d" % [m["current_hp"], m["max_hp"]]
			elif r_id == "wanderer":
				lbl.text = "⚔ Герой: %d/%d" % [m["current_hp"], m["max_hp"]]
			elif r_id == "nightshade":
				lbl.text = "🗡 Вор: %d/%d" % [m["current_hp"], m["max_hp"]]
			elif r_id == "bloodweaver":
				lbl.text = "🩸 Хилер: %d/%d" % [m["current_hp"], m["max_hp"]]

		if party_hp_bars.has(r_id) and party_hp_bars[r_id] != null:
			var bar: ProgressBar = party_hp_bars[r_id]
			bar.visible = is_act
			bar.max_value = m["max_hp"]
			bar.value = m["current_hp"]

func _build_party_modal():
	party_modal = Control.new()
	party_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	party_modal.visible = false

	var dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.01, 0.03, 0.88)
	party_modal.add_child(dim)

	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(850, 560)
	panel.position = Vector2((1280 - 850) / 2, (720 - 560) / 2)
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.07, 0.06, 0.09, 0.98)
	p_style.border_color = Color(0.7, 0.55, 0.25, 0.9)
	p_style.border_width_left = 2
	p_style.border_width_top = 2
	p_style.border_width_right = 2
	p_style.border_width_bottom = 2
	p_style.corner_radius_top_left = 8
	p_style.corner_radius_top_right = 8
	p_style.corner_radius_bottom_left = 8
	p_style.corner_radius_bottom_right = 8
	p_style.content_margin_left = 20
	p_style.content_margin_top = 16
	p_style.content_margin_right = 20
	p_style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", p_style)
	party_modal.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	panel.add_child(vbox)

	var title = Label.new()
	title.text = localization.get_string("party_title")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	vbox.add_child(title)

	var sub = Label.new()
	sub.text = localization.get_string("party_subtitle")
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size", 12)
	sub.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	vbox.add_child(sub)

	var cards_grid = GridContainer.new()
	cards_grid.columns = 2
	cards_grid.add_theme_constant_override("h_separation", 14)
	cards_grid.add_theme_constant_override("v_separation", 14)
	cards_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(cards_grid)

	var char_data = [
		{"id": "bulwark", "name_key": "party_tank", "desc_key": "party_tank_desc", "col": Color(0.35, 0.75, 1.0)},
		{"id": "wanderer", "name_key": "party_wanderer", "desc_key": "party_wanderer_desc", "col": Color(1.0, 0.88, 0.35)},
		{"id": "nightshade", "name_key": "party_thief", "desc_key": "party_thief_desc", "col": Color(0.25, 0.95, 0.45)},
		{"id": "bloodweaver", "name_key": "party_cleric", "desc_key": "party_cleric_desc", "col": Color(0.95, 0.3, 0.35)}
	]

	for cd in char_data:
		var c_id = cd["id"]
		var c_panel = PanelContainer.new()
		c_panel.custom_minimum_size = Vector2(390, 150)
		var c_style = StyleBoxFlat.new()
		c_style.bg_color = Color(0.10, 0.08, 0.12, 0.9)
		c_style.border_color = cd["col"]
		c_style.border_width_left = 1
		c_style.border_width_top = 1
		c_style.border_width_right = 1
		c_style.border_width_bottom = 1
		c_style.corner_radius_top_left = 6
		c_style.corner_radius_top_right = 6
		c_style.corner_radius_bottom_left = 6
		c_style.corner_radius_bottom_right = 6
		c_style.content_margin_left = 12
		c_style.content_margin_top = 10
		c_style.content_margin_right = 12
		c_style.content_margin_bottom = 10
		c_panel.add_theme_stylebox_override("panel", c_style)
		cards_grid.add_child(c_panel)

		var c_vbox = VBoxContainer.new()
		c_vbox.add_theme_constant_override("separation", 6)
		c_panel.add_child(c_vbox)

		var c_title = Label.new()
		c_title.text = localization.get_string(cd["name_key"])
		c_title.add_theme_font_size_override("font_size", 14)
		c_title.add_theme_color_override("font_color", cd["col"])
		c_vbox.add_child(c_title)

		var c_desc = Label.new()
		c_desc.text = localization.get_string(cd["desc_key"])
		c_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		c_desc.add_theme_font_size_override("font_size", 11)
		c_desc.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
		c_vbox.add_child(c_desc)

		var spacer = Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		c_vbox.add_child(spacer)

		if c_id != "wanderer":
			var btn_toggle = Button.new()
			btn_toggle.custom_minimum_size = Vector2(180, 32)
			var is_act = party_members[c_id].get("active", true)
			btn_toggle.text = "В строю: " + ("ВКЛ ✓" if is_act else "ВЫКЛ ✗")
			btn_toggle.add_theme_font_size_override("font_size", 11)
			btn_toggle.pressed.connect(func():
				var new_state = not party_members[c_id]["active"]
				party_members[c_id]["active"] = new_state
				save_manager.set_companion_active(c_id, new_state)
				btn_toggle.text = "В строю: " + ("ВКЛ ✓" if new_state else "ВЫКЛ ✗")
				if rebirth_3d:
					rebirth_3d.set_companion_active(c_id, new_state)
				sound_manager.play_click()
			)
			c_vbox.add_child(btn_toggle)
		else:
			var lbl_fixed = Label.new()
			lbl_fixed.text = "[Лидер экспедиции • Всегда в строю]"
			lbl_fixed.add_theme_font_size_override("font_size", 11)
			lbl_fixed.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
			c_vbox.add_child(lbl_fixed)

	var btn_close = Button.new()
	btn_close.custom_minimum_size = Vector2(220, 38)
	btn_close.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_close.text = "ЗАКРЫТЬ"
	btn_close.add_theme_font_size_override("font_size", 13)
	btn_close.pressed.connect(func():
		sound_manager.play_click()
		party_modal.visible = false
	)
	vbox.add_child(btn_close)

	ui_canvas.add_child(party_modal)

func _open_party_modal():
	sound_manager.play_click()
	if party_modal:
		party_modal.visible = true

func _build_chest_modal():
	chest_modal = Control.new()
	chest_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	chest_modal.visible = false

	var dim = ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.01, 0.03, 0.85)
	chest_modal.add_child(dim)

	var panel = PanelContainer.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(560, 380)
	panel.position = Vector2((1280 - 560) / 2, (720 - 380) / 2)
	var p_style = StyleBoxFlat.new()
	p_style.bg_color = Color(0.08, 0.06, 0.10, 0.98)
	p_style.border_color = Color(1.0, 0.75, 0.2, 0.9)
	p_style.border_width_left = 2
	p_style.border_width_top = 2
	p_style.border_width_right = 2
	p_style.border_width_bottom = 2
	p_style.corner_radius_top_left = 8
	p_style.corner_radius_top_right = 8
	p_style.corner_radius_bottom_left = 8
	p_style.corner_radius_bottom_right = 8
	p_style.content_margin_left = 24
	p_style.content_margin_top = 20
	p_style.content_margin_right = 24
	p_style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", p_style)
	chest_modal.add_child(panel)

	var vbox = VBoxContainer.new()
	vbox.name = "ChestVBox"
	vbox.add_theme_constant_override("separation", 14)
	panel.add_child(vbox)

	var lbl_title = Label.new()
	lbl_title.name = "ChestTitle"
	lbl_title.text = localization.get_string("chest_title") % current_floor if localization else "СОКРОВИЩНИЦА ЭТАЖА"
	lbl_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_title.add_theme_font_size_override("font_size", 20)
	lbl_title.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	vbox.add_child(lbl_title)

	var lbl_desc = Label.new()
	lbl_desc.name = "ChestDesc"
	lbl_desc.text = localization.get_string("chest_subtitle") if localization else "Отряд наткнулся на кованый готический ларец с рунической печатью."
	lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.add_theme_font_size_override("font_size", 13)
	lbl_desc.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
	vbox.add_child(lbl_desc)

	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var btn_thief = Button.new()
	btn_thief.name = "BtnThiefPick"
	btn_thief.custom_minimum_size = Vector2(500, 48)
	btn_thief.text = localization.get_string("chest_pick_thief") if localization else "🗝 Вор в отряде: Вскрыть отмычками (100% успех!)"
	btn_thief.add_theme_font_size_override("font_size", 14)
	btn_thief.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	btn_thief.pressed.connect(_on_thief_lockpick_pressed)
	vbox.add_child(btn_thief)
	chest_btn_thief = btn_thief

	var btn_force = Button.new()
	btn_force.name = "BtnForceLock"
	btn_force.custom_minimum_size = Vector2(500, 42)
	btn_force.text = localization.get_string("chest_force") if localization else "🔨 Сбить замок оружием (риск 50% сломать лут/ловушка)"
	btn_force.add_theme_font_size_override("font_size", 12)
	btn_force.pressed.connect(_on_force_lock_pressed)
	vbox.add_child(btn_force)

	var btn_leave = Button.new()
	btn_leave.name = "BtnLeaveChest"
	btn_leave.custom_minimum_size = Vector2(500, 38)
	btn_leave.text = localization.get_string("chest_leave") if localization else "🚪 Оставить сундук и идти к лифту"
	btn_leave.add_theme_font_size_override("font_size", 12)
	btn_leave.pressed.connect(_on_leave_chest_pressed)
	vbox.add_child(btn_leave)

	ui_canvas.add_child(chest_modal)

func _show_treasure_chest_modal():
	if chest_modal == null:
		_enter_draft_state()
		return
	
	var has_thief = party_members.get("nightshade", {}).get("active", false)
	if chest_btn_thief != null:
		chest_btn_thief.visible = has_thief
	
	var vbox = chest_modal.get_node_or_null("Panel/ChestVBox")
	if vbox:
		var lbl_t: Label = vbox.get_node_or_null("ChestTitle")
		if lbl_t and localization:
			lbl_t.text = localization.get_string("chest_title") % current_floor
		var lbl_d: Label = vbox.get_node_or_null("ChestDesc")
		if lbl_d and localization:
			lbl_d.text = localization.get_string("chest_subtitle")
	
	chest_modal.visible = true

func _on_thief_lockpick_pressed():
	chest_modal.visible = false
	sound_manager.play_lockpick()
	_enter_draft_state()
	if rebirth_3d:
		rebirth_3d.animate_thief_lockpick(Callable())

func _on_force_lock_pressed():
	chest_modal.visible = false
	sound_manager.play_hit()
	if randf() < 0.5:
		_log("[color=gold]Замок поддался под ударом клинка! Сундук открыт.[/color]")
		_enter_draft_state()
	else:
		sound_manager.play_hit()
		var trap_dmg = 15
		player_stats["current_health"] = max(1, player_stats["current_health"] - trap_dmg)
		_log("[color=crimson]Ловушка! Сработал ядовитый шип (-%d ОЗ).[/color]" % trap_dmg)
		_enter_draft_state()

func _on_leave_chest_pressed():
	chest_modal.visible = false
	current_floor += 1
	_start_floor_battle(true)
	if rebirth_3d:
		sound_manager.play_elevator()
		rebirth_3d.animate_elevator_ascent(Callable())

func _get_enemy_texture_for_id(e_id: String) -> Texture2D:
	match e_id:
		"feeble_skeleton": return tex_enemy_skeleton
		"spire_imp": return tex_enemy_imp
		"crypt_ghoul": return tex_enemy_ghoul if tex_enemy_ghoul else tex_enemy_skeleton
		"tormented_shade": return tex_enemy_shade if tex_enemy_shade else tex_enemy_skeleton
		"hollow_knight": return tex_enemy_knight
		"blood_cultist": return tex_enemy_cultist if tex_enemy_cultist else tex_enemy_knight
		"obsidian_gargoyle": return tex_enemy_obsidian_gargoyle if tex_enemy_obsidian_gargoyle else tex_enemy_knight
		"plague_abomination": return tex_enemy_plague_abomination if tex_enemy_plague_abomination else tex_enemy_ghoul
		"cursed_inquisitor": return tex_enemy_inquisitor if tex_enemy_inquisitor else tex_enemy_cultist
		"spire_executioner": return tex_enemy_executioner if tex_enemy_executioner else tex_enemy_knight
		"crypt_lich": return tex_enemy_crypt_lich if tex_enemy_crypt_lich else tex_enemy_shade
		"void_stalker": return tex_enemy_void_stalker if tex_enemy_void_stalker else tex_enemy_shade
		"infernal_colossus": return tex_enemy_infernal_colossus if tex_enemy_infernal_colossus else tex_enemy_knight
		"boss_gargoyle": return tex_boss_malgorath
		"boss_flesh_amalgam": return tex_boss_amalgam
		"boss_valthor": return tex_boss_valthor if tex_boss_valthor else tex_boss_malgorath
		_: return tex_enemy_skeleton

func _open_main_menu():
	sound_manager.play_click()
	main_menu_modal.visible = true

func _open_compendium():
	sound_manager.play_click()
	compendium_modal.visible = true

func _on_toggle_speed_pressed():
	sound_manager.play_click()
	if combat_speed == 1.0:
		combat_speed = 1.5
	elif combat_speed == 1.5:
		combat_speed = 2.0
	else:
		combat_speed = 1.0
	speed_btn.text = "⏩ %.1fx" % combat_speed

func _apply_ui_theming():
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
	
	var effective_delta = delta * combat_speed
	var time = Time.get_ticks_msec() / 1000.0
	
	# Dynamic breathing and combat stance footsies
	if not is_traversing:
		if state == GameState.BATTLE:
			player_sprite.position.y = -180.0 + sin(time * 3.6) * 5.0
			player_sprite.position.x = sin(time * 1.8) * 3.5
			enemy_sprite.position.y = -180.0 + cos(time * 3.2) * 6.0
			enemy_sprite.position.x = -cos(time * 1.6) * 3.5
		else:
			player_sprite.position.y = -180.0 + sin(time * 2.5) * 6.0
			player_sprite.position.x = 0.0
			enemy_sprite.position.y = -180.0 + cos(time * 2.8) * 7.0
			enemy_sprite.position.x = 0.0
		if armor_overlay.visible:
			armor_overlay.position.y = player_sprite.position.y + 10.0
			armor_overlay.position.x = player_sprite.position.x
		if helm_overlay.visible:
			helm_overlay.position.y = player_sprite.position.y - 70.0
			helm_overlay.position.x = player_sprite.position.x
		if accessory_aura.visible:
			accessory_aura.rotation += effective_delta * 1.5
	
	if state == GameState.BATTLE:
		_process_battle_loop(effective_delta)

func _process_battle_loop(delta: float):
	if enemy_data.is_empty() or player_stats.is_empty() or is_traversing:
		return
	
	# -------------------------------------------------------------
	# 1. Frontline Tank (Bulwark)
	# -------------------------------------------------------------
	if party_members.get("bulwark", {}).get("active", false) and party_members["bulwark"].get("current_hp", 0) > 0:
		var bulwark = party_members["bulwark"]
		bulwark["taunt_timer"] = max(0.0, bulwark.get("taunt_timer", 0.0) - delta)
		bulwark["taunt_cooldown"] = max(0.0, bulwark.get("taunt_cooldown", 0.0) - delta)
		if bulwark["taunt_cooldown"] <= 0.0:
			bulwark["taunt_cooldown"] = 7.5
			bulwark["taunt_timer"] = 4.0
			sound_manager.play_taunt()
			if rebirth_3d:
				rebirth_3d.animate_tank_taunt()
			_spawn_combat_badge(player_anchor.position + Vector2(-60, -220), "🛡 ПРОВОКАЦИЯ / TAUNT", Color(0.1, 0.4, 0.8, 0.95), Color(0.4, 0.8, 1.0, 1.0))
			_log("[color=#4da6ff]🛡 Оплот применяет Провокацию! Удары монстров перенаправлены на щит (-60% урона).[/color]")
		
		bulwark["cooldown"] = max(0.0, bulwark.get("cooldown", 0.0) - delta)
		if enemy_data.get("current_health", 0) > 0 and bulwark["cooldown"] <= 0.0:
			bulwark["cooldown"] = 1.0 / bulwark.get("speed", 0.75)
			if rebirth_3d:
				rebirth_3d.animate_companion_attack("bulwark", Vector3.ZERO, false)
			var t_dmg = bulwark.get("damage", 16)
			enemy_data["current_health"] = max(0, enemy_data["current_health"] - t_dmg)
			_spawn_floating_text(enemy_anchor.position + Vector2(-30, -120), "-%d" % t_dmg, Color(0.4, 0.7, 1.0))
			_update_hud()
			if enemy_data["current_health"] <= 0:
				_on_enemy_defeated()
				return

	# -------------------------------------------------------------
	# 2. Midline Hero (Wanderer)
	# -------------------------------------------------------------
	player_attack_cooldown -= delta
	if player_attack_cooldown <= 0.0:
		if player_soul >= 100.0:
			_execute_player_soul_cleave()
		else:
			_execute_player_attack()
		var p_spd = max(0.2, float(player_stats.get("attack_speed", 1.0)))
		player_attack_cooldown = 1.0 / p_spd
		if enemy_data.get("current_health", 0) <= 0:
			return

	# -------------------------------------------------------------
	# 3. Flank Thief (Nightshade)
	# -------------------------------------------------------------
	if party_members.get("nightshade", {}).get("active", false) and party_members["nightshade"].get("current_hp", 0) > 0:
		var thief = party_members["nightshade"]
		thief["backstab_cooldown"] = max(0.0, thief.get("backstab_cooldown", 0.0) - delta)
		if enemy_data.get("current_health", 0) > 0 and thief["backstab_cooldown"] <= 0.0:
			thief["backstab_cooldown"] = 5.5
			sound_manager.play_backstab()
			if rebirth_3d:
				rebirth_3d.animate_thief_backstab()
			var bs_dmg = int(thief.get("damage", 28) * 3.0)
			enemy_data["current_health"] = max(0, enemy_data["current_health"] - bs_dmg)
			_spawn_combat_badge(enemy_anchor.position + Vector2(40, -210), "🗡 УДАР В СПИНУ / BACKSTAB", Color(0.1, 0.6, 0.25, 0.95), Color(0.4, 1.0, 0.5, 1.0))
			_spawn_floating_text(enemy_anchor.position + Vector2(20, -150), "⚡-%d" % bs_dmg, Color(0.2, 1.0, 0.4), 1.4)
			_log("[color=#33ff77]🗡 Тень наносит сокрушительный удар в спину: %d критического урона![/color]" % bs_dmg)
			_shake_node(enemy_anchor, 8.0)
			_update_hud()
			if enemy_data["current_health"] <= 0:
				_on_enemy_defeated()
				return
		
		thief["cooldown"] = max(0.0, thief.get("cooldown", 0.0) - delta)
		if enemy_data.get("current_health", 0) > 0 and thief["cooldown"] <= 0.0:
			thief["cooldown"] = 1.0 / thief.get("speed", 1.45)
			var is_crit = randf() < thief.get("crit_chance", 0.38)
			var dmg = thief.get("damage", 28)
			if is_crit:
				dmg = int(dmg * thief.get("crit_multiplier", 2.2))
			if rebirth_3d:
				rebirth_3d.animate_companion_attack("nightshade", Vector3.ZERO, is_crit)
			enemy_data["current_health"] = max(0, enemy_data["current_health"] - dmg)
			_spawn_floating_text(enemy_anchor.position + Vector2(randf_range(-15, 15), -110), "-%d" % dmg, Color(0.25, 0.9, 0.45))
			_update_hud()
			if enemy_data["current_health"] <= 0:
				_on_enemy_defeated()
				return

	# -------------------------------------------------------------
	# 4. Backline Cleric (Bloodweaver)
	# -------------------------------------------------------------
	if party_members.get("bloodweaver", {}).get("active", false) and party_members["bloodweaver"].get("current_hp", 0) > 0:
		var cleric = party_members["bloodweaver"]
		cleric["heal_cooldown"] = max(0.0, cleric.get("heal_cooldown", 0.0) - delta)
		if cleric["heal_cooldown"] <= 0.0:
			cleric["heal_cooldown"] = 6.5
			var lowest_role = ""
			var lowest_pct = 1.0
			for r in party_members:
				if party_members[r].get("active", true):
					var pct = float(party_members[r]["current_hp"]) / float(party_members[r]["max_hp"])
					if pct < lowest_pct:
						lowest_pct = pct
						lowest_role = r
			if lowest_role != "" and lowest_pct < 0.95:
				sound_manager.play_heal()
				if rebirth_3d:
					rebirth_3d.animate_cleric_heal(lowest_role)
				var target_m = party_members[lowest_role]
				var h_amt = int(target_m["max_hp"] * 0.25)
				target_m["current_hp"] = min(target_m["max_hp"], target_m["current_hp"] + h_amt)
				if lowest_role == "wanderer":
					player_stats["current_health"] = min(player_stats["max_health"], player_stats["current_health"] + h_amt)
					_spawn_floating_text(player_anchor.position + Vector2(0, -140), "+%d ОЗ" % h_amt, Color(0.95, 0.3, 0.4))
				_spawn_combat_badge(player_anchor.position + Vector2(0, -210), "🩸 ИСЦЕЛЕНИЕ КРОВИ / BLOOD HEAL", Color(0.7, 0.1, 0.2, 0.95), Color(1.0, 0.4, 0.5, 1.0))
				_log("[color=#ff4d66]🩸 Кровный Ткач исцеляет %s на +%d ОЗ![/color]" % [target_m["name"], h_amt])
				_update_party_hud()
				_update_hud()
		
		cleric["cooldown"] = max(0.0, cleric.get("cooldown", 0.0) - delta)
		if enemy_data.get("current_health", 0) > 0 and cleric["cooldown"] <= 0.0:
			cleric["cooldown"] = 1.0 / cleric.get("speed", 0.9)
			if rebirth_3d:
				rebirth_3d.animate_companion_attack("bloodweaver", Vector3.ZERO, false)
			var c_dmg = cleric.get("damage", 15)
			enemy_data["current_health"] = max(0, enemy_data["current_health"] - c_dmg)
			_spawn_floating_text(enemy_anchor.position + Vector2(10, -100), "-%d" % c_dmg, Color(0.9, 0.35, 0.45))
			_update_hud()
			if enemy_data["current_health"] <= 0:
				_on_enemy_defeated()
				return

	# -------------------------------------------------------------
	# 5. Enemy Attack
	# -------------------------------------------------------------
	enemy_attack_cooldown -= delta
	if enemy_data.get("current_health", 0) > 0 and enemy_attack_cooldown <= 0.0:
		_execute_enemy_attack()
		var e_spd = max(0.2, float(enemy_data.get("attack_speed", 1.0)))
		enemy_attack_cooldown = 1.0 / e_spd
	
	_update_party_hud()

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
	
	if btn_skip_draft != null:
		var bonus_g = 20 + current_floor * 5
		btn_skip_draft.text = localization.get_string("btn_skip_draft") % bonus_g
	
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
	if rebirth_3d:
		bg_texture.visible = false
		ground_shadow.visible = false
		player_anchor.visible = false
		enemy_anchor.visible = false
		player_sprite.visible = false
		enemy_sprite.visible = false
	camp_panel.visible = true
	draft_modal.visible = false
	defeat_modal.visible = false
	battle_hud.visible = false
	top_hud.visible = true
	$Arena.visible = false
	if archway_sprite: archway_sprite.visible = false
	if chest_sprite: chest_sprite.visible = false
	if chest_modal: chest_modal.visible = false
	
	if rebirth_3d:
		rebirth_3d.set_stage_camp()
	if sound_manager:
		sound_manager.play_camp_theme()
	
	floor_banner.text = ""
	_refresh_camp_ui()

func _refresh_camp_ui():
	var gold = save_manager.save_data.get("PersistentGold", 0)
	var max_floor = save_manager.save_data.get("HighestFloorReached", 1)
	altar_gold_label.text = localization.get_string("camp_gold_record") % [gold, max_floor]
	gold_label.text = "%d %s" % [gold, localization.get_string("gold_unit")]
	
	for child in upgrades_container.get_children():
		upgrades_container.remove_child(child)
		child.queue_free()
	
	for upg in game_data.meta_upgrades:
		var type_name = upg.get("type", "")
		var rank = save_manager.get_upgrade_rank(type_name)
		var base_cost = int(upg.get("baseCost", 50))
		var cost = base_cost * (rank + 1)
		
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(400, 56)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
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
		p_style.content_margin_left = 10
		p_style.content_margin_top = 6
		p_style.content_margin_right = 10
		p_style.content_margin_bottom = 6
		panel.add_theme_stylebox_override("panel", p_style)
		
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 10)
		panel.add_child(hbox)
		
		var upg_name = localization.get_upgrade_name(type_name, upg.get("name", ""))
		var upg_bonus = localization.get_upgrade_bonus(type_name, upg.get("statBonus", ""))
		var upg_desc = localization.get_upgrade_description(type_name, upg.get("description", ""))
		
		var info_vbox = VBoxContainer.new()
		info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(info_vbox)
		
		var lbl_title = Label.new()
		lbl_title.text = "%s  [%s %d] — %s" % [upg_name, localization.get_string("rank"), rank, upg_bonus]
		lbl_title.add_theme_font_size_override("font_size", 12)
		lbl_title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.4))
		lbl_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_vbox.add_child(lbl_title)
		
		var lbl_desc = Label.new()
		lbl_desc.text = upg_desc
		lbl_desc.add_theme_font_size_override("font_size", 10)
		lbl_desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
		lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info_vbox.add_child(lbl_desc)
		
		var btn_upg = Button.new()
		btn_upg.custom_minimum_size = Vector2(100, 34)
		btn_upg.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		btn_upg.add_theme_font_size_override("font_size", 11)
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
	sound_manager.play_gate()
	current_floor = 1
	run_gold_earned = 0
	equipped_items.clear()
	player_soul = 0.0
	_calculate_player_stats()
	_update_player_visuals()
	for r_id in party_members:
		party_members[r_id]["current_hp"] = party_members[r_id]["max_hp"]
		party_members[r_id]["cooldown"] = 0.0
		if party_members[r_id].has("taunt_timer"):
			party_members[r_id]["taunt_timer"] = 0.0
	_start_floor_battle(true)
	if rebirth_3d:
		rebirth_3d.animate_ascent_through_gate(Callable())

func _start_floor_battle(with_walk_entry: bool = false):
	state = GameState.BATTLE
	bg_texture.texture = tex_spire_interior
	camp_panel.visible = false
	draft_modal.visible = false
	defeat_modal.visible = false
	battle_hud.visible = true
	top_hud.visible = true
	$Arena.visible = true
	if rebirth_3d:
		bg_texture.visible = false
		ground_shadow.visible = false
		player_anchor.visible = false
		enemy_anchor.visible = false
		player_sprite.visible = false
		enemy_sprite.visible = false
		if archway_sprite: archway_sprite.visible = false
		if chest_sprite: chest_sprite.visible = false
	else:
		if archway_sprite: archway_sprite.visible = true
		if chest_sprite: chest_sprite.visible = false
	if chest_modal: chest_modal.visible = false
	if room_clear_banner: room_clear_banner.visible = false
	
	player_sprite.modulate = Color(1, 1, 1, 1)
	enemy_sprite.modulate = Color(1, 1, 1, 1)
	
	enemy_data = game_data.get_enemy_for_floor(current_floor)
	_setup_enemy_visuals()
	_update_player_visuals()
	
	player_attack_cooldown = 0.5
	enemy_attack_cooldown = 1.0
	
	var is_boss = enemy_data.get("isBoss", false)
	var e_name = localization.get_enemy_name(enemy_data.get("id", ""), enemy_data.get("name", ""))
	if is_boss:
		floor_banner.text = localization.get_string("boss_floor_banner") % [current_floor, e_name.to_upper()]
	else:
		floor_banner.text = localization.get_string("floor_banner") % [current_floor, e_name.to_upper()]
	
	gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]
	player_name_label.text = localization.get_string("player_label")
	enemy_name_label.text = e_name
	
	if party_members.has("wanderer"):
		party_members["wanderer"]["current_hp"] = player_stats.get("current_health", 100)
		party_members["wanderer"]["max_hp"] = player_stats.get("max_health", 100)
	
	_update_hud()
	_update_party_hud()
	_refresh_equipped_icons()
	_log("[color=#c0a060]%s[/color]" % [localization.get_string("log_floor_entered") % [current_floor, e_name]])
	
	if sound_manager:
		sound_manager.play_combat_theme()
	
	if rebirth_3d:
		rebirth_3d.set_stage_battle(current_floor, enemy_data.get("id", ""), is_boss)
	
	if with_walk_entry:
		_animate_room_entrance()
	else:
		player_anchor.position = player_base_pos
		enemy_anchor.position = enemy_base_pos
		is_traversing = false

func _animate_room_entrance():
	is_traversing = true
	player_anchor.position = Vector2(80, player_base_pos.y)
	enemy_anchor.position = Vector2(1150, enemy_base_pos.y)
	walk_dust.emitting = true
	enemy_walk_dust.emitting = true
	
	sound_manager.play_step()
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(player_anchor, "position:x", player_base_pos.x, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(enemy_anchor, "position:x", enemy_base_pos.x, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Weapon ready sway
	tw.tween_property(weapon_anchor, "rotation_degrees", -22.0, 0.65)
	
	tw.chain().tween_callback(func():
		walk_dust.emitting = false
		enemy_walk_dust.emitting = false
		is_traversing = false
	)

func _setup_enemy_visuals():
	var enemy_id = enemy_data.get("id", "")
	var is_boss = enemy_data.get("isBoss", false)
	
	if is_boss:
		if current_floor >= 30:
			enemy_sprite.texture = tex_boss_valthor if tex_boss_valthor else tex_boss_malgorath
			enemy_sprite.scale = Vector2(1.05, 1.05)
		elif current_floor >= 20:
			enemy_sprite.texture = tex_boss_amalgam
			enemy_sprite.scale = Vector2(0.95, 0.95)
		else:
			enemy_sprite.texture = tex_boss_malgorath
			enemy_sprite.scale = Vector2(1.0, 1.0)
	elif enemy_id == "feeble_skeleton" or current_floor == 1:
		enemy_sprite.texture = tex_enemy_skeleton
		enemy_sprite.scale = Vector2(0.85, 0.85)
	elif enemy_id == "spire_imp" or current_floor == 2:
		enemy_sprite.texture = tex_enemy_imp
		enemy_sprite.scale = Vector2(0.8, 0.8)
	elif enemy_id == "crypt_ghoul" or current_floor == 3:
		enemy_sprite.texture = tex_enemy_ghoul if tex_enemy_ghoul else tex_enemy_skeleton
		enemy_sprite.scale = Vector2(0.85, 0.85)
	elif enemy_id == "tormented_shade" or current_floor == 4:
		enemy_sprite.texture = tex_enemy_shade if tex_enemy_shade else tex_enemy_skeleton
		enemy_sprite.scale = Vector2(0.85, 0.85)
	elif enemy_id == "hollow_knight" or current_floor == 5:
		enemy_sprite.texture = tex_enemy_knight
		enemy_sprite.scale = Vector2(0.85, 0.85)
	elif enemy_id == "blood_cultist" or current_floor == 6:
		enemy_sprite.texture = tex_enemy_cultist if tex_enemy_cultist else tex_enemy_knight
		enemy_sprite.scale = Vector2(0.85, 0.85)
	elif enemy_id == "obsidian_gargoyle" or current_floor == 8:
		enemy_sprite.texture = tex_enemy_obsidian_gargoyle if tex_enemy_obsidian_gargoyle else tex_enemy_knight
		enemy_sprite.scale = Vector2(0.9, 0.9)
	elif enemy_id == "plague_abomination" or current_floor == 9:
		enemy_sprite.texture = tex_enemy_plague_abomination if tex_enemy_plague_abomination else tex_enemy_ghoul
		enemy_sprite.scale = Vector2(0.95, 0.95)
	elif enemy_id == "cursed_inquisitor" or current_floor in [11, 12, 13]:
		enemy_sprite.texture = tex_enemy_inquisitor if tex_enemy_inquisitor else tex_enemy_cultist
		enemy_sprite.scale = Vector2(0.85, 0.85)
	elif enemy_id == "spire_executioner" or current_floor in [14, 15, 16]:
		enemy_sprite.texture = tex_enemy_executioner if tex_enemy_executioner else tex_enemy_knight
		enemy_sprite.scale = Vector2(0.9, 0.9)
	elif enemy_id == "crypt_lich" or current_floor in [17, 18, 19]:
		enemy_sprite.texture = tex_enemy_crypt_lich if tex_enemy_crypt_lich else tex_enemy_shade
		enemy_sprite.scale = Vector2(0.88, 0.88)
	elif enemy_id == "void_stalker" or (current_floor >= 21 and current_floor <= 25):
		enemy_sprite.texture = tex_enemy_void_stalker if tex_enemy_void_stalker else tex_enemy_shade
		enemy_sprite.scale = Vector2(0.85, 0.85)
	elif enemy_id == "infernal_colossus" or (current_floor >= 26 and current_floor <= 29):
		enemy_sprite.texture = tex_enemy_infernal_colossus if tex_enemy_infernal_colossus else tex_enemy_knight
		enemy_sprite.scale = Vector2(1.0, 1.0)
	else:
		enemy_sprite.texture = tex_enemy_knight
		enemy_sprite.scale = Vector2(0.85, 0.85)
	
	enemy_sprite.modulate = Color(1, 1, 1, 1)

func _update_player_visuals():
	# 1. Weapon
	var w = equipped_items.get("Weapon", null)
	if w:
		weapon_sprite.visible = true
		var w_id = w.get("id", "")
		if "scythe" in w_id:
			weapon_sprite.texture = tex_gear_weapons.get("scythe")
		elif "mace" in w_id:
			weapon_sprite.texture = tex_gear_weapons.get("mace")
		elif "axe" in w_id:
			weapon_sprite.texture = tex_gear_weapons.get("axe")
		elif "greatsword" in w_id or "eater" in w_id:
			weapon_sprite.texture = tex_gear_weapons.get("greatsword")
		elif "dagger" in w_id or "katana" in w_id:
			weapon_sprite.texture = tex_gear_weapons.get("dagger")
		else:
			weapon_sprite.texture = tex_gear_weapons.get("cleaver")
		
		# Glow / enchant effect based on item rarity
		var rarity = w.get("rarity", "Common")
		if rarity == "Cursed":
			weapon_sprite.modulate = Color(1.8, 0.35, 0.45, 1.0)
		elif rarity in ["Mythic", "Legendary"]:
			weapon_sprite.modulate = Color(1.5, 1.35, 0.45, 1.0)
		elif rarity == "Epic":
			weapon_sprite.modulate = Color(1.4, 0.6, 1.7, 1.0)
		elif rarity == "Rare":
			weapon_sprite.modulate = Color(0.6, 1.2, 1.8, 1.0)
		else:
			weapon_sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		weapon_sprite.visible = false
	
	# 2. Helmet
	var h = equipped_items.get("Helmet", null)
	if h:
		helm_overlay.visible = true
		var h_id = h.get("id", "")
		if "thorns" in h_id or "king" in h_id:
			helm_overlay.texture = tex_gear_helms.get("crown_thorns")
		elif "inquisitor" in h_id or "mitre" in h_id:
			helm_overlay.texture = tex_gear_helms.get("inquisitor")
		elif "hood" in h_id or "cowl" in h_id:
			helm_overlay.texture = tex_gear_helms.get("hood")
		else:
			helm_overlay.texture = tex_gear_helms.get("sallet")
		helm_overlay.modulate = Color(1, 1, 1, 1)
	else:
		helm_overlay.visible = false
	
	# 3. Armor
	var a = equipped_items.get("Armor", null)
	if a:
		armor_overlay.visible = true
		var a_id = a.get("id", "")
		if "carapace" in a_id or "shroud" in a_id:
			armor_overlay.texture = tex_gear_armors.get("carapace")
		elif "robes" in a_id or "vestment" in a_id:
			armor_overlay.texture = tex_gear_armors.get("robes")
		else:
			armor_overlay.texture = tex_gear_armors.get("cuirass")
		armor_overlay.modulate = Color(1, 1, 1, 1)
	else:
		armor_overlay.visible = false
	
	# 4. Offhand
	var o = equipped_items.get("OffHand", null)
	if o:
		offhand_sprite.visible = true
		var o_id = o.get("id", "")
		if "grimoire" in o_id or "totem" in o_id:
			offhand_sprite.texture = tex_gear_offhands.get("grimoire")
		elif "buckler" in o_id or "shield" in o_id:
			offhand_sprite.texture = tex_gear_offhands.get("buckler")
		else:
			offhand_sprite.texture = tex_gear_offhands.get("weeping")
		offhand_sprite.modulate = Color(1, 1, 1, 1)
	else:
		offhand_sprite.visible = false
	
	# 5. Accessory Aura & Enchant
	var acc = equipped_items.get("Accessory", null)
	accessory_aura.visible = (acc != null)
	if acc != null:
		var acc_r = acc.get("rarity", "Common")
		var mote_color = Color(1.0, 0.4, 0.5, 0.9)
		if acc_r == "Cursed":
			mote_color = Color(1.0, 0.15, 0.25, 0.95)
		elif acc_r in ["Legendary", "Mythic"]:
			mote_color = Color(1.0, 0.88, 0.2, 0.95)
		elif acc_r == "Epic":
			mote_color = Color(0.85, 0.35, 1.0, 0.95)
		for child in accessory_aura.get_children():
			if child is Polygon2D:
				child.color = mote_color

# ==============================================================================
# COMBAT EXECUTION
# ==============================================================================

func _execute_player_attack():
	var res = game_data.calculate_damage(player_stats, enemy_data)
	var e_name = localization.get_enemy_name(enemy_data.get("id", ""), enemy_data.get("name", "Enemy"))
	if res.dodged:
		var tw_edodge = create_tween()
		tw_edodge.tween_property(enemy_anchor, "position:x", enemy_base_pos.x + 60, 0.08 / combat_speed)
		tw_edodge.tween_property(enemy_anchor, "position:x", enemy_base_pos.x, 0.12 / combat_speed)
		_spawn_floating_text(enemy_anchor.position + Vector2(0, -140), localization.get_string("float_dodge"), Color(0.4, 0.8, 1.0))
		_spawn_combat_badge(enemy_anchor.position + Vector2(0, -220), localization.get_string("badge_dodge"), Color(0.05, 0.35, 0.6, 0.9), Color(0.3, 0.8, 1.0, 1.0))
		_log(localization.get_string("log_enemy_dodge") % e_name)
		return

	var dmg = res.damage
	var is_crit = res.is_crit
	var lifesteal = res.lifesteal
	var combo_idx = player_combo_step
	player_combo_step = (player_combo_step + 1) % 3
	
	player_soul = min(100.0, player_soul + 20.0)
	if soul_bar != null:
		soul_bar.value = player_soul
	
	if rebirth_3d:
		rebirth_3d.animate_companion_attack("wanderer", Vector3.ZERO, is_crit)
	
	match combo_idx:
		0:
			_execute_combo_twin_slash(dmg, is_crit, lifesteal, e_name)
		1:
			_execute_combo_heavy_thrust(dmg, is_crit, lifesteal, e_name)
		2:
			_execute_combo_overhead_cleave(dmg, is_crit, lifesteal, e_name)

func _execute_combo_twin_slash(total_dmg: int, is_crit: bool, lifesteal: int, e_name: String):
	var dmg1 = max(1, int(round(total_dmg * 0.45)))
	var dmg2 = max(1, total_dmg - dmg1)
	
	var tw = create_tween()
	# Hit 1: Quick jab lunge
	tw.tween_property(player_anchor, "position:x", player_base_pos.x + 75, 0.06 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", -45.0, 0.06 / combat_speed)
	
	tw.tween_callback(func():
		sound_manager.play_slash()
		_spawn_fx_slash(enemy_anchor.position + Vector2(-20, -110))
		_flash_node(enemy_sprite, Color(2.5, 0.8, 0.8, 1.0))
		_shake_node(enemy_anchor, 4.0)
		_spawn_floating_text(enemy_anchor.position + Vector2(-25, -130), "-%d" % dmg1, Color(1.0, 0.6, 0.6))
		enemy_data["current_health"] = max(0, enemy_data["current_health"] - dmg1)
		_update_hud()
	)
	
	# Hit 2: Immediate follow-up cleave
	tw.tween_property(player_anchor, "position:x", player_base_pos.x + 115, 0.08 / combat_speed).set_delay(0.04 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", 75.0, 0.08 / combat_speed)
	
	tw.tween_callback(func():
		if is_crit:
			sound_manager.play_crit()
			_spawn_combat_badge(player_anchor.position + Vector2(40, -220), localization.get_string("badge_crit"), Color(0.8, 0.5, 0.0, 0.95), Color(1.0, 0.9, 0.2, 1.0))
			_spawn_floating_text(enemy_anchor.position + Vector2(25, -145), localization.get_string("float_crit") % dmg2, Color(1.0, 0.85, 0.1), 1.3)
			_log(localization.get_string("log_player_crit") % [e_name, total_dmg])
		else:
			sound_manager.play_hit()
			_spawn_combat_badge(player_anchor.position + Vector2(40, -220), localization.get_string("badge_combo"), Color(0.1, 0.45, 0.8, 0.9), Color(0.4, 0.8, 1.0, 1.0))
			_spawn_floating_text(enemy_anchor.position + Vector2(25, -135), "-%d" % dmg2, Color(1.0, 0.3, 0.3))
			_log(localization.get_string("log_player_hit") % [e_name, total_dmg])
		
		_spawn_fx_slash(enemy_anchor.position + Vector2(15, -85), true)
		_spawn_blood_burst(enemy_anchor.position + Vector2(0, -95))
		_shake_node(enemy_anchor, 9.0 if is_crit else 5.0)
		_flash_node(enemy_sprite, Color(3.0, 0.5, 0.5, 1.0))
		
		enemy_data["current_health"] = max(0, enemy_data["current_health"] - dmg2)
		
		if lifesteal > 0:
			player_stats["current_health"] = min(player_stats["max_health"], player_stats["current_health"] + lifesteal)
			_spawn_floating_text(player_anchor.position + Vector2(0, -140), localization.get_string("float_hp") % lifesteal, Color(0.3, 1.0, 0.4))
		
		_update_hud()
		if enemy_data["current_health"] <= 0:
			_on_enemy_defeated()
	)
	
	# Return to stance
	tw.tween_property(player_anchor, "position:x", player_base_pos.x, 0.12 / combat_speed).set_delay(0.05 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", -20.0, 0.12 / combat_speed)

func _execute_combo_heavy_thrust(dmg: int, is_crit: bool, lifesteal: int, e_name: String):
	var bonus_dmg = int(dmg * 1.15)
	
	var tw = create_tween()
	# Crouch windup
	tw.tween_property(player_anchor, "position:x", player_base_pos.x - 30, 0.08 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", -80.0, 0.08 / combat_speed)
	
	# Explosive lunge thrust
	tw.tween_property(player_anchor, "position:x", player_base_pos.x + 140, 0.08 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", 25.0, 0.08 / combat_speed)
	
	tw.tween_callback(func():
		sound_manager.play_slash()
		sound_manager.play_hit()
		_spawn_heavy_slash(enemy_anchor.position + Vector2(-15, -95))
		_spawn_blood_burst(enemy_anchor.position + Vector2(0, -95))
		_shake_node(enemy_anchor, 11.0 if is_crit else 8.0)
		_flash_node(enemy_sprite, Color(3.5, 0.3, 0.3, 1.0))
		
		_spawn_combat_badge(player_anchor.position + Vector2(40, -220), localization.get_string("badge_heavy_thrust"), Color(0.75, 0.15, 0.1, 0.95), Color(1.0, 0.45, 0.2, 1.0))
		
		if is_crit:
			sound_manager.play_crit()
			_spawn_floating_text(enemy_anchor.position + Vector2(0, -150), localization.get_string("float_crit") % bonus_dmg, Color(1.0, 0.85, 0.1), 1.4)
			_log(localization.get_string("log_player_crit") % [e_name, bonus_dmg])
		else:
			_spawn_floating_text(enemy_anchor.position + Vector2(0, -140), "-%d" % bonus_dmg, Color(1.0, 0.3, 0.3), 1.2)
			_log(localization.get_string("log_player_hit") % [e_name, bonus_dmg])
		
		enemy_data["current_health"] = max(0, enemy_data["current_health"] - bonus_dmg)
		
		if lifesteal > 0:
			player_stats["current_health"] = min(player_stats["max_health"], player_stats["current_health"] + lifesteal)
			_spawn_floating_text(player_anchor.position + Vector2(0, -140), localization.get_string("float_hp") % lifesteal, Color(0.3, 1.0, 0.4))
		
		_update_hud()
		if enemy_data["current_health"] <= 0:
			_on_enemy_defeated()
	)
	
	# Recoil return
	tw.tween_property(player_anchor, "position:x", player_base_pos.x, 0.14 / combat_speed).set_delay(0.06 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", -20.0, 0.14 / combat_speed)

func _execute_combo_overhead_cleave(dmg: int, is_crit: bool, lifesteal: int, e_name: String):
	var tw = create_tween()
	# Leap into air
	tw.tween_property(player_anchor, "position", player_base_pos + Vector2(50, -40), 0.10 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", -100.0, 0.10 / combat_speed)
	if player_shadow != null:
		tw.parallel().tween_property(player_shadow, "scale", Vector2(0.40, 0.32), 0.10 / combat_speed)
	
	# Downward cleave impact
	tw.tween_property(player_anchor, "position", player_base_pos + Vector2(105, 0), 0.08 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", 80.0, 0.08 / combat_speed)
	if player_shadow != null:
		tw.parallel().tween_property(player_shadow, "scale", Vector2(0.55, 0.45), 0.08 / combat_speed)
	
	tw.tween_callback(func():
		sound_manager.play_slash()
		sound_manager.play_hit()
		_spawn_heavy_slash(enemy_anchor.position + Vector2(0, -90), false, PI * 0.2)
		_spawn_blood_burst(enemy_anchor.position + Vector2(0, -90))
		_shake_node(enemy_anchor, 10.0 if is_crit else 6.0)
		_flash_node(enemy_sprite, Color(3.0, 0.4, 0.4, 1.0))
		if enemy_walk_dust:
			enemy_walk_dust.restart()
		
		_spawn_combat_badge(player_anchor.position + Vector2(40, -220), localization.get_string("badge_cleave"), Color(0.5, 0.1, 0.6, 0.95), Color(0.85, 0.4, 1.0, 1.0))
		
		if is_crit:
			sound_manager.play_crit()
			_spawn_floating_text(enemy_anchor.position + Vector2(0, -150), localization.get_string("float_crit") % dmg, Color(1.0, 0.85, 0.1), 1.4)
			_log(localization.get_string("log_player_crit") % [e_name, dmg])
		else:
			_spawn_floating_text(enemy_anchor.position + Vector2(0, -140), "-%d" % dmg, Color(1.0, 0.4, 0.4), 1.1)
			_log(localization.get_string("log_player_hit") % [e_name, dmg])
		
		enemy_data["current_health"] = max(0, enemy_data["current_health"] - dmg)
		
		if lifesteal > 0:
			player_stats["current_health"] = min(player_stats["max_health"], player_stats["current_health"] + lifesteal)
			_spawn_floating_text(player_anchor.position + Vector2(0, -140), localization.get_string("float_hp") % lifesteal, Color(0.3, 1.0, 0.4))
		
		_update_hud()
		if enemy_data["current_health"] <= 0:
			_on_enemy_defeated()
	)
	
	# Step back
	tw.tween_property(player_anchor, "position", player_base_pos, 0.12 / combat_speed).set_delay(0.05 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", -20.0, 0.12 / combat_speed)

func _execute_player_soul_cleave():
	player_soul = 0.0
	sound_manager.play_soul()
	if rebirth_3d:
		rebirth_3d.animate_hero_soul_cleave()
	
	var p_dmg = int(player_stats.get("attack_damage", 15) * 2.5)
	enemy_data["current_health"] = max(0, enemy_data["current_health"] - p_dmg)
	_update_hud()
	
	var tw = create_tween()
	# Hero dashes straight into enemy space and leaps
	tw.tween_property(player_anchor, "position", player_base_pos + Vector2(130, -55), 0.11 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", -180.0, 0.11 / combat_speed)
	
	# Full 360 whirlwind spin cleave
	tw.tween_property(player_anchor, "position", player_base_pos + Vector2(150, 0), 0.10 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", 180.0, 0.10 / combat_speed)
	
	tw.tween_callback(func():
		_spawn_heavy_slash(enemy_anchor.position + Vector2(0, -95), false, 0.0)
		_spawn_heavy_slash(enemy_anchor.position + Vector2(0, -75), true, PI * 0.45)
		_spawn_blood_burst(enemy_anchor.position + Vector2(-20, -90))
		_spawn_blood_burst(enemy_anchor.position + Vector2(20, -100))
		
		_shake_node(enemy_anchor, 15.0)
		_flash_node(enemy_sprite, Color(3.5, 0.3, 2.5, 1.0))
		
		_spawn_combat_badge(player_anchor.position + Vector2(50, -230), localization.get_string("badge_soul_cleave"), Color(0.65, 0.05, 0.75, 0.95), Color(1.0, 0.85, 0.2, 1.0))
		_spawn_floating_text(enemy_anchor.position + Vector2(0, -155), localization.get_string("float_soul") % p_dmg, Color(0.95, 0.4, 1.0), 1.6)
		_log(localization.get_string("log_player_soul") % p_dmg)
		_update_hud()
		
		if enemy_data["current_health"] <= 0:
			_on_enemy_defeated()
	)
	
	# Recovery return to base pos
	tw.tween_property(player_anchor, "position", player_base_pos, 0.14 / combat_speed).set_delay(0.08 / combat_speed)
	tw.parallel().tween_property(weapon_anchor, "rotation_degrees", -20.0, 0.14 / combat_speed)

func _execute_enemy_attack():
	if rebirth_3d:
		rebirth_3d.animate_enemy_attack()
	
	# Check if Bulwark taunt is active
	var bulwark_taunting = party_members.get("bulwark", {}).get("active", false) and party_members["bulwark"].get("taunt_timer", 0.0) > 0.0 and party_members["bulwark"].get("current_hp", 0) > 0
	if bulwark_taunting:
		telegraph_glow.visible = true
		var tw_tel = create_tween()
		tw_tel.tween_property(telegraph_glow, "modulate:a", 1.0, 0.07 / combat_speed)
		tw_tel.tween_property(telegraph_glow, "modulate:a", 0.0, 0.07 / combat_speed)
		tw_tel.tween_callback(func(): telegraph_glow.visible = false)
		
		var tw_tank = create_tween()
		tw_tank.tween_property(enemy_anchor, "position:x", enemy_base_pos.x - 120, 0.09 / combat_speed)
		
		var raw_dmg = enemy_data.get("attack_damage", 10)
		var mitigated_dmg = max(1, int(raw_dmg * 0.40))
		party_members["bulwark"]["current_hp"] = max(0, party_members["bulwark"]["current_hp"] - mitigated_dmg)
		
		tw_tank.tween_callback(func():
			sound_manager.play_shield_block()
			_spawn_parry_spark(player_anchor.position + Vector2(-60, -140))
			_spawn_combat_badge(player_anchor.position + Vector2(-60, -210), "🛡 БЛОК ЩИТОМ (-60%)", Color(0.1, 0.4, 0.8, 0.95), Color(0.5, 0.9, 1.0, 1.0))
			_spawn_floating_text(player_anchor.position + Vector2(-60, -140), "-%d [Щит]" % mitigated_dmg, Color(0.5, 0.8, 1.0))
			_log("[color=#4da6ff]🛡 Оплот принимает удар на щит: поглощено 60%% урона (-%d ОЗ Оплота).[/color]" % mitigated_dmg)
			_shake_node(player_anchor, 3.0)
			_update_party_hud()
		)
		tw_tank.tween_property(enemy_anchor, "position:x", enemy_base_pos.x, 0.13 / combat_speed).set_delay(0.06 / combat_speed)
		return
	
	# Telegraph flash before lunge
	telegraph_glow.visible = true
	var tw_tel = create_tween()
	tw_tel.tween_property(telegraph_glow, "modulate:a", 1.0, 0.07 / combat_speed)
	tw_tel.tween_property(telegraph_glow, "modulate:a", 0.0, 0.07 / combat_speed)
	tw_tel.tween_callback(func(): telegraph_glow.visible = false)
	
	# Enemy lunges forward into physical striking range
	var tw = create_tween()
	tw.tween_property(enemy_anchor, "position:x", enemy_base_pos.x - 120, 0.09 / combat_speed)
	
	var res = game_data.calculate_damage(enemy_data, player_stats)
	var e_name = localization.get_enemy_name(enemy_data.get("id", ""), enemy_data.get("name", "Enemy"))
	
	if res.dodged:
		# Player rapid shadow roll / backdash dodge
		var tw_dodge = create_tween()
		tw_dodge.tween_property(player_anchor, "position:x", player_base_pos.x - 65, 0.07 / combat_speed)
		tw_dodge.tween_property(player_anchor, "position:x", player_base_pos.x, 0.12 / combat_speed)
		_spawn_combat_badge(player_anchor.position + Vector2(-30, -210), localization.get_string("badge_dodge"), Color(0.05, 0.35, 0.6, 0.9), Color(0.3, 0.8, 1.0, 1.0))
		_spawn_floating_text(player_anchor.position + Vector2(0, -140), localization.get_string("float_dodge"), Color(0.4, 0.8, 1.0))
		_log(localization.get_string("log_player_dodge") % e_name)
		
		# Enemy misses and returns
		tw.tween_property(enemy_anchor, "position:x", enemy_base_pos.x, 0.12 / combat_speed).set_delay(0.05 / combat_speed)
		return
	
	var dmg = res.damage
	var is_blocked = res.get("is_blocked", false)
	
	if is_blocked and offhand_sprite.visible:
		# Shield raise & parry clash
		var tw_block = create_tween()
		tw_block.tween_property(offhand_anchor, "position:x", -10.0, 0.05 / combat_speed)
		tw_block.tween_property(offhand_anchor, "position:x", -45.0, 0.12 / combat_speed)
		
		tw.tween_callback(func():
			sound_manager.play_block()
			_spawn_parry_spark(player_anchor.position + Vector2(40, -140))
			_spawn_combat_badge(player_anchor.position + Vector2(-20, -215), localization.get_string("badge_parry"), Color(0.7, 0.5, 0.05, 0.95), Color(1.0, 0.9, 0.3, 1.0))
			_spawn_floating_text(player_anchor.position + Vector2(0, -140), localization.get_string("float_block"), Color(0.5, 0.85, 1.0))
			_log(localization.get_string("log_player_block"))
			
			# Hero recoil
			_shake_node(player_anchor, 4.0)
			player_stats["current_health"] = max(0, player_stats["current_health"] - dmg)
			if party_members.has("wanderer"):
				party_members["wanderer"]["current_hp"] = player_stats["current_health"]
			player_soul = min(100.0, player_soul + 12.0)
			_update_hud()
			_update_party_hud()
			if player_stats["current_health"] <= 0:
				_on_player_perished()
		)
	else:
		tw.tween_callback(func():
			sound_manager.play_hit()
			_spawn_fx_slash(player_anchor.position + Vector2(0, -100), true)
			_spawn_blood_burst(player_anchor.position + Vector2(0, -100))
			_shake_node(player_anchor, 6.0)
			_flash_node(player_sprite, Color(2.5, 0.4, 0.4, 1.0))
			
			_spawn_floating_text(player_anchor.position + Vector2(0, -140), "-%d" % dmg, Color(1.0, 0.2, 0.2))
			_log(localization.get_string("log_enemy_hit") % [e_name, dmg])
			
			player_stats["current_health"] = max(0, player_stats["current_health"] - dmg)
			if party_members.has("wanderer"):
				party_members["wanderer"]["current_hp"] = player_stats["current_health"]
			player_soul = min(100.0, player_soul + 10.0)
			_update_hud()
			_update_party_hud()
			if player_stats["current_health"] <= 0:
				_on_player_perished()
		)
	
	# Enemy returns to base position
	tw.tween_property(enemy_anchor, "position:x", enemy_base_pos.x, 0.13 / combat_speed).set_delay(0.06 / combat_speed)

func _on_enemy_defeated():
	sound_manager.play_room_clear()
	var base_gold = int(enemy_data.get("gold_reward", 15))
	var gold_mult = float(player_stats.get("gold_multiplier", 1.0))
	var total_gold = int(round(base_gold * gold_mult))
	
	# Nightshade thief passive bonus (+35% gold find)
	if party_members.get("nightshade", {}).get("active", false):
		total_gold = int(round(total_gold * 1.35))
	
	run_gold_earned += total_gold
	save_manager.add_gold(total_gold)
	save_manager.record_run_completion(current_floor)
	gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]
	
	# Bloodweaver cleric passive bonus (+15% post-battle squad heal)
	if party_members.get("bloodweaver", {}).get("active", false):
		for r in party_members:
			var m = party_members[r]
			var heal = int(m["max_hp"] * 0.15)
			m["current_hp"] = min(m["max_hp"], m["current_hp"] + heal)
		var hero_heal = int(player_stats["max_health"] * 0.15)
		player_stats["current_health"] = min(player_stats["max_health"], player_stats["current_health"] + hero_heal)
		_log("[color=#e05565]🩸 Кровный Ткач залечивает раны отряда на 15% ОЗ после боя.[/color]")
		_update_party_hud()
		_update_hud()
	
	var e_name = localization.get_enemy_name(enemy_data.get("id", ""), enemy_data.get("name", ""))
	_log(localization.get_string("log_enemy_defeated") % [e_name, total_gold])
	
	# Room Cleared Banner
	if room_clear_banner:
		room_clear_banner.visible = true
	
	# Death fade of enemy
	var tw = create_tween()
	tw.tween_property(enemy_sprite, "modulate:a", 0.0, 0.35)
	
	# Player walks forward towards the loot chest
	if chest_sprite:
		chest_sprite.visible = (rebirth_3d == null)
	if rebirth_3d == null:
		walk_dust.emitting = true
	sound_manager.play_step()
	
	if rebirth_3d:
		rebirth_3d.animate_room_cleared(Callable())
	
	tw.tween_property(player_anchor, "position:x", 580.0, 0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		walk_dust.emitting = false
		_show_treasure_chest_modal()
	)

func _on_player_perished():
	sound_manager.play_death()
	_log(localization.get_string("log_player_died"))
	
	var tw = create_tween()
	tw.tween_property(player_sprite, "modulate", Color(0.2, 0.05, 0.05, 0.0), 0.6)
	tw.tween_callback(_enter_defeat_state)

# ==============================================================================
# DRAFT MODAL (REWARD CHOICES & SALVAGE OPTION)
# ==============================================================================

func _enter_draft_state():
	state = GameState.DRAFT
	battle_hud.visible = false
	top_hud.visible = true
	$Arena.visible = false
	defeat_modal.visible = false
	draft_modal.visible = true
	floor_banner.text = ""
	gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]
	current_draft_items = game_data.get_smart_draft_items(3, current_floor, equipped_items)
	_refresh_draft_ui()

func _refresh_draft_ui():
	draft_title.text = localization.get_string("draft_title") % current_floor
	draft_subtitle.text = localization.get_string("draft_subtitle")
	draft_gear_header.text = localization.get_string("draft_current_gear")
	
	if btn_skip_draft != null:
		var bonus_g = 20 + current_floor * 5
		btn_skip_draft.text = localization.get_string("btn_skip_draft") % bonus_g
	
	# Current equipped gear bar (5 slots)
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
	var is_fusion = item.get("is_fusion", false)
	var rarity_color = Color(1.0, 0.85, 0.2) if is_fusion else _get_rarity_color(rarity)
	
	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.12, 0.09, 0.16, 0.98) if is_fusion else Color(0.08, 0.07, 0.11, 0.98)
	card_style.border_color = rarity_color
	card_style.border_width_left = 3 if is_fusion else 2
	card_style.border_width_top = 3 if is_fusion else 2
	card_style.border_width_right = 3 if is_fusion else 2
	card_style.border_width_bottom = 3 if is_fusion else 2
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
	
	var rarity_disp = localization.get_rarity_name(rarity).to_upper()
	var slot_disp = localization.get_slot_name(slot).to_upper()
	var lbl_slot = Label.new()
	if is_fusion:
		lbl_slot.text = "[ ⚡ СЛИЯНИЕ / EVOLVE ⚡ ]"
		lbl_slot.modulate = Color(1.0, 0.9, 0.25)
	else:
		lbl_slot.text = "[ %s • %s ]" % [rarity_disp, slot_disp]
		lbl_slot.modulate = rarity_color
	lbl_slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_slot.add_theme_font_size_override("font_size", 12)
	vbox.add_child(lbl_slot)
	
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
	
	var itm_name = localization.get_item_name(item)
	var lbl_name = Label.new()
	lbl_name.text = itm_name
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_name.add_theme_font_size_override("font_size", 15)
	lbl_name.add_theme_color_override("font_color", Color(1.0, 0.95, 0.85))
	vbox.add_child(lbl_name)
	
	var itm_desc = localization.get_item_description(item)
	var lbl_desc = Label.new()
	lbl_desc.text = itm_desc
	lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.modulate = Color(0.72, 0.72, 0.78, 1)
	lbl_desc.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_desc)
	
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
	
	var cur_equipped = equipped_items.get(slot, null)
	var lbl_replace = Label.new()
	lbl_replace.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_replace.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_replace.add_theme_font_size_override("font_size", 11)
	if is_fusion:
		var target_name = item.get("fusion_target_name", "Реликвия")
		lbl_replace.text = "⚡ Слияние с: %s (Тир %d)" % [target_name, item.get("new_tier", 2)]
		lbl_replace.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	elif cur_equipped:
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
	if is_fusion:
		btn_select.text = "⚡ СОВЕРШИТЬ СЛИЯНИЕ ⚡"
		btn_select.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	else:
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
	var slot = item.get("slot", "Weapon")
	if item.get("is_fusion", false) and equipped_items.has(slot) and equipped_items[slot] != null:
		var fused = game_data.fuse_items(equipped_items[slot], item)
		equipped_items[slot] = fused
		sound_manager.play_fusion()
		_log("[color=gold]⚡ СЛИЯНИЕ РЕЛИКВИИ: %s улучшен до Тира %d! ⚡[/color]" % [fused.get("name", ""), fused.get("tier", 2)])
	else:
		sound_manager.play_equip()
		equipped_items[slot] = item
		var itm_name = localization.get_item_name(item)
		var slot_name = localization.get_slot_name(slot)
		_log(localization.get_string("log_equipped") % [itm_name, slot_name])
	
	current_floor += 1
	_calculate_player_stats()
	_update_player_visuals()
	
	var max_hp = player_stats.get("max_health", 100)
	var heal_amt = int(round(max_hp * 0.25))
	player_stats["current_health"] = min(max_hp, player_stats.get("current_health", max_hp) + heal_amt)
	_log(localization.get_string("log_heal_boon") % heal_amt)
	
	_start_floor_battle(true)
	if rebirth_3d:
		sound_manager.play_elevator()
		rebirth_3d.animate_elevator_ascent(Callable())

func _on_skip_draft_pressed():
	current_draft_items.clear()
	sound_manager.play_coin()
	
	var bonus_gold = 20 + current_floor * 5
	save_manager.add_gold(bonus_gold)
	run_gold_earned += bonus_gold
	gold_label.text = "%d %s" % [save_manager.save_data.get("PersistentGold", 0), localization.get_string("gold_unit")]
	
	current_floor += 1
	_calculate_player_stats()
	
	var max_hp = player_stats.get("max_health", 100)
	var heal_amt = int(round(max_hp * 0.25))
	player_stats["current_health"] = min(max_hp, player_stats.get("current_health", max_hp) + heal_amt)
	
	_log(localization.get_string("log_salvaged") % bonus_gold)
	_log(localization.get_string("log_heal_boon") % heal_amt)
	
	_start_floor_battle(true)
	if rebirth_3d:
		sound_manager.play_elevator()
		rebirth_3d.animate_elevator_ascent(Callable())

# ==============================================================================
# DEFEAT MODAL
# ==============================================================================

func _enter_defeat_state():
	state = GameState.DEFEAT
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
	player_soul = 0.0
	_calculate_player_stats()
	_update_player_visuals()
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
	
	if soul_bar != null:
		soul_bar.value = player_soul
		if player_soul >= 100.0:
			soul_label.text = "★ РАЗРЫВ ДУШИ ГОТОВ! ★"
			soul_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2))
		else:
			soul_label.text = "⚡ ДУША: %d%%" % int(player_soul)
			soul_label.add_theme_color_override("font_color", Color(1.0, 0.9, 1.0))
	
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

func _spawn_combat_badge(pos: Vector2, text: String, bg_color: Color, border_color: Color):
	var panel = PanelContainer.new()
	panel.position = pos - Vector2(100, 20)
	panel.custom_minimum_size = Vector2(200, 32)
	
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", style)
	
	var lbl = Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	panel.add_child(lbl)
	
	fx_layer.add_child(panel)
	
	panel.scale = Vector2(0.6, 0.6)
	panel.pivot_offset = Vector2(100, 16)
	var tw = create_tween()
	tw.tween_property(panel, "scale", Vector2(1.15, 1.15), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.08)
	tw.tween_property(panel, "position:y", panel.position.y - 32.0, 0.45).set_delay(0.2)
	tw.parallel().tween_property(panel, "modulate:a", 0.0, 0.4).set_delay(0.25)
	tw.tween_callback(panel.queue_free)

func _spawn_parry_spark(pos: Vector2):
	if tex_parry_spark == null:
		return
	var s = Sprite2D.new()
	s.texture = tex_parry_spark
	s.position = pos
	s.scale = Vector2(0.6, 0.6)
	s.modulate = Color(1.6, 1.4, 0.9, 1.0)
	fx_layer.add_child(s)
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(s, "scale", Vector2(1.35, 1.35), 0.15).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "rotation", randf_range(-0.5, 0.5), 0.15)
	tw.tween_property(s, "modulate:a", 0.0, 0.15)
	tw.chain().tween_callback(s.queue_free)

func _spawn_heavy_slash(pos: Vector2, flipped: bool = false, rot: float = 0.0):
	if tex_heavy_slash == null:
		_spawn_fx_slash(pos, flipped)
		return
	var s = Sprite2D.new()
	s.texture = tex_heavy_slash
	s.position = pos
	s.scale = Vector2(0.85, 0.85)
	s.flip_h = flipped
	s.rotation = rot
	s.modulate = Color(1.6, 1.3, 0.8, 1.0)
	fx_layer.add_child(s)
	
	var tw = create_tween().set_parallel(true)
	tw.tween_property(s, "scale", Vector2(1.4, 1.4), 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(s, "modulate:a", 0.0, 0.18)
	tw.chain().tween_callback(s.queue_free)

func _log(bbcode: String):
	combat_log.append_text(bbcode + "\n")
	var v_scroll = combat_log.get_v_scroll_bar()
	if v_scroll:
		v_scroll.value = v_scroll.max_value
