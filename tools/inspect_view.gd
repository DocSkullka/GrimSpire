extends SceneTree

func _init():
	var scene = load("res://scenes/MainGame.tscn")
	var game = scene.instantiate()
	root.add_child(game)

func _process(delta: float) -> bool:
	var game = root.get_child(0)
	print("Hiding 2D layers...")
	game.bg_texture.visible = false
	game.get_node("BackgroundLayer/GroundShadow").visible = false
	game.player_sprite.visible = false
	game.enemy_sprite.visible = false
	if game.weapon_sprite: game.weapon_sprite.visible = false
	if game.player_shadow: game.player_shadow.visible = false
	if game.enemy_shadow: game.enemy_shadow.visible = false
	if game.archway_sprite: game.archway_sprite.visible = false
	if game.chest_sprite: game.chest_sprite.visible = false
	
	# Test camp 3D visibility
	print("Rebirth 3D main_3d: ", game.rebirth_3d.main_3d != null)
	print("Rebirth 3D cam_3d: ", game.rebirth_3d.cam_3d != null)
	if game.rebirth_3d.cam_3d:
		print("cam_3d current: ", game.rebirth_3d.cam_3d.current)
		print("cam_3d pos: ", game.rebirth_3d.cam_3d.position)
	
	# Check 3D party models in sub_viewport
	for role in game.rebirth_3d.party_models:
		var model = game.rebirth_3d.party_models[role]
		var ap = game.rebirth_3d.party_anims.get(role, null)
		var anims = ap.get_animation_list() if ap else []
		print("Party model ", role, ": ", model != null, " anims: ", anims)
	
	# Switch to battle
	game._start_floor_battle()
	game.player_sprite.visible = false
	game.enemy_sprite.visible = false
	game.bg_texture.visible = false
	
	print("After battle start:")
	print("Enemy 3D model: ", game.rebirth_3d.enemy_model != null)
	if game.rebirth_3d.enemy_model:
		var e_ap = game.rebirth_3d.enemy_anim
		var e_anims = e_ap.get_animation_list() if e_ap else []
		print("Enemy 3D visible: ", game.rebirth_3d.enemy_model.visible, " anims: ", e_anims)
		print("Enemy 3D parent: ", game.rebirth_3d.enemy_model.get_parent().name)
	
	# Capture image
	var vp = game.rebirth_3d.sub_viewport
	if vp:
		var img = vp.get_texture().get_image()
		if img:
			img.save_png("res://tools/rebirth_3d_test_render.png")
			print("Saved 3D viewport render to tools/rebirth_3d_test_render.png (size: ", img.get_size(), ")")
	
	quit(0)
	return true
