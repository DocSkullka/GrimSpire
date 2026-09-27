extends SceneTree

var game: Node2D = null
var step: int = 0

func _init():
	var scene_res = load("res://scenes/MainGame.tscn")
	game = scene_res.instantiate()
	root.add_child(game)

func _process(delta: float) -> bool:
	step += 1
	if step == 2:
		# 1. Capture Camp
		var img = root.get_texture().get_image()
		if img != null:
			img.save_png("C:/Users/DocSk/Desktop/new_ui_camp_screen.png")
		
		# 2. Open Settings
		game._toggle_settings_modal()
	elif step == 4:
		# Capture Settings Modal
		var img = root.get_texture().get_image()
		if img != null:
			img.save_png("C:/Users/DocSk/Desktop/new_ui_settings_screen.png")
		game._toggle_settings_modal()
		
		# 3. Enter Battle
		game._on_ascend_pressed()
	elif step == 7:
		# Capture Battle Screen
		var img = root.get_texture().get_image()
		if img != null:
			img.save_png("C:/Users/DocSk/Desktop/new_ui_battle_screen.png")
		
		# 4. Defeat enemy and enter Draft
		game.enemy_data["current_health"] = 0
		game._enter_draft_state()
	elif step == 10:
		# Capture Draft Screen
		var img = root.get_texture().get_image()
		if img != null:
			img.save_png("C:/Users/DocSk/Desktop/new_ui_reward_screen.png")
		
		# 5. Trigger Defeat
		game.run_gold_earned = 45
		game.player_stats["current_health"] = 0
		game._enter_defeat_state()
	elif step == 13:
		# Capture Defeat Screen
		var img = root.get_texture().get_image()
		if img != null:
			img.save_png("C:/Users/DocSk/Desktop/new_ui_defeat_screen.png")
		print(">>> ALL SCREENSHOTS CAPTURED INCLUDING DEFEAT SCREEN!")
		quit(0)
		return true
	return false
