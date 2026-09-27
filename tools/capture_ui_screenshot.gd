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
			img.save_png("C:/Users/DocSk/Desktop/enhanced_camp_screen.png")
		
		# 2. Open Main Menu
		game._open_main_menu()
	elif step == 4:
		# Capture Main Menu
		var img = root.get_texture().get_image()
		if img != null:
			img.save_png("C:/Users/DocSk/Desktop/enhanced_main_menu.png")
		game.main_menu_modal.visible = false
		
		# 3. Open Compendium (Bestiary & Armory)
		game._open_compendium()
	elif step == 6:
		# Capture Compendium
		var img = root.get_texture().get_image()
		if img != null:
			img.save_png("C:/Users/DocSk/Desktop/enhanced_bestiary_screen.png")
		game.compendium_modal.visible = false
		
		# 4. Enter Battle with Full Modular Gear equipped
		game.equipped_items["Weapon"] = {"id": "blood_scythe", "slot": "Weapon", "rarity": "Legendary", "name": "Harvester of the Damned"}
		game.equipped_items["Armor"] = {"id": "bone_carapace", "slot": "Armor", "rarity": "Uncommon", "name": "Carapace of the Unburied"}
		game.equipped_items["Helmet"] = {"id": "crown_of_thorns", "slot": "Helmet", "rarity": "Cursed", "name": "Martyr's Jagged Crown"}
		game.equipped_items["OffHand"] = {"id": "weeping_shield", "slot": "OffHand", "rarity": "Rare", "name": "Buckler of the Weeping Mother"}
		game.equipped_items["Accessory"] = {"id": "heart_of_the_spire", "slot": "Accessory", "rarity": "Legendary", "name": "Heart of the Nether Citadels"}
		game.current_floor = 6
		game._start_floor_battle()
		game.player_soul = 85.0
		game._update_hud()
	elif step == 9:
		# Capture Battle Screen with Modular Gear, Soul Bar, Speed Toggle, and Archway
		var img = root.get_texture().get_image()
		if img != null:
			img.save_png("C:/Users/DocSk/Desktop/enhanced_battle_modular_gear.png")
		
		# 5. Defeat enemy and enter Draft
		game.enemy_data["current_health"] = 0
		game._enter_draft_state()
	elif step == 12:
		# Capture Draft Screen showing 3 cards + Skip & Salvage Button
		var img = root.get_texture().get_image()
		if img != null:
			img.save_png("C:/Users/DocSk/Desktop/enhanced_draft_skip_option.png")
		print(">>> ALL 5 ENHANCED SCREENSHOTS CAPTURED TO DESKTOP!")
		quit(0)
		return true
	return false
