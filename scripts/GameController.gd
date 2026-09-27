extends Node2D

enum GameState { CAMP, BATTLE, DRAFT, DEFEAT }

var state: GameState = GameState.CAMP

# References
var _sound_manager: Node
var _game_data: Node
var _save_manager: Node

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

# Visual Nodes
@onready var bg_texture = $BackgroundLayer/BackgroundTexture
@onready var ground_shadow = $BackgroundLayer/GroundShadow
@onready var player_sprite = $Arena/PlayerAnchor/PlayerSprite
@onready var player_anchor = $Arena/PlayerAnchor
@onready var enemy_anchor = $Arena/EnemyAnchor
@onready var enemy_sprite = $Arena/EnemyAnchor/EnemySprite
@onready var fx_layer = $Arena/FXLayer

# UI Nodes
@onready var ui_canvas = $UI
@onready var floor_banner = $UI/TopHUD/FloorBanner
@onready var gold_label = $UI/TopHUD/GoldDisplay/GoldLabel
@onready var player_hp_bar = $UI/BattleHUD/PlayerHPBar
@onready var player_hp_label = $UI/BattleHUD/PlayerHPBar/HPLabel
@onready var player_name_label = $UI/BattleHUD/PlayerHPBar/NameLabel
@onready var enemy_hp_bar = $UI/BattleHUD/EnemyHPBar
@onready var enemy_hp_label = $UI/BattleHUD/EnemyHPBar/HPLabel
@onready var enemy_name_label = $UI/BattleHUD/EnemyHPBar/NameLabel
@onready var combat_log = $UI/BattleHUD/CombatLogPanel/CombatLog
@onready var equip_icons_container = $UI/BattleHUD/EquippedGearBar

# Modals
@onready var camp_panel = $UI/CampPanel
@onready var altar_gold_label = $UI/CampPanel/VBox/Header/AltarGoldLabel
@onready var upgrades_container = $UI/CampPanel/VBox/ScrollContainer/UpgradesVBox
@onready var btn_ascend = $UI/CampPanel/VBox/BtnAscend

@onready var draft_modal = $UI/DraftModal
@onready var draft_cards_container = $UI/DraftModal/VBox/CardsContainer
@onready var draft_title = $UI/DraftModal/VBox/DraftTitle

@onready var defeat_modal = $UI/DefeatModal
@onready var defeat_summary_label = $UI/DefeatModal/VBox/SummaryLabel
@onready var btn_return_altar = $UI/DefeatModal/VBox/BtnReturnAltar

# Game Logic Variables
var current_floor: int = 1
var player_stats: Dictionary = {}
var enemy_data: Dictionary = {}
var equipped_items: Dictionary = {} # slot -> item_dict

var player_attack_cooldown: float = 0.0
var enemy_attack_cooldown: float = 0.0

var player_base_pos: Vector2
var enemy_base_pos: Vector2

# Textures
var tex_spire_interior: Texture2D
var tex_camp_altar: Texture2D
var tex_player_wanderer: Texture2D
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
	var img = Image.load_from_file(global_path)
	if img != null:
		return ImageTexture.create_from_image(img)
	return null

func _ready():
	_load_textures()
	player_base_pos = player_anchor.position
	enemy_base_pos = enemy_anchor.position
	
	btn_ascend.pressed.connect(_on_ascend_pressed)
	btn_return_altar.pressed.connect(_on_return_altar_pressed)
	
	_calculate_player_stats()
	_enter_camp_state()

func _load_textures():
	tex_spire_interior = _safe_load_tex("res://assets/textures/spire_interior.png")
	tex_camp_altar = _safe_load_tex("res://assets/textures/camp_altar.png")
	tex_player_wanderer = _safe_load_tex("res://assets/textures/player_wanderer.png")
	tex_enemy_ghoul = _safe_load_tex("res://assets/textures/enemy_ghoul.png")
	tex_enemy_cultist = _safe_load_tex("res://assets/textures/enemy_cultist.png")
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
	$UI/TopHUD/GoldDisplay/GoldIcon.texture = _safe_load_tex("res://assets/ui/gold_coin.png")
	bg_texture.texture = tex_camp_altar

func _process(delta: float):
	# Idle breathing animations for units
	var time = Time.get_ticks_msec() / 1000.0
	player_sprite.position.y = sin(time * 2.5) * 6.0
	enemy_sprite.position.y = cos(time * 2.8) * 7.0
	
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
# STATE TRANSITIONS
# ==============================================================================

