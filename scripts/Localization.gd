extends Node

signal language_changed(new_lang: String)

var current_language: String = "ru"

const STRINGS = {
	"ru": {
		"game_title": "GrimSpire: Восхождение Проклятых",
		"camp_title": "КРОВАВЫЙ АЛТАРЬ (ЛАГЕРЬ)",
		"camp_subtitle": "Освятите золото павших походов, чтобы навеки усилить свою душу.",
		"camp_gold_record": "Золото: %d зол.   |   Рекорд восхождения: Этаж %d",
		"btn_ascend": "⚔ ВОСХОЖДЕНИЕ В ШПИЛЬ",
		"upgrade_btn": "Улучшить (%d зол.)",
		"rank": "Ранг",
		"floor_banner": "ЭТАЖ %d: %s",
		"boss_floor_banner": "★ БОСС ЭТАЖА %d: %s ★",
		"player_name": "Проклятый Странник",
		"player_label": "Проклятый Странник (Вы)",
		"gold_unit": "зол.",
		"hp_unit": "ОЗ",
		"hp_format": "%d / %d ОЗ  (Броня: %d | Урон: %d)",
		"player_stats_fmt": "⚔ Урон: %d  |  🛡 Броня: %d  |  ⚡ Скор.: %.2fx\n🎯 Крит: %d%% (x%.1f)  |  🩸 Вампиризм: %d%%  |  💨 Уклон: %d%%",
		"enemy_stats_fmt": "⚔ Базовый урон: %d   |   🛡 Броня: %d\n⚡ Скорость атаки: %.2f уд/сек   |   💰 Награда: +%d зол.",
		"combat_log_header": "ЖУРНАЛ СРАЖЕНИЯ",
		"draft_title": "ЭТАЖ %d ПРОЙДЕН! ВЫБЕРИТЕ НАГРАДУ",
		"draft_subtitle": "Выберите 1 реликвию для этого восхождения. Она займет ячейку экипировки.",
		"draft_current_gear": "ТЕКУЩАЯ ЭКИПИРОВКА:",
		"equip_relic": "ВЗЯТЬ РЕЛИКВИЮ",
		"replaces_slot": "Заменяет: %s",
		"slot_empty_hint": "Ячейка свободна",
		"defeat_title": "ВАША ПЛОТЬ УГАСЛА",
		"defeat_summary": "Вы пали на этаже %d.\nРекорд восхождения: Этаж %d.\nВся временная экипировка растворилась во тьме.\nСохранено золота: +%d зол. (Всего: %d зол.)",
		"btn_return_altar": "ВЕРНУТЬСЯ К АЛТАРЮ",
		"settings_title": "НАСТРОЙКИ",
		"master_volume": "Общая громкость",
		"sfx_volume": "Громкость звуков (SFX)",
		"music_volume": "Громкость музыки и фона",
		"language": "Язык интерфейса",
		"fullscreen": "Полноэкранный режим",
		"test_sfx": "▶ Проверить звук",
		"btn_close": "ЗАКРЫТЬ",
		"btn_settings": "⚙ НАСТРОЙКИ",
		"btn_lang_toggle": "Язык: РУС",
		"empty_slot_tooltip": "Пустой слот (%s)",
		"log_floor_entered": "=== Вы ступили на этаж %d: %s ===",
		"log_player_crit": "[b]КРИТИЧЕСКИЙ УДАР![/b] Вы нанесли %s урон [color=crimson][b]%d[/b][/color]!",
		"log_player_hit": "Вы нанесли %s урон [color=crimson]%d[/color].",
		"log_enemy_hit": "%s нанёс вам урон [color=red]%d[/color].",
		"log_player_dodge": "Вы уклонились от удара %s!",
		"log_enemy_dodge": "%s уклонился от вашего удара!",
		"log_enemy_defeated": "[color=gold]★ %s повержен! Собрано +%d золота! ★[/color]",
		"log_player_died": "[color=crimson][b]ВЫ ПОГИБЛИ В ШПИЛЕ. ПЛОТЬ ОБРАТИЛАСЬ В ПРАХ.[/b][/color]",
		"log_equipped": "[color=#60b0ff]Экипировано: %s (ячейка: %s).[/color]",
		"log_heal_boon": "[color=#40ff70]Благословение восхождения: восстановлено +%d ОЗ.[/color]",
		"float_dodge": "УКЛОНЕНИЕ!",
		"float_crit": "-%d КРИТ!",
		"float_hp": "+%d ОЗ",
		"slots": {
			"Weapon": "Оружие",
			"Armor": "Доспех",
			"Helmet": "Шлем",
			"OffHand": "Щит",
			"Accessory": "Амулет"
		},
		"rarities": {
			"Common": "Обычный",
			"Uncommon": "Необычный",
			"Rare": "Редкий",
			"Epic": "Эпический",
			"Legendary": "Легендарный",
			"Cursed": "Проклятый"
		},
		"stats": {
			"MaxHealth": "Макс. ОЗ",
			"AttackDamage": "Урон",
			"Armor": "Броня",
			"AttackSpeed": "Скор. атаки",
			"CritChance": "Шанс крита",
			"CritMultiplier": "Крит. урон",
			"Lifesteal": "Вампиризм",
			"DodgeChance": "Уклонение",
			"GoldMultiplier": "Множитель золота"
		},
		"items": {
			"rusty_blade": {
				"name": "Ржавый тесак Шпиля",
				"desc": "Зазубренное лезвие из ржавого железа, помнящее бесчисленные казни."
			},
			"executioner_axe": {
				"name": "Полумесяц Палача",
				"desc": "Тяжёлое лезвие из тёмной стали, жаждущее шейных позвонков."
			},
			"blood_scythe": {
				"name": "Жнец Проклятых",
				"desc": "Пульсирует украденными ударами сердец павших покорителей Шпиля."
			},
			"bone_carapace": {
				"name": "Панцирь Непогребённого",
				"desc": "Грудные клетки древних врагов, скреплённые ржавой проволокой."
			},
			"abyssal_shroud": {
				"name": "Саван Ловца Бездны",
				"desc": "Тёмная материя из теней, поглощающая и рассеивающая входящие удары."
			},
			"iron_sallet": {
				"name": "Шлем Часового Шпиля",
				"desc": "Узкое смотровое забрало с засохшей кровью по контуру стали."
			},
			"crown_of_thorns": {
				"name": "Шипастый венец Мученика",
				"desc": "Вонзается в череп носителя, даруя чудовищную силу ценой боли и уязвимости."
			},
			"weeping_shield": {
				"name": "Баклер Плачущей Матери",
				"desc": "Выкован со скорбным ликом, гасящим самые сокрушительные выпады."
			},
			"bloodstone_amulet": {
				"name": "Талисман Ока Гаргульи",
				"desc": "Высечен из окаменевшего ока часового 10-го этажа."
			}
		},
		"enemies": {
			"feeble_skeleton": {
				"name": "Неупокоенный скелет",
				"desc": "Хрупкие кости, стучащие на ледяном ветру у основания Шпиля."
			},
			"spire_imp": {
				"name": "Шпилевой бес",
				"desc": "Злобная тварь с обсидиановыми когтями, внезапно нападающая из темноты сводов."
			},
			"hollow_knight": {
				"name": "Полый рыцарь",
				"desc": "Ржавые готические латы, движимые темными духами минувшей эпохи."
			},
			"boss_gargoyle": {
				"name": "Смотритель Малгорат",
				"desc": "Колоссальное каменное чудовище на страже порога 10-го этажа. Сотрясает твердь."
			},
			"boss_flesh_amalgam": {
				"name": "Амальгама Скорби",
				"desc": "Извивающаяся масса сшитых тел и стонущих лиц, источающая смертоносный яд."
			}
		},
		"upgrades": {
			"Health": {
				"name": "Титаническая стойкость",
				"desc": "Увеличивает базовое максимальное здоровье на +12 ОЗ за ранг.",
				"bonus": "+12 к макс. ОЗ за ранг"
			},
			"Damage": {
				"name": "Беспощадное лезвие",
				"desc": "Увеличивает базовый урон на +2.5 DMG за ранг.",
				"bonus": "+2.5 к урону за ранг"
			},
			"Armor": {
				"name": "Железная плоть",
				"desc": "Увеличивает базовую броню на +2.0 за ранг.",
				"bonus": "+2.0 к броне за ранг"
			},
			"AttackSpeed": {
				"name": "Неистовая реакция",
				"desc": "Увеличивает скорость атаки на +0.05 уд/сек за ранг.",
				"bonus": "+0.05 к скор. атаки за ранг"
			},
			"CritChance": {
				"name": "Анатомия расправы",
				"desc": "Увеличивает базовый шанс критического удара на +1% за ранг.",
				"bonus": "+1% к шансу крита за ранг"
			},
			"Lifesteal": {
				"name": "Вампирический голод",
				"desc": "Увеличивает базовый вампиризм на +1% за ранг.",
				"bonus": "+1% к вампиризму за ранг"
			},
			"GoldMultiplier": {
				"name": "Алчность павших",
				"desc": "Увеличивает всё добываемое золото на +8% за ранг.",
				"bonus": "+8% к золоту за ранг"
			}
		}
	},
	"en": {
		"game_title": "GrimSpire: Ascent of the Cursed",
		"camp_title": "THE BLOOD ALTAR (BASE CAMP)",
		"camp_subtitle": "Consecrate the gold of fallen climbs to permanently strengthen your soul.",
		"camp_gold_record": "Gold: %d G   |   Deepest Descent: Floor %d",
		"btn_ascend": "⚔ ASCEND THE CURSED SPIRE",
		"upgrade_btn": "Upgrade (%d G)",
		"rank": "Rank",
		"floor_banner": "FLOOR %d: %s",
		"boss_floor_banner": "★ BOSS FLOOR %d: %s ★",
		"player_name": "Cursed Wanderer",
		"player_label": "Cursed Wanderer (You)",
		"gold_unit": "G",
		"hp_unit": "HP",
		"hp_format": "%d / %d HP  (Armor: %d | DMG: %d)",
		"player_stats_fmt": "⚔ DMG: %d  |  🛡 Armor: %d  |  ⚡ Speed: %.2fx\n🎯 Crit: %d%% (x%.1f)  |  🩸 Lifesteal: %d%%  |  💨 Dodge: %d%%",
		"enemy_stats_fmt": "⚔ Base Damage: %d   |   🛡 Armor: %d\n⚡ Attack Speed: %.2f atk/s   |   💰 Reward: +%d G",
		"combat_log_header": "COMBAT LOG",
		"draft_title": "FLOOR %d CLEARED! CHOOSE YOUR REWARD",
		"draft_subtitle": "Choose 1 relic to equip for this ascent. Replaces existing slot.",
		"draft_current_gear": "CURRENT EQUIPMENT:",
		"equip_relic": "EQUIP RELIC",
		"replaces_slot": "Replaces: %s",
		"slot_empty_hint": "Slot is empty",
		"defeat_title": "YOUR FLESH HAS PERISHED",
		"defeat_summary": "You met your end on Floor %d.\nDeepest Ascent: Floor %d.\nAll ephemeral equipment has dissolved into ash.\nGold Preserved: +%d G (Total: %d G)",
		"btn_return_altar": "RETURN TO BLOOD ALTAR",
		"settings_title": "SETTINGS",
		"master_volume": "Master Volume",
		"sfx_volume": "SFX Volume",
		"music_volume": "Music & Ambience Volume",
		"language": "Interface Language",
		"fullscreen": "Fullscreen Mode",
		"test_sfx": "▶ Test Sound",
		"btn_close": "CLOSE",
		"btn_settings": "⚙ SETTINGS",
		"btn_lang_toggle": "Lang: ENG",
		"empty_slot_tooltip": "Empty %s Slot",
		"log_floor_entered": "=== Entered Floor %d: %s ===",
		"log_player_crit": "[b]CRITICAL STRIKE![/b] You hit %s for [color=crimson][b]%d[/b][/color] dmg!",
		"log_player_hit": "You hit %s for [color=crimson]%d[/color] dmg.",
		"log_enemy_hit": "%s struck you for [color=red]%d[/color] dmg.",
		"log_player_dodge": "You dodged %s's blow!",
		"log_enemy_dodge": "%s dodged your strike!",
		"log_enemy_defeated": "[color=gold]★ %s vanquished! Gathered +%d Gold! ★[/color]",
		"log_player_died": "[color=crimson][b]YOU HAVE PERISHED IN THE SPIRE.[/b][/color]",
		"log_equipped": "[color=#60b0ff]Equipped: %s in %s slot.[/color]",
		"log_heal_boon": "[color=#40ff70]Ascension boon: Restored +%d HP for the climb ahead.[/color]",
		"float_dodge": "DODGED!",
		"float_crit": "-%d CRIT!",
		"float_hp": "+%d HP",
		"slots": {
			"Weapon": "Weapon",
			"Armor": "Armor",
			"Helmet": "Helmet",
			"OffHand": "Off-Hand",
			"Accessory": "Accessory"
		},
		"rarities": {
			"Common": "Common",
			"Uncommon": "Uncommon",
			"Rare": "Rare",
			"Epic": "Epic",
			"Legendary": "Legendary",
			"Cursed": "Cursed"
		},
		"stats": {
			"MaxHealth": "Max HP",
			"AttackDamage": "Attack Damage",
			"Armor": "Armor",
			"AttackSpeed": "Attack Speed",
			"CritChance": "Crit Chance",
			"CritMultiplier": "Crit Multiplier",
			"Lifesteal": "Lifesteal",
			"DodgeChance": "Dodge Chance",
			"GoldMultiplier": "Gold Multiplier"
		},
		"items": {},
		"enemies": {},
		"upgrades": {}
	}
}

