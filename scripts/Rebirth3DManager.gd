extends Node

# Manages the 2.5D Camera, 3D Scene Architecture, Skeletal Animation Rigs,
# Environment Stages (Camp, Gate, Corridor, Elevator, Chest), and Party Visuals.

var viewport_container: SubViewportContainer
var sub_viewport: SubViewport
var main_3d: Node3D
var cam_3d: Camera3D

# Environment Groups
var env_node: Node3D
var camp_group: Node3D
var wall_mesh: MeshInstance3D
var floor_mesh: MeshInstance3D
var iron_gate: Node3D
var elevator: Node3D
var chest: Node3D
var torches_group: Node3D
var campfire_light: OmniLight3D
var chest_light: OmniLight3D
var elevator_light: OmniLight3D

# Squad and Enemy slots
var party_slots: Dictionary = {} # "bulwark", "wanderer", "nightshade", "bloodweaver" -> Marker3D
var party_models: Dictionary = {} # role_id -> Node3D instance
var party_anims: Dictionary = {} # role_id -> AnimationPlayer

var enemy_slot: Marker3D
var enemy_model: Node3D = null
var enemy_anim: AnimationPlayer = null

# Base local positions for party formation
const FORMATION_POS = {
	"bulwark": Vector3(-0.2, 0.0, 0.2),      # Frontline Tank
	"wanderer": Vector3(-1.4, 0.0, 0.0),     # Midline Hero DPS
	"nightshade": Vector3(-2.6, 0.0, -0.2),  # Flank Thief
	"bloodweaver": Vector3(-3.8, 0.0, -0.3)  # Backline Cleric
}

const MODEL_PATHS = {
	"bulwark": "res://assets/models/tank_bulwark.gltf",
	"wanderer": "res://assets/models/hero_wanderer.gltf",
	"nightshade": "res://assets/models/thief_nightshade.gltf",
	"bloodweaver": "res://assets/models/cleric_bloodweaver.gltf"
}

func setup_3d_world(parent_node: Node2D):
	# Create SubViewportContainer to display 3D under UI
	viewport_container = SubViewportContainer.new()
	viewport_container.size = Vector2(1280, 720)
	viewport_container.stretch = true
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport_container.z_index = -5
	parent_node.add_child(viewport_container)
	parent_node.move_child(viewport_container, 1)

	sub_viewport = SubViewport.new()
	sub_viewport.size = Vector2i(1280, 720)
	sub_viewport.handle_input_locally = false
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport_container.add_child(sub_viewport)

	var scene_res = load("res://scenes/Main3D.tscn")
	if scene_res:
		main_3d = scene_res.instantiate()
		sub_viewport.add_child(main_3d)
	else:
		push_error("Could not load res://scenes/Main3D.tscn")
		return

	_bind_3d_references()
	_instantiate_party_characters()

func _bind_3d_references():
	if main_3d == null: return
	cam_3d = main_3d.get_node_or_null("Camera25D")
	env_node = main_3d.get_node_or_null("Environment")

	if env_node:
		camp_group = env_node.get_node_or_null("CampGroup")
		wall_mesh = env_node.get_node_or_null("BackWall")
		floor_mesh = env_node.get_node_or_null("Floor")
		iron_gate = env_node.get_node_or_null("IronGate")
		elevator = env_node.get_node_or_null("ElevatorPlatform")
		chest = env_node.get_node_or_null("TreasureChest")
		torches_group = env_node.get_node_or_null("Torches")

		if camp_group:
			campfire_light = camp_group.get_node_or_null("CampfireLight")
		if chest:
			chest_light = chest.get_node_or_null("ChestLight")
		if elevator:
			elevator_light = elevator.get_node_or_null("ElevatorLight")

	var squad_group = main_3d.get_node_or_null("PartySquad")
	if squad_group:
		party_slots["bulwark"] = squad_group.get_node_or_null("TankSlot")
		party_slots["wanderer"] = squad_group.get_node_or_null("HeroSlot")
		party_slots["nightshade"] = squad_group.get_node_or_null("ThiefSlot")
		party_slots["bloodweaver"] = squad_group.get_node_or_null("ClericSlot")

	var e_group = main_3d.get_node_or_null("EnemyWave")
	if e_group:
		enemy_slot = e_group.get_node_or_null("EnemySlot1")

