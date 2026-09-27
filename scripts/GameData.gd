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
	return get_smart_draft_items(count, floor_num, {})

func get_smart_draft_items(count: int, floor_num: int, current_equipped: Dictionary) -> Array:
	if items.is_empty():
		return []
	
	var pool = items.duplicate()
	pool.shuffle()
	
	# Exclude direct identical duplicates from pool
	var equipped_names = {}
	for slot in current_equipped:
		var eq = current_equipped[slot]
		if eq != null:
			equipped_names[eq.get("name", "")] = true
	
	var filtered_pool = []
	for itm in pool:
		if not equipped_names.has(itm.get("name", "")):
			filtered_pool.append(itm)
	if filtered_pool.size() < count:
		filtered_pool = pool
	
	var chosen: Array = []
	var chosen_slots = {}
	
	# Diversity first: distinct equipment slots
	for item in filtered_pool:
		var slot = item.get("slot", "")
		if not chosen_slots.has(slot):
			var itm_copy = item.duplicate(true)
			# Check if eligible for fusion with equipped item in this slot
			if current_equipped.has(slot) and current_equipped[slot] != null:
				var eq = current_equipped[slot]
				var eq_tier = eq.get("tier", 1)
				if eq_tier < 3 and randf() < 0.45:
					itm_copy["is_fusion"] = true
					itm_copy["fusion_target_name"] = eq.get("name", "")
					itm_copy["new_tier"] = eq_tier + 1
			chosen.append(itm_copy)
			chosen_slots[slot] = true
			if chosen.size() >= count:
				break
	
	# Fill remaining if needed
	if chosen.size() < count:
		for item in filtered_pool:
			var found = false
			for c in chosen:
				if c.get("id") == item.get("id"):
					found = true
					break
			if not found:
				chosen.append(item.duplicate(true))
				if chosen.size() >= count:
					break
	
	return chosen

func fuse_items(base_item: Dictionary, _sac_item: Dictionary) -> Dictionary:
	var cur_tier = base_item.get("tier", 1)
	var new_tier = min(3, cur_tier + 1)
	var mult = 1.6 if new_tier == 2 else 2.4
	
	var fused = base_item.duplicate(true)
	fused["tier"] = new_tier
	var clean_name = base_item.get("name", "Relic")
	clean_name = clean_name.replace(" [Тир II]", "").replace(" [Тир III ★]", "")
	clean_name = clean_name.replace(" [Tier II]", "").replace(" [Tier III ★]", "")
	fused["name"] = "%s %s" % [clean_name, "[Тир II]" if new_tier == 2 else "[Тир III ★]"]
	
	var new_stats = {}
	var old_stats = base_item.get("stats", {})
	for k in old_stats:
		var val = old_stats[k]
		if val is float:
			new_stats[k] = round(val * (1.2 if new_tier == 2 else 1.35) * 100.0) / 100.0
		else:
			new_stats[k] = int(round(val * mult))
	fused["stats"] = new_stats
	fused["description"] = "%s (Эволюция Тир %d: увеличены характеристики)" % [base_item.get("description", ""), new_tier]
	return fused


func get_enemy_for_floor(floor_num: int) -> Dictionary:
	var template: Dictionary = {}
	var is_boss: bool = (floor_num % 10 == 0)
	
	if is_boss:
		if floor_num == 10:
			template = _find_enemy("boss_gargoyle")
		elif floor_num == 20:
			template = _find_enemy("boss_flesh_amalgam")
		elif floor_num == 30:
			template = _find_enemy("boss_valthor")
		else:
			var boss_pool = ["boss_gargoyle", "boss_flesh_amalgam", "boss_valthor"]
			var b_id = boss_pool[(floor_num / 10) % boss_pool.size()]
			template = _find_enemy(b_id)
			template["name"] = "%s [Tier %d]" % [template.get("name", "Spire Lord"), floor_num / 10]
	elif floor_num == 1:
		template = _find_enemy("feeble_skeleton")
	elif floor_num == 2:
		template = _find_enemy("spire_imp")
	elif floor_num == 3:
		template = _find_enemy("crypt_ghoul")
	elif floor_num == 4:
		template = _find_enemy("tormented_shade")
	elif floor_num == 5:
		template = _find_enemy("hollow_knight")
	elif floor_num == 6:
		template = _find_enemy("blood_cultist")
	elif floor_num == 7:
		template = _find_enemy("hollow_knight")
	elif floor_num == 8:
		template = _find_enemy("obsidian_gargoyle")
	elif floor_num == 9:
		template = _find_enemy("plague_abomination")
	elif floor_num in [11, 12, 13]:
		template = _find_enemy("cursed_inquisitor")
	elif floor_num in [14, 15, 16]:
		template = _find_enemy("spire_executioner")
	elif floor_num in [17, 18, 19]:
		template = _find_enemy("crypt_lich")
	elif floor_num >= 21 and floor_num <= 25:
		template = _find_enemy("void_stalker")
	elif floor_num >= 26 and floor_num <= 29:
		template = _find_enemy("infernal_colossus")
	else:
		var non_boss_pool = [
			"hollow_knight", "blood_cultist", "spire_executioner",
			"crypt_lich", "void_stalker", "infernal_colossus"
		]
		var idx = (floor_num % non_boss_pool.size())
		template = _find_enemy(non_boss_pool[idx])
	
	# Clone template and scale by floor
	var enemy = template.duplicate(true)
	var stats = enemy["stats"]
	
	var scale_factor = 1.0 + (floor_num - 1) * 0.09
	if is_boss:
		scale_factor = 1.0 + (floor_num - 10) * 0.12
	
	var max_hp = int(stats.get("MaxHealth", 50) * scale_factor)
	var dmg = int(stats.get("AttackDamage", 10) * scale_factor)
	var armor = int(stats.get("Armor", 0) * (1.0 + (floor_num - 1) * 0.05))
	var spd = float(stats.get("AttackSpeed", 1.0))
	var gold = int(enemy.get("goldReward", 15) * (1.0 + (floor_num - 1) * 0.12))
	
	return {
		"id": enemy.get("id", "enemy"),
		"name": enemy.get("name", "Spire Horror"),
		"description": enemy.get("description", ""),
		"isBoss": is_boss,
		"max_health": max_hp,
		"current_health": max_hp,
		"attack_damage": dmg,
		"armor": armor,
		"attack_speed": spd,
		"crit_chance": stats.get("CritChance", 0.05),
		"crit_multiplier": stats.get("CritMultiplier", 1.5),
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
			"is_blocked": false,
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
	
	# Block check (if defender has high armor and reduced damage substantially)
	var is_blocked = (def_armor >= 12 and reduction < 0.60 and randf() < 0.35)
	if is_blocked:
		final_dmg = max(1, int(final_dmg * 0.5))
	
	# Lifesteal
	var ls_rate = float(attacker.get("lifesteal", 0.0))
	var healed = int(round(final_dmg * ls_rate)) if ls_rate > 0.0 else 0
	
	return {
		"dodged": false,
		"is_crit": is_crit,
		"is_blocked": is_blocked,
		"damage": final_dmg,
		"lifesteal": healed
	}