func _init():
	current_language = "ru"

func set_language(lang: String):
	if lang != "ru" and lang != "en":
		lang = "ru"
	current_language = lang
	language_changed.emit(current_language)

func get_string(key: String, default_text: String = "") -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"])
	if dict.has(key):
		return dict[key]
	var fallback = STRINGS["en"]
	if fallback.has(key):
		return fallback[key]
	return default_text if default_text != "" else key

func get_slot_name(slot: String) -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("slots", {})
	return dict.get(slot, slot)

func get_rarity_name(rarity: String) -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("rarities", {})
	return dict.get(rarity, rarity)

func get_stat_name(stat_key: String) -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("stats", {})
	return dict.get(stat_key, stat_key)

func get_item_name(item: Dictionary) -> String:
	var item_id = item.get("id", "")
	if current_language == "ru":
		var items_dict = STRINGS["ru"].get("items", {})
		if items_dict.has(item_id):
			return items_dict[item_id].get("name", item.get("name", ""))
	return item.get("name", "")

func get_item_description(item: Dictionary) -> String:
	var item_id = item.get("id", "")
	if current_language == "ru":
		var items_dict = STRINGS["ru"].get("items", {})
		if items_dict.has(item_id):
			return items_dict[item_id].get("desc", item.get("description", ""))
	return item.get("description", "")