func _instantiate_party_characters():
	for role in MODEL_PATHS:
		var path = MODEL_PATHS[role]
		var slot = party_slots.get(role, null)
		if slot == null: continue

		var res = load(path)
		if res:
			var model_inst = res.instantiate()
			model_inst.name = "Model_" + role
			slot.add_child(model_inst)
			party_models[role] = model_inst

			var anim_player = _find_anim_player(model_inst)
			if anim_player:
				party_anims[role] = anim_player
				anim_player.play("idle")

func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for c in node.get_children():
		var res = _find_anim_player(c)
		if res != null:
			return res
	return null

func set_companion_active(role: String, active: bool):
	if party_models.has(role) and party_models[role] != null:
		party_models[role].visible = active

# =============================================================================
# ENVIRONMENT & CAMERA STAGE TRANSITIONS
# =============================================================================

func set_stage_camp():
	if camp_group: camp_group.visible = true
	if wall_mesh: wall_mesh.visible = false
	if elevator: elevator.visible = false
	if chest: chest.visible = false
	if iron_gate:
		iron_gate.visible = true
		_play_gate_anim("idle")

	if cam_3d:
		cam_3d.position = Vector3(-0.6, 1.85, 5.2)
		cam_3d.rotation_degrees = Vector3(-5.0, 0.0, 0.0)

	# Reset party formation near campfire (positioned nicely on right 60% of screen)
	for role in party_slots:
		var slot = party_slots[role]
		if slot:
			slot.position = FORMATION_POS[role] - Vector3(1.2, 0.0, 0.0)
		play_companion_anim(role, "idle")

	if enemy_model:
		enemy_model.visible = false

