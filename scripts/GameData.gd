extends Node

var items: Array = []
var enemies: Array = []
var meta_upgrades: Array = []

func _init():
	load_all_data()

func _ready():
	if items.is_empty():
		load_all_data()

func load_all_data():
	items = _load_json("res://data/items.json")
	enemies = _load_json("res://data/enemies.json")
	meta_upgrades = _load_json("res://data/meta_upgrades.json")

func _load_json(path: String) -> Array:
	if not FileAccess.file_exists(path):
		push_warning("File not found: " + path)
		return []
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(content)
	if err == OK and json.data is Array:
		return json.data
	return []

func get_random_items(count: int, floor_num: int) -> Array:
	if items.is_empty():
		return []
	var pool = items.duplicate()
	pool.shuffle()
	var result = []
	for i in range(min(count, pool.size())):
		result.append(pool[i].duplicate(true))
	return result

func get_enemy_for_floor(floor_num: int) -> Dictionary:
	var template: Dictionary = {}
	var is_boss: bool = (floor_num % 10 == 0)
	
	if is_boss:
		if floor_num == 10:
			template = _find_enemy("boss_gargoyle")
		elif floor_num == 20:
			template = _find_enemy("boss_flesh_amalgam")
		else:
			template = _find_enemy("boss_gargoyle")
			template["name"] = "Ancient Spire Titan [Floor %d]" % floor_num
	elif floor_num == 1:
		template = _find_enemy("feeble_skeleton")
	elif floor_num <= 4:
		template = _find_enemy("spire_imp")
	else:
		template = _find_enemy("hollow_knight")
	
	# Clone template and scale by floor
	var enemy = template.duplicate(true)
	var stats = enemy["stats"]
	
	# Scaling formula matching GrimSpire GDD: +10% per floor after floor 1
	var scale_factor = 1.0 + (floor_num - 1) * 0.10
	if is_boss:
		scale_factor = 1.0 + (floor_num - 10) * 0.12
	
	var max_hp = int(stats.get("MaxHealth", 50) * scale_factor)
	var dmg = int(stats.get("AttackDamage", 10) * scale_factor)
	var armor = int(stats.get("Armor", 0) * (1.0 + (floor_num - 1) * 0.05))
	var spd = float(stats.get("AttackSpeed", 1.0))
	var gold = int(enemy.get("goldReward", 15) * (1.0 + (floor_num - 1) * 0.15))
	
	return {
		"id": enemy.get("id", "enemy"),
		"name": enemy.get("name", "Spire Horror"),
		"isBoss": is_boss,
		"max_health": max_hp,
		"current_health": max_hp,
		"attack_damage": dmg,
		"armor": armor,
		"attack_speed": spd,
		"crit_chance": stats.get("CritChance", 0.05),
		"lifesteal": stats.get("Lifesteal", 0.0),
		"dodge_chance": stats.get("DodgeChance", 0.0),
		"gold_reward": gold
	}

func _find_enemy(id: String) -> Dictionary:
	for e in enemies:
		if e.get("id") == id:
			return e
	if not enemies.is_empty():
		return enemies[0]
	return {
		"id": "shadow",
		"name": "Spire Shadow",
		"stats": {"MaxHealth": 40, "AttackDamage": 8, "Armor": 2, "AttackSpeed": 1.0},
		"goldReward": 15,
		"isBoss": false
	}

func calculate_damage(attacker: Dictionary, defender: Dictionary) -> Dictionary:
	# Check dodge
	var dodge = float(defender.get("dodge_chance", 0.0))
	if dodge > 0.0 and randf() < dodge:
		return {
			"dodged": true,
			"is_crit": false,
			"damage": 0,
			"lifesteal": 0
		}
	
	var raw_dmg = float(attacker.get("attack_damage", 10))
	var crit_chance = float(attacker.get("crit_chance", 0.05))
	var is_crit = (randf() < crit_chance)
	if is_crit:
		var crit_mult = float(attacker.get("crit_multiplier", 1.5))
		raw_dmg *= crit_mult
	
	# Armor damage reduction: dmg * (100 / (100 + armor))
	var def_armor = max(0.0, float(defender.get("armor", 0)))
	var reduction = 100.0 / (100.0 + def_armor)
	var final_dmg = max(1, int(round(raw_dmg * reduction)))
	
	# Lifesteal
	var ls_rate = float(attacker.get("lifesteal", 0.0))
	var healed = int(round(final_dmg * ls_rate)) if ls_rate > 0.0 else 0
	
	return {
		"dodged": false,
		"is_crit": is_crit,
		"damage": final_dmg,
		"lifesteal": healed
	}
