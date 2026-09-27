extends Node

var save_data: Dictionary = {
	"PersistentGold": 0,
	"HighestFloorReached": 1,
	"TotalRunsPlayed": 0,
	"Language": "ru",
	"MasterVolume": 0.8,
	"SfxVolume": 0.8,
	"MusicVolume": 0.5,
	"Fullscreen": false,
	"UpgradeRanks": {
		"Health": 0,
		"Damage": 0,
		"Armor": 0,
		"AttackSpeed": 0,
		"CritChance": 0,
		"Lifesteal": 0,
		"GoldMultiplier": 0
	}
}

const SAVE_USER_PATH = "user://grimspire_save.json"
const SAVE_LOCAL_PATH = "res://grimspire_save.json"

func _init():
	load_game()

func _ready():
	load_game()

func load_game():
	var path_to_load = ""
	if FileAccess.file_exists(SAVE_USER_PATH):
		path_to_load = SAVE_USER_PATH
	elif FileAccess.file_exists(SAVE_LOCAL_PATH):
		path_to_load = SAVE_LOCAL_PATH
	
	if path_to_load != "":
		var f = FileAccess.open(path_to_load, FileAccess.READ)
		var text = f.get_as_text()
		var json = JSON.new()
		if json.parse(text) == OK and json.data is Dictionary:
			var d = json.data
			save_data["PersistentGold"] = int(d.get("PersistentGold", 0))
			save_data["HighestFloorReached"] = max(1, int(d.get("HighestFloorReached", 1)))
			save_data["TotalRunsPlayed"] = int(d.get("TotalRunsPlayed", 0))
			save_data["Language"] = str(d.get("Language", "ru"))
			save_data["MasterVolume"] = float(d.get("MasterVolume", 0.8))
			save_data["SfxVolume"] = float(d.get("SfxVolume", 0.8))
			save_data["MusicVolume"] = float(d.get("MusicVolume", 0.5))
			save_data["Fullscreen"] = bool(d.get("Fullscreen", false))
			
			if d.has("UpgradeRanks") and d["UpgradeRanks"] is Dictionary:
				for k in save_data["UpgradeRanks"].keys():
					save_data["UpgradeRanks"][k] = int(d["UpgradeRanks"].get(k, 0))

func save_game():
	var json_str = JSON.stringify(save_data, "\t")
	var f = FileAccess.open(SAVE_USER_PATH, FileAccess.WRITE)
	if f:
		f.store_string(json_str)
	var f2 = FileAccess.open(SAVE_LOCAL_PATH, FileAccess.WRITE)
	if f2:
		f2.store_string(json_str)

func add_gold(amount: int):
	save_data["PersistentGold"] = max(0, save_data["PersistentGold"] + amount)
	save_game()

func spend_gold(amount: int) -> bool:
	if save_data["PersistentGold"] >= amount:
		save_data["PersistentGold"] -= amount
		save_game()
		return true
	return false

func record_run_completion(floor_reached: int):
	save_data["TotalRunsPlayed"] += 1
	if floor_reached > save_data["HighestFloorReached"]:
		save_data["HighestFloorReached"] = floor_reached
	save_game()

func get_upgrade_rank(upgrade_name: String) -> int:
	return save_data["UpgradeRanks"].get(upgrade_name, 0)

func increment_upgrade_rank(upgrade_name: String):
	if save_data["UpgradeRanks"].has(upgrade_name):
		save_data["UpgradeRanks"][upgrade_name] += 1
		save_game()

func get_language() -> String:
	return save_data.get("Language", "ru")

func set_language(lang: String):
	save_data["Language"] = lang
	save_game()

func get_master_volume() -> float:
	return float(save_data.get("MasterVolume", 0.8))

func set_master_volume(vol: float):
	save_data["MasterVolume"] = vol
	save_game()

func get_sfx_volume() -> float:
	return float(save_data.get("SfxVolume", 0.8))

func set_sfx_volume(vol: float):
	save_data["SfxVolume"] = vol
	save_game()

func get_music_volume() -> float:
	return float(save_data.get("MusicVolume", 0.5))

func set_music_volume(vol: float):
	save_data["MusicVolume"] = vol
	save_game()

func get_fullscreen() -> bool:
	return bool(save_data.get("Fullscreen", false))

func set_fullscreen(fs: bool):
	save_data["Fullscreen"] = fs
	save_game()