func animate_ascent_through_gate(callback: Callable):
	# 1. Gate portcullis lifts up
	_play_gate_anim("open")

	# 2. Party walks forward through gate into Spire corridor
	for role in party_slots:
		play_companion_anim(role, "walk")

	var tw = main_3d.create_tween()
	# Camera tracks smoothly to battle position
	tw.tween_property(cam_3d, "position:x", 0.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	for role in party_slots:
		var slot = party_slots[role]
		if slot:
			tw.parallel().tween_property(slot, "position:x", FORMATION_POS[role].x, 1.2)

	tw.tween_callback(func():
		for role in party_slots:
			var slot = party_slots[role]
			if slot:
				slot.position = FORMATION_POS[role]
			play_companion_anim(role, "idle")
		if iron_gate:
			iron_gate.visible = false
		if callback.is_valid():
			callback.call()
	)

func set_stage_battle(floor_num: int, enemy_id: String, is_boss: bool):
	if camp_group: camp_group.visible = false
	if wall_mesh: wall_mesh.visible = true
	if elevator: elevator.visible = false
	if chest:
		chest.visible = false
		_play_chest_anim("idle")

	if cam_3d:
		cam_3d.position = Vector3(0.0, 1.95, 5.9)
		cam_3d.rotation_degrees = Vector3(-5.5, 0.0, 0.0)

	# Reset party slots to battle formation
	for role in party_slots:
		var slot = party_slots[role]
		if slot:
			slot.position = FORMATION_POS[role]
		play_companion_anim(role, "idle")

	_spawn_enemy_model(floor_num, enemy_id, is_boss)

func _spawn_enemy_model(floor_num: int, enemy_id: String, is_boss: bool):
	if enemy_slot == null: return

	# Clean up previous enemy
	if enemy_model != null:
		enemy_slot.remove_child(enemy_model)
		enemy_model.queue_free()
		enemy_model = null
		enemy_anim = null

	var gltf_name = "enemy_skeleton"
	if is_boss:
		if floor_num >= 30 or enemy_id == "boss_valthor":
			gltf_name = "boss_valthor"
		elif floor_num >= 20 or enemy_id == "boss_flesh_amalgam":
			gltf_name = "boss_amalgam"
		else:
			gltf_name = "gargoyle_boss"
	elif enemy_id == "spire_imp" or floor_num == 2:
		gltf_name = "enemy_imp"
	elif enemy_id == "blood_cultist" or enemy_id == "cursed_inquisitor":
		gltf_name = "enemy_cultist"
	elif enemy_id == "hollow_knight" or floor_num == 5:
		gltf_name = "enemy_knight"
	elif enemy_id == "feeble_skeleton" or floor_num == 1:
		gltf_name = "enemy_skeleton"
	else:
		gltf_name = "enemy_knight"

	var path = "res://assets/models/%s.gltf" % gltf_name
	var res = load(path)
	if res:
		enemy_model = res.instantiate()
		enemy_slot.add_child(enemy_model)
		enemy_anim = _find_anim_player(enemy_model)
		if enemy_anim:
			enemy_anim.play("idle")
		enemy_model.visible = true

func animate_room_cleared(callback: Callable):
	play_enemy_anim("death")
	if chest:
		chest.visible = true
		_play_chest_anim("idle")

	# Squad walks forward to chest
	for role in party_slots:
		play_companion_anim(role, "walk")

	var tw = main_3d.create_tween()
	for role in party_slots:
		var slot = party_slots[role]
		if slot:
			tw.parallel().tween_property(slot, "position:x", slot.position.x + 1.8, 0.85).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tw.tween_callback(func():
		for role in party_slots:
			play_companion_anim(role, "idle")
		if callback.is_valid():
			callback.call()
	)

func animate_thief_lockpick(callback: Callable):
	var thief_slot = party_slots.get("nightshade", null)
	if thief_slot != null:
		play_companion_anim("nightshade", "attack") # dextrous lockpick gesture

	var tw = main_3d.create_tween()
	tw.tween_interval(0.35)
	tw.tween_callback(func():
		_play_chest_anim("open")
		if chest_light:
			chest_light.light_energy = 3.5
			var tw_l = main_3d.create_tween()
			tw_l.tween_property(chest_light, "light_energy", 1.8, 0.8)
	)
	tw.tween_interval(0.5)
	tw.tween_callback(func():
		play_companion_anim("nightshade", "idle")
		if callback.is_valid():
			callback.call()
	)

func animate_elevator_ascent(callback: Callable):
	if elevator:
		elevator.visible = true
		if elevator_light:
			elevator_light.light_energy = 3.0

	# Squad walks onto elevator platform
	for role in party_slots:
		play_companion_anim(role, "walk")

	var tw = main_3d.create_tween()
	for role in party_slots:
		var slot = party_slots[role]
		if slot:
			tw.parallel().tween_property(slot, "position:x", slot.position.x + 3.0, 0.9)

	# Elevator rises vertically
	tw.chain().tween_callback(func():
		for role in party_slots:
			play_companion_anim(role, "idle")
	)
	if elevator:
		tw.parallel().tween_property(elevator, "position:y", 5.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	for role in party_slots:
		var slot = party_slots[role]
		if slot:
			tw.parallel().tween_property(slot, "position:y", 5.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(cam_3d, "position:y", cam_3d.position.y + 4.0, 1.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tw.tween_callback(func():
		if elevator:
			elevator.position = Vector3(6.5, 0.0, 0.0)
			elevator.visible = false
		for role in party_slots:
			var slot = party_slots[role]
			if slot:
				slot.position = FORMATION_POS[role]
				play_companion_anim(role, "idle")
		if cam_3d:
			cam_3d.position = Vector3(0.0, 1.95, 5.9)
		if callback.is_valid():
			callback.call()
	)

# =============================================================================
# COMBAT ANIMATIONS & SYNERGY VISUALS
# =============================================================================

func play_companion_anim(role: String, anim_name: String):
	if party_anims.has(role) and party_anims[role] != null:
		var player: AnimationPlayer = party_anims[role]
		if player.has_animation(anim_name):
			player.play(anim_name)
		elif player.has_animation("idle"):
			player.play("idle")

func play_enemy_anim(anim_name: String):
	if enemy_anim != null:
		if enemy_anim.has_animation(anim_name):
			enemy_anim.play(anim_name)
		elif enemy_anim.has_animation("idle"):
			enemy_anim.play("idle")

func _play_gate_anim(anim_name: String):
	if iron_gate:
		var ap = _find_anim_player(iron_gate)
		if ap and ap.has_animation(anim_name):
			ap.play(anim_name)

func _play_chest_anim(anim_name: String):
	if chest:
		var ap = _find_anim_player(chest)
		if ap and ap.has_animation(anim_name):
			ap.play(anim_name)

func animate_companion_attack(role: String, target_pos: Vector3, is_crit: bool):
	var slot = party_slots.get(role, null)
	if slot == null: return
	var base_pos = FORMATION_POS[role]

	play_companion_anim(role, "attack")

	# Quick lunge and return
	var tw = main_3d.create_tween()
	tw.tween_property(slot, "position:x", base_pos.x + 0.65, 0.10)
	tw.tween_property(slot, "position:x", base_pos.x, 0.15).set_delay(0.08)
	tw.tween_callback(func():
		play_companion_anim(role, "idle")
	)

func animate_tank_taunt():
	var slot = party_slots.get("bulwark", null)
	if slot == null: return
	play_companion_anim("bulwark", "block") # Raises tower shield

	var tw = main_3d.create_tween()
	tw.tween_property(slot, "position:x", FORMATION_POS["bulwark"].x + 0.4, 0.12)
	tw.tween_property(slot, "position:x", FORMATION_POS["bulwark"].x, 0.15).set_delay(0.4)
	tw.tween_callback(func():
		play_companion_anim("bulwark", "idle")
	)

func animate_hero_soul_cleave():
	var slot = party_slots.get("wanderer", null)
	if slot == null: return
	play_companion_anim("wanderer", "attack")

	var tw = main_3d.create_tween()
	tw.tween_property(slot, "position:x", FORMATION_POS["wanderer"].x + 1.2, 0.12)
	tw.tween_property(slot, "position:x", FORMATION_POS["wanderer"].x, 0.2).set_delay(0.15)
	tw.tween_callback(func():
		play_companion_anim("wanderer", "idle")
	)

func animate_thief_backstab():
	var slot = party_slots.get("nightshade", null)
	if slot == null or enemy_slot == null: return
	var base_pos = FORMATION_POS["nightshade"]

	# Teleport behind enemy
	play_companion_anim("nightshade", "attack")
	var tw = main_3d.create_tween()
	tw.tween_property(slot, "position", enemy_slot.position + Vector3(0.9, 0.0, -0.1), 0.08)
	tw.tween_interval(0.18)
	tw.tween_property(slot, "position", base_pos, 0.12)
	tw.tween_callback(func():
		play_companion_anim("nightshade", "idle")
	)

func animate_cleric_heal(target_role: String):
	play_companion_anim("bloodweaver", "cast_heal")
	var tw = main_3d.create_tween()
	tw.tween_interval(0.6)
	tw.tween_callback(func():
		play_companion_anim("bloodweaver", "idle")
	)

func animate_enemy_attack():
	if enemy_slot == null: return
	play_enemy_anim("attack")
	var tw = main_3d.create_tween()
	tw.tween_property(enemy_slot, "position:x", 1.8 - 0.7, 0.10)
	tw.tween_property(enemy_slot, "position:x", 1.8, 0.15).set_delay(0.08)
	tw.tween_callback(func():
		play_enemy_anim("idle")
	)