func get_enemy_name(enemy_id: String, default_name: String = "") -> String:
	if current_language == "ru":
		var enemies_dict = STRINGS["ru"].get("enemies", {})
		if enemies_dict.has(enemy_id):
			return enemies_dict[enemy_id].get("name", default_name)
	return default_name

func get_enemy_description(enemy_id: String, default_desc: String = "") -> String:
	if current_language == "ru":
		var enemies_dict = STRINGS["ru"].get("enemies", {})
		if enemies_dict.has(enemy_id):
			return enemies_dict[enemy_id].get("desc", default_desc)
	return default_desc

func get_upgrade_name(upgrade_type: String, default_name: String = "") -> String:
	if current_language == "ru":
		var upg_dict = STRINGS["ru"].get("upgrades", {})
		if upg_dict.has(upgrade_type):
			return upg_dict[upgrade_type].get("name", default_name)
	return default_name

func get_upgrade_description(upgrade_type: String, default_desc: String = "") -> String:
	if current_language == "ru":
		var upg_dict = STRINGS["ru"].get("upgrades", {})
		if upg_dict.has(upgrade_type):
			return upg_dict[upgrade_type].get("desc", default_desc)
	return default_desc

func get_upgrade_bonus(upgrade_type: String, default_bonus: String = "") -> String:
	if current_language == "ru":
		var upg_dict = STRINGS["ru"].get("upgrades", {})
		if upg_dict.has(upgrade_type):
			return upg_dict[upgrade_type].get("bonus", default_bonus)
	return default_bonus

func format_stat(stat_key: String, value: Variant) -> String:
	var stat_name = get_stat_name(stat_key)
	var f_val = float(value)
	if (stat_key in ["CritChance", "CritMultiplier", "Lifesteal", "DodgeChance", "GoldMultiplier"]) or (abs(f_val) < 1.0 and stat_key == "AttackSpeed"):
		var pct = int(round(f_val * 100))
		return ("+%d%% %s" if pct >= 0 else "%d%% %s") % [pct, stat_name]
	
	if f_val == floor(f_val):
		var iv = int(f_val)
		return ("+%d %s" if iv >= 0 else "%d %s") % [iv, stat_name]
	else:
		return ("+%.1f %s" if f_val >= 0 else "%.1f %s") % [f_val, stat_name]