func _enter_camp_state():
	state = GameState.CAMP
	bg_texture.texture = tex_camp_altar
	camp_panel.visible = true
	draft_modal.visible = false
	defeat_modal.visible = false
	$UI/BattleHUD.visible = false
	$Arena.visible = false
	
	_refresh_camp_ui()

func _refresh_camp_ui():
	var gold = save_manager.save_data.get("PersistentGold", 0)
	var max_floor = save_manager.save_data.get("HighestFloorReached", 1)
	altar_gold_label.text = "Gold: %d   |   Deepest Descent: Floor %d" % [gold, max_floor]
	gold_label.text = "%d" % gold
	
	# Populate upgrade items
	for child in upgrades_container.get_children():
		child.queue_free()
	
	for upg in game_data.meta_upgrades:
		var type_name = upg.get("type", "")
		var rank = save_manager.get_upgrade_rank(type_name)
		var base_cost = int(upg.get("baseCost", 50))
		var cost = base_cost * (rank + 1)
		
		var panel = PanelContainer.new()
		panel.custom_minimum_size = Vector2(580, 52)
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 15)
		panel.add_child(hbox)
		
		var lbl_name = Label.new()
		lbl_name.custom_minimum_size = Vector2(240, 0)
		lbl_name.text = "%s (Rank %d)\n%s" % [upg.get("name", ""), rank, upg.get("statBonus", "")]
		lbl_name.add_theme_font_size_override("font_size", 13)
		hbox.add_child(lbl_name)
		
		var spacer = Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(spacer)
		
		var btn_upg = Button.new()
		btn_upg.custom_minimum_size = Vector2(140, 36)
		btn_upg.text = "Upgrade (%d G)" % cost
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
	equipped_items.clear()
	_calculate_player_stats()
	_start_floor_battle()

func _start_floor_battle():
	state = GameState.BATTLE
	bg_texture.texture = tex_spire_interior
	camp_panel.visible = false
	draft_modal.visible = false
	defeat_modal.visible = false
	$UI/BattleHUD.visible = true
	$Arena.visible = true
	
	enemy_data = game_data.get_enemy_for_floor(current_floor)
	_setup_enemy_visuals()
	
	# Attack timers
	player_attack_cooldown = 0.5
	enemy_attack_cooldown = 1.0
	
	# HUD Setup
	var is_boss = enemy_data.get("isBoss", false)
	floor_banner.text = "FLOOR %d: %s" % [current_floor, enemy_data.get("name", "").to_upper()]
	if is_boss:
		floor_banner.text = "★ BOSS FLOOR %d: %s ★" % [current_floor, enemy_data.get("name", "").to_upper()]
	
	gold_label.text = "%d" % save_manager.save_data.get("PersistentGold", 0)
	
	player_name_label.text = "Cursed Wanderer (You)"
	enemy_name_label.text = enemy_data.get("name", "Enemy")
	
	_update_hud()
	_refresh_equipped_icons()
	_log("[color=#c0a060]=== Entered Floor %d: %s ===[/color]" % [current_floor, enemy_data.get("name", "")])

func _setup_enemy_visuals():
	var enemy_id = enemy_data.get("id", "")
	var is_boss = enemy_data.get("isBoss", false)
	
	if is_boss:
		if current_floor >= 20:
			enemy_sprite.texture = tex_boss_amalgam
		else:
			enemy_sprite.texture = tex_boss_malgorath
		enemy_sprite.scale = Vector2(0.95, 0.95)
	elif enemy_id == "hollow_knight" or current_floor >= 5:
		enemy_sprite.texture = tex_enemy_cultist
		enemy_sprite.scale = Vector2(0.75, 0.75)
	else:
		enemy_sprite.texture = tex_enemy_ghoul
		enemy_sprite.scale = Vector2(0.75, 0.75)
	
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
	if res.dodged:
		_spawn_floating_text(enemy_anchor.position + Vector2(0, -140), "DODGED!", Color(0.4, 0.8, 1.0))
		_log("%s dodged your strike!" % enemy_data.get("name", "Enemy"))
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
		_spawn_floating_text(enemy_anchor.position + Vector2(0, -140), "-%d CRIT!" % dmg, Color(1.0, 0.85, 0.1), 1.4)
		_log("[b]CRITICAL STRIKE![/b] You hit %s for [color=crimson][b]%d[/b][/color] dmg!" % [enemy_data.get("name", ""), dmg])
	else:
		sound_manager.play_hit()
		_spawn_floating_text(enemy_anchor.position + Vector2(0, -140), "-%d" % dmg, Color(1.0, 0.4, 0.4))
		_log("You hit %s for [color=crimson]%d[/color] dmg." % [enemy_data.get("name", ""), dmg])
	
	if lifesteal > 0:
		player_stats["current_health"] = min(player_stats["max_health"], player_stats["current_health"] + lifesteal)
		_spawn_floating_text(player_anchor.position + Vector2(0, -140), "+%d HP" % lifesteal, Color(0.3, 1.0, 0.4))
	
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
	if res.dodged:
		_spawn_floating_text(player_anchor.position + Vector2(0, -140), "DODGED!", Color(0.4, 0.8, 1.0))
		_log("You dodged %s's blow!" % enemy_data.get("name", "Enemy"))
		return
	
	var dmg = res.damage
	player_stats["current_health"] = max(0, player_stats["current_health"] - dmg)
	
	_shake_node(player_anchor, 6.0)
	_flash_node(player_sprite, Color(2, 0.4, 0.4, 1))
	_spawn_blood_burst(player_anchor.position + Vector2(0, -100))
	sound_manager.play_hit()
	
	_spawn_floating_text(player_anchor.position + Vector2(0, -140), "-%d" % dmg, Color(1.0, 0.2, 0.2))
	_log("%s struck you for [color=red]%d[/color] dmg." % [enemy_data.get("name", ""), dmg])
	
	_update_hud()
	
	if player_stats["current_health"] <= 0:
		_on_player_perished()

func _on_enemy_defeated():
	sound_manager.play_coin()
	var base_gold = int(enemy_data.get("gold_reward", 15))
	var gold_mult = float(player_stats.get("gold_multiplier", 1.0))
	var total_gold = int(round(base_gold * gold_mult))
	
	save_manager.add_gold(total_gold)
	save_manager.record_run_completion(current_floor)
	gold_label.text = "%d" % save_manager.save_data.get("PersistentGold", 0)
	
	_log("[color=gold]★ %s vanquished! Gathered +%d Gold! ★[/color]" % [enemy_data.get("name", ""), total_gold])
	
	# Death fade of enemy
	var tw = create_tween()
	tw.tween_property(enemy_sprite, "modulate:a", 0.0, 0.4)
	tw.tween_callback(_enter_draft_state)

func _on_player_perished():
	sound_manager.play_death()
	_log("[color=crimson][b]YOU HAVE PERISHED IN THE SPIRE.[/b][/color]")
	
	# Player dissolution
	var tw = create_tween()
	tw.tween_property(player_sprite, "modulate", Color(0.2, 0.05, 0.05, 0.0), 0.6)
	tw.tween_callback(_enter_defeat_state)

# ==============================================================================
# DRAFT MODAL (3 ITEMS ON FLOOR PASS)
# ==============================================================================

func _enter_draft_state():
	state = GameState.DRAFT
	draft_modal.visible = true
	draft_title.text = "FLOOR %d CLEARED! CHOOSE YOUR REWARD" % current_floor
	
	for child in draft_cards_container.get_children():
		child.queue_free()
	
	var offered_items = game_data.get_random_items(3, current_floor)
	for item in offered_items:
		var card = _create_draft_card(item)
		draft_cards_container.add_child(card)

func _create_draft_card(item: Dictionary) -> Control:
	var container = PanelContainer.new()
	container.custom_minimum_size = Vector2(250, 360)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	container.add_child(vbox)
	
	var slot = item.get("slot", "Weapon")
	var rarity = item.get("rarity", "Common")
	var rarity_color = _get_rarity_color(rarity)
	
	# Rarity & Slot Header
	var lbl_slot = Label.new()
	lbl_slot.text = "[ %s - %s ]" % [rarity.to_upper(), slot.to_upper()]
	lbl_slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_slot.modulate = rarity_color
	lbl_slot.add_theme_font_size_override("font_size", 12)
	vbox.add_child(lbl_slot)
	
	# Icon
	var icon_tex = item_icons.get(slot, null)
	if icon_tex:
		var tex_rect = TextureRect.new()
		tex_rect.texture = icon_tex
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.custom_minimum_size = Vector2(80, 80)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(tex_rect)
	
	# Name
	var lbl_name = Label.new()
	lbl_name.text = item.get("name", "Unknown Relic")
	lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_name.add_theme_font_size_override("font_size", 14)
	vbox.add_child(lbl_name)
	
	# Description
	var lbl_desc = Label.new()
	lbl_desc.text = item.get("description", "")
	lbl_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.modulate = Color(0.7, 0.7, 0.75, 1)
	lbl_desc.add_theme_font_size_override("font_size", 11)
	vbox.add_child(lbl_desc)
	
	# Stats breakdown
	var stats_text = ""
	var s = item.get("stats", {})
	for k in s.keys():
		var val = s[k]
		if typeof(val) == TYPE_FLOAT and val < 1.0:
			stats_text += "+%d%% %s\n" % [int(val * 100), k]
		else:
			stats_text += "+%s %s\n" % [str(val), k]
	
	var lbl_stats = Label.new()
	lbl_stats.text = stats_text
	lbl_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_stats.modulate = Color(0.3, 0.9, 0.5, 1)
	lbl_stats.add_theme_font_size_override("font_size", 12)
	vbox.add_child(lbl_stats)
	
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	var btn_select = Button.new()
	btn_select.text = "EQUIP RELIC"
	btn_select.custom_minimum_size = Vector2(0, 36)
	btn_select.pressed.connect(func(): _on_item_drafted(item))
	vbox.add_child(btn_select)
	
	return container

func _get_rarity_color(rarity: String) -> Color:
	match rarity:
		"Common": return Color(0.8, 0.8, 0.8)
		"Uncommon": return Color(0.3, 0.85, 0.4)
		"Rare": return Color(0.3, 0.6, 1.0)
		"Epic": return Color(0.75, 0.35, 0.95)
		"Legendary": return Color(1.0, 0.75, 0.2)
		"Cursed": return Color(0.9, 0.2, 0.3)
		_: return Color(0.8, 0.8, 0.8)

func _on_item_drafted(item: Dictionary):
	sound_manager.play_equip()
	var slot = item.get("slot", "Weapon")
	equipped_items[slot] = item
	
	_calculate_player_stats()
	_log("[color=#60b0ff]Equipped: %s in %s slot.[/color]" % [item.get("name", ""), slot])
	
	current_floor += 1
	_start_floor_battle()

# ==============================================================================
# DEFEAT MODAL
# ==============================================================================

func _enter_defeat_state():
	state = GameState.DEFEAT
	defeat_modal.visible = true
	var gold = save_manager.save_data.get("PersistentGold", 0)
	var max_floor = save_manager.save_data.get("HighestFloorReached", 1)
	
	defeat_summary_label.text = """You met your end on Floor %d.
Deepest Ascent: Floor %d
All ephemeral equipment has dissolved into ash.
Gold Preserved: %d G.""" % [current_floor, max_floor, gold]

func _on_return_altar_pressed():
	sound_manager.play_click()
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
	
	var p_cur = player_stats.get("current_health", 0)
	var p_max = player_stats.get("max_health", 100)
	player_hp_bar.max_value = p_max
	player_hp_bar.value = p_cur
	player_hp_label.text = "%d / %d HP  (Armor: %d | DMG: %d)" % [p_cur, p_max, player_stats.get("armor", 0), player_stats.get("attack_damage", 0)]
	
	var e_cur = enemy_data.get("current_health", 0)
	var e_max = enemy_data.get("max_health", 100)
	enemy_hp_bar.max_value = e_max
	enemy_hp_bar.value = e_cur
	enemy_hp_label.text = "%d / %d HP  (Armor: %d | DMG: %d)" % [e_cur, e_max, enemy_data.get("armor", 0), enemy_data.get("attack_damage", 0)]

func _refresh_equipped_icons():
	for child in equip_icons_container.get_children():
		child.queue_free()
	
	for slot in ["Weapon", "Armor", "Helmet", "OffHand", "Accessory"]:
		var itm = equipped_items.get(slot, null)
		var tex_rect = TextureRect.new()
		tex_rect.custom_minimum_size = Vector2(48, 48)
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		
		if itm:
			tex_rect.texture = item_icons.get(slot, null)
			tex_rect.modulate = _get_rarity_color(itm.get("rarity", "Common"))
			tex_rect.tooltip_text = "%s (%s)\n%s" % [itm.get("name", ""), slot, itm.get("description", "")]
		else:
			tex_rect.texture = item_icons.get(slot, null)
			tex_rect.modulate = Color(0.3, 0.3, 0.35, 0.4)
			tex_rect.tooltip_text = "Empty %s Slot" % slot
		
		equip_icons_container.add_child(tex_rect)

# ==============================================================================
# VISUAL EFFECTS (SHAKE, FLASH, FLOATING NUMBERS, PARTICLES)
# ==============================================================================

func _shake_node(node: Node2D, intensity: float):
	var orig = node.position
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
	# Auto-scroll to bottom
	var v_scroll = combat_log.get_v_scroll_bar()
	if v_scroll:
		v_scroll.value = v_scroll.max_value
