extends Node

signal language_changed(new_lang: String)

var current_language: String = "ru"

const STRINGS = {
	"ru": {
		"game_title": "GRIMSPIRE: ASCENT OF THE CURSED",
		"game_subtitle": "Мрачный Автобатлер • Восхождение Проклятого",
		"menu_start": "⚔ НАЧАТЬ ВОСХОЖДЕНИЕ",
		"menu_camp": "🩸 КРОВАВЫЙ АЛТАРЬ (ЛАГЕРЬ)",
		"menu_compendium": "📖 БЕСТИАРИЙ И АРСЕНАЛ",
		"menu_settings": "⚙ НАСТРОЙКИ",
		"menu_quit": "🚪 ВЫХОД ИЗ ИГРЫ",
		"btn_main_menu": "🏛 ГЛАВНОЕ МЕНЮ",
		"compendium_title": "БЕСТИАРИЙ И АРСЕНАЛ ШПИЛЯ",
		"compendium_tab_enemies": "💀 МОНСТРЫ ШПИЛЯ",
		"compendium_tab_items": "🗡 РЕЛИКВИИ И СНАРЯЖЕНИЕ",
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
		"draft_subtitle": "Выберите 1 реликвию или переплавьте добычу в золото, сохранив текущий билд.",
		"draft_current_gear": "ТЕКУЩАЯ ЭКИПИРОВКА:",
		"equip_relic": "ВЗЯТЬ РЕЛИКВИЮ",
		"btn_skip_draft": "💰 ПРОПУСТИТЬ И ПЕРЕПЛАВИТЬ (+%d ЗОЛ.)",
		"skip_draft_desc": "Оставить текущее снаряжение без изменений и забрать чистое золото.",
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
		"speed_btn": "⏩ Скорость: %s",
		"soul_bar_label": "⚡ ДУША: %d%% (РАЗРЫВ ДУШИ ГОТОВ!)",
		"room_cleared_banner": "⚔ КОМНАТА ОЧИЩЕНА! ⚔",
		"walking_transition": "Переход в следующие покои Шпиля...",
		"float_block": "БЛОК!",
		"float_soul": "РАЗРЫВ ДУШИ! -%d",
		"float_dodge": "УКЛОНЕНИЕ!",
		"float_crit": "-%d КРИТ!",
		"float_hp": "+%d ОЗ",
		"badge_combo": "СЕРИЯ x2!",
		"badge_heavy_thrust": "ТЯЖЕЛЫЙ ВЫПАД!",
		"badge_cleave": "РАЗРУБАНИЕ С ПЛЕЧА!",
		"badge_parry": "ПАРРИРОВАНИЕ!",
		"badge_block": "ОТРАЖЕНО ЩИТОМ!",
		"badge_dodge": "ТЕНЕВОЙ ПЕРЕКАТ!",
		"badge_soul_cleave": "★ РАЗРУБАНИЕ ДУШИ! ★",
		"badge_crit": "КРИТИЧЕСКИЙ УДАР!",
		"log_floor_entered": "=== Вы ступили на этаж %d: %s ===",
		"log_player_crit": "[b]КРИТИЧЕСКИЙ УДАР![/b] Вы нанесли %s урон [color=crimson][b]%d[/b][/color]!",
		"log_player_hit": "Вы нанесли %s урон [color=crimson]%d[/color].",
		"log_player_block": "[color=#60b0ff]Вы отразили удар щитом! Поглощено 50% урона.[/color]",
		"log_player_soul": "[color=#e060ff][b]★ РАЗРЫВ ДУШИ! Нанесён сокрушительный урон %d! ★[/b][/color]",
		"log_enemy_hit": "%s нанёс вам урон [color=red]%d[/color].",
		"log_player_dodge": "Вы ловко уклонились от выпада %s!",
		"log_enemy_dodge": "%s уклонился от вашего удара!",
		"log_enemy_defeated": "[color=gold]★ %s повержен! Собрано +%d золота! ★[/color]",
		"log_player_died": "[color=crimson][b]ВЫ ПОГИБЛИ В ШПИЛЕ. ПЛОТЬ ОБРАТИЛАСЬ В ПРАХ.[/b][/color]",
		"log_equipped": "[color=#60b0ff]Экипировано: %s (ячейка: %s). Вид персонажа обновлён![/color]",
		"log_salvaged": "[color=gold]Трофеи переплавлены: получено +%d золота![/color]",
		"log_heal_boon": "[color=#40ff70]Благословение перехода: восстановлено +%d ОЗ.[/color]",
		"party_title": "ОТРЯД СПУТНИКОВ (ЛАГЕРЬ)",
		"party_subtitle": "Соберите тактический отряд до 4 героев перед штурмом Шпиля.",
		"btn_manage_party": "👥 ОТРЯД СПУТНИКОВ",
		"party_tank": "Железный Бастион (Танк)",
		"party_wanderer": "Проклятый Странник (Герой)",
		"party_thief": "Ночная Тень (Вор-взломщик)",
		"party_cleric": "Плетунья Крови (Целитель)",
		"party_tank_desc": "Передовой рубеж. Навык: Провокация (стягивает атаки, блок щитом -60% урона). Аура: +20% защиты соседним бойцам.",
		"party_wanderer_desc": "Основной урон (DPS). Накапливает шкалу Разрубания Души для кругового удара.",
		"party_thief_desc": "Фланговый ловкач. Навык: Теневой шаг и удар в спину (х3 крит). Пассивно: +35% золота и взлом сундуков.",
		"party_cleric_desc": "Оккультный маг. Навык: Кровавое исцеление (+25% ОЗ). Пассивно: восстанавливает +15% ОЗ отряду после боя.",
		"btn_toggle_active": "В строю: %s",
		"btn_recruit": "Нанять (%d зол.)",
		"chest_title": "СОКРОВИЩНИЦА ЭТАЖА %d",
		"chest_subtitle": "Отряд наткнулся на древний кованый готический ларец с рунической печатью.",
		"chest_pick_thief": "🗝 Вор в отряде: Вскрыть отмычками (100% успех!)",
		"chest_use_key": "🔑 Открыть Ключом Шпиля",
		"chest_force": "🔨 Сбить замок силой (риск 50% сломать лут/ловушка)",
		"chest_leave": "🚪 Оставить сундук и идти к лифту",
		"chest_opened_title": "СУНДУК РАСПАХНУТ!",
		"badge_fusion": "★ СЛИЯНИЕ / ЭВОЛЮЦИЯ ★",
		"badge_taunt": "ПРОВОКАЦИЯ (ТАНК)!",
		"badge_heal": "ИСЦЕЛЕНИЕ КРОВИ!",
		"badge_backstab": "УДАР В СПИНУ!",
		"fusion_banner": "⚡ СЛИЯНИЕ: УЛУЧШИТЬ ДО ТИРА %d ⚡",
		"fusion_desc": "Объединить с экипированным предметом (+60% характеристик).",
		"slots": {
			"Weapon": "Оружие",
			"Armor": "Доспех",
			"Helmet": "Шлем",
			"OffHand": "Щит/Оффхенд",
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
			"rusty_blade": { "name": "Ржавый тесак Шпиля", "desc": "Зазубренное лезвие из ржавого железа, помнящее бесчисленные казни." },
			"dusk_dagger": { "name": "Сумеречный кинжал", "desc": "Почерневшее лезвие, омытое соком белладонны. Невероятно быстрые выпады." },
			"executioner_axe": { "name": "Полумесяц Палача", "desc": "Тяжёлое лезвие из тёмной стали, жаждущее шейных позвонков." },
			"flanged_mace": { "name": "Шестопёр Костолом", "desc": "Массивное шипастое навершие, дробящее любые рыцарские латы." },
			"runic_greatsword": { "name": "Рунический полуторник", "desc": "Древний меч, испещрённый светящимися глифами павших паладинов." },
			"void_katana": { "name": "Нодати Пронзатель Тьмы", "desc": "Многослойный клинок из черненой стали, рассекающий ткань теней." },
			"blood_scythe": { "name": "Жнец Проклятых", "desc": "Пульсирует украденными ударами сердец павших покорителей Шпиля." },
			"cursed_soul_eater": { "name": "Клинок Пожиратель Душ", "desc": "Шепчет безумие в разум владельца. Колоссальный урон ценой жизненных сил." },
			"tattered_brigandine": { "name": "Истлевшая бригантина", "desc": "Плотная кожа с нашитыми железными кольцами, пахнущая торфяной гарью." },
			"bone_carapace": { "name": "Панцирь Непогребённого", "desc": "Грудные клетки древних врагов, скреплённые ржавой проволокой." },
			"knight_cuirass": { "name": "Кираса Чёрного Стража", "desc": "Воронёная готическая броня, выкованная отражать удары осадных орудий." },
			"abyssal_shroud": { "name": "Саван Ловца Бездны", "desc": "Тёмная ткань, сотканная из теней и поглощающая вражеские выпады." },
			"demon_plate": { "name": "Латы Джаггернаута Бездны", "desc": "Выкованы в глубинных горнилах под Шпилем. Несокрушимая защита." },
			"blood_soaked_shroud": { "name": "Одеяние Кровавого Мученика", "desc": "Непрерывно сочится свежей кровью. Дарует чудовищный вампиризм." },
			"iron_sallet": { "name": "Шлем Часового Шпиля", "desc": "Узкая смотровая щель с засохшей кровью по контуру." },
			"leather_hood": { "name": "Капюшон Ловца Склепов", "desc": "Мягкая теневая кожа, скрадывающая звук шагов и дыхания." },
			"winged_bascinet": { "name": "Крылатый бацинет Валькирии", "desc": "Украшен потускневшими серебряными крыльями, направляющими гнев." },
			"shadow_cowl": { "name": "Клобук Безликого", "desc": "Скрывает лицо владельца в вечном полумраке, обостряя смертоносность." },
			"crown_of_thorns": { "name": "Терновый Венец Мученика", "desc": "Впивается шипами в череп, даруя ужасающую летальность ценой мук." },
			"crown_of_the_spire_king": { "name": "Венец Владыки Шпиля", "desc": "Излучает абсолютное владычество над цитаделью проклятых." },
			"wooden_buckler": { "name": "Кованый дубовый баклер", "desc": "Дубовые плашки с железными заклепками для парирования клинков." },
			"spiked_targe": { "name": "Шипастая тарча", "desc": "Снабжена острым 20-сантиметровым шипом для контратак." },
			"weeping_shield": { "name": "Баклер Плачущей Матери", "desc": "Барельеф скорбного лика, отражающий самые сокрушительные удары." },
			"grimoire_of_shadows": { "name": "Гримуар Кровавой Луны", "desc": "Переплетён кожей упыря, читает проклятия, вытягивающие чужую жизнь." },
			"aegis_of_the_immortal": { "name": "Эгида Затонувшей Цитадели", "desc": "Ростовой щит древних исполинов, способный остановить метеорит." },
			"cursed_skull_totem": { "name": "Тотем Свежеванного Пророка", "desc": "Хихикающий сушеный череп, жаждущий кровавого побоища." },
			"copper_ring": { "name": "Медное кольцо первопроходца", "desc": "Простое гравированное кольцо на удачу от былых странников." },
			"rogue_signet": { "name": "Печатка Гильдии Теней", "desc": "Изображение вороньих перьев, ускоряющее реакцию пальцев." },
			"vampire_fang_pendant": { "name": "Клык Древнего Нетопыря", "desc": "Окаменевший клык крылатого кровопийцы, жаждущий крови." },
			"bloodstone_amulet": { "name": "Око Стража Малгората", "desc": "Выточен из окаменевшего ока часового 10-го яруса." },
			"heart_of_the_spire": { "name": "Сердце Цитадели Бездны", "desc": "Пульсирующее ядро застывшего эфира, многократно умножающее силу." },
			"ring_of_the_doomed": { "name": "Перстень Обречённого Палача", "desc": "Дарует чудовищную силу критических ударов взамен крепости плоти." }
		},
		"enemies": {
			"feeble_skeleton": "Неупокоенный скелет",
			"spire_imp": "Обсидиановый бес",
			"crypt_ghoul": "Склепный вурдалак",
			"tormented_shade": "Терзаемая тень",
			"hollow_knight": "Пустой рыцарь",
			"blood_cultist": "Фанатик кровавого культа",
			"obsidian_gargoyle": "Обсидиановый страж",
			"plague_abomination": "Чумная мерзость",
			"boss_gargoyle": "Надзиратель Малгорат",
			"cursed_inquisitor": "Проклятый инквизитор",
			"spire_executioner": "Палач Шпиля",
			"crypt_lich": "Архилич катакомб",
			"boss_flesh_amalgam": "Амальгама Скорби",
			"void_stalker": "Ловец Бездны",
			"infernal_colossus": "Адский колосс",
			"boss_valthor": "Валтор Гаситель Душ"
		},
		"enemy_desc": {
			"feeble_skeleton": "Хрупкие кости, гремящие на ледяном ветру у основания Башни.",
			"spire_imp": "Хихикающая тварь с обсидиановыми когтями, прыгающая с потолочных балок.",
			"crypt_ghoul": "Одичавший пожиратель падали, терзающий плоть павших авантюристов.",
			"tormented_shade": "Призрачный фантом, скользящий сквозь сталь и плоть.",
			"hollow_knight": "Ржавые готические латы, движимые неистовой злобой древних духов.",
			"blood_cultist": "Аколит в тёмной сутане, приносящий свою кровь в жертву демонам.",
			"obsidian_gargoyle": "Ожившая каменная химера, блокирующая удары каменными крыльями.",
			"plague_abomination": "Раздувшийся гнилостный гигант, сочащийся ядовитой сукровицей.",
			"boss_gargoyle": "Исполинский каменный монстр у врат 10-го яруса. Вызывает сотрясения пола.",
			"cursed_inquisitor": "Падший храмовник, испепеляющий осквернённым священным пламенем.",
			"spire_executioner": "Исполин в кожаном клобуке с колоссальным топором-гильотиной.",
			"crypt_lich": "Древний чернокнижник, черпающий бессмертие из филактерий крови.",
			"boss_flesh_amalgam": "Клубящаяся масса сшитых тел и кричащих лиц, исторгающая яд.",
			"void_stalker": "Существо из глубин между мирами, мгновенно мерцающее в пространстве.",
			"infernal_colossus": "Ожившая крепость из раскалённого железа и адского пламени.",
			"boss_valthor": "Бессмертный архитектор Мрачного Шпиля, абсолютный повелитель погибели."
		},
		"upgrades": {
			"Health": { "name": "Укрепление плоти", "bonus": "+12 ОЗ за ранг", "desc": "Наращивает максимальный запас здоровья Проклятого Странника." },
			"Damage": { "name": "Кровавая ярость", "bonus": "+2.5 урона за ранг", "desc": "Усиливает силу удара клинка и физическую мощь." },
			"Armor": { "name": "Закалка духа", "bonus": "+2 брони за ранг", "desc": "Повышает природную стойкость к ударам врагов." },
			"AttackSpeed": { "name": "Быстрота тени", "bonus": "+5% скор. атаки за ранг", "desc": "Ускоряет частоту выпадов и парирований." },
			"CritChance": { "name": "Смертоносная точность", "bonus": "+1% шанс крита за ранг", "desc": "Увеличивает вероятность нанести сокрушительный удар." },
			"Lifesteal": { "name": "Жажда вампира", "bonus": "+1% вампиризма за ранг", "desc": "Похищает часть нанесённого урона в виде здоровья." },
			"GoldMultiplier": { "name": "Алчность проклятых", "bonus": "+8% золота за ранг", "desc": "Увеличивает количество золота, добываемого в боях." }
		}
	},
	"en": {
		"game_title": "GRIMSPIRE: ASCENT OF THE CURSED",
		"game_subtitle": "Dark Roguelite Autobattler • Ascent of the Damned",
		"menu_start": "⚔ START ASCENT",
		"menu_camp": "🩸 BLOOD ALTAR (CAMP)",
		"menu_compendium": "📖 BESTIARY & ARMORY",
		"menu_settings": "⚙ SETTINGS",
		"menu_quit": "🚪 QUIT GAME",
		"btn_main_menu": "🏛 MAIN MENU",
		"compendium_title": "SPIRE BESTIARY & ARMORY",
		"compendium_tab_enemies": "💀 SPIRE HORRORS",
		"compendium_tab_items": "🗡 RELICS & GEAR",
		"camp_title": "BLOOD ALTAR (CAMP)",
		"camp_subtitle": "Consecrate the gold of fallen expeditions to permanently bolster your soul.",
		"camp_gold_record": "Gold: %d G   |   Ascent Record: Floor %d",
		"btn_ascend": "⚔ ASCEND INTO THE SPIRE",
		"upgrade_btn": "Upgrade (%d G)",
		"rank": "Rank",
		"floor_banner": "FLOOR %d: %s",
		"boss_floor_banner": "★ BOSS FLOOR %d: %s ★",
		"player_name": "Cursed Wanderer",
		"player_label": "Cursed Wanderer (You)",
		"gold_unit": "G",
		"hp_unit": "HP",
		"hp_format": "%d / %d HP  (Armor: %d | Damage: %d)",
		"player_stats_fmt": "⚔ Damage: %d  |  🛡 Armor: %d  |  ⚡ Speed: %.2fx\n🎯 Crit: %d%% (x%.1f)  |  🩸 Lifesteal: %d%%  |  💨 Dodge: %d%%",
		"enemy_stats_fmt": "⚔ Base Damage: %d   |   🛡 Armor: %d\n⚡ Attack Speed: %.2f atk/s   |   💰 Reward: +%d G",
		"combat_log_header": "COMBAT LOG",
		"draft_title": "FLOOR %d CLEARED! CHOOSE YOUR SPOILS",
		"draft_subtitle": "Select 1 relic for this run or salvage spoils into gold while keeping your build.",
		"draft_current_gear": "EQUIPPED GEAR:",
		"equip_relic": "EQUIP RELIC",
		"btn_skip_draft": "💰 SKIP & SALVAGE (+%d GOLD)",
		"skip_draft_desc": "Keep existing equipment unchanged and salvage spoils for pure gold.",
		"replaces_slot": "Replaces: %s",
		"slot_empty_hint": "Slot is empty",
		"defeat_title": "YOUR FLESH HAS WITHERED",
		"defeat_summary": "You fell upon Floor %d.\nAscent Record: Floor %d.\nAll temporary equipment dissolved into shadows.\nGold preserved: +%d G (Total: %d G)",
		"btn_return_altar": "RETURN TO ALTAR",
		"settings_title": "SETTINGS",
		"master_volume": "Master Volume",
		"sfx_volume": "SFX Volume",
		"music_volume": "Music & Ambience",
		"language": "Interface Language",
		"fullscreen": "Fullscreen Mode",
		"test_sfx": "▶ Test Sound",
		"btn_close": "CLOSE",
		"btn_settings": "⚙ SETTINGS",
		"btn_lang_toggle": "Lang: ENG",
		"empty_slot_tooltip": "Empty slot (%s)",
		"speed_btn": "⏩ Speed: %s",
		"soul_bar_label": "⚡ SOUL: %d%% (SOUL CLEAVE READY!)",
		"room_cleared_banner": "⚔ CHAMBER PURGED! ⚔",
		"walking_transition": "Advancing deeper into the Spire...",
		"float_block": "BLOCKED!",
		"float_soul": "SOUL CLEAVE! -%d",
		"float_dodge": "DODGE!",
		"float_crit": "-%d CRIT!",
		"float_hp": "+%d HP",
		"badge_combo": "COMBO x2!",
		"badge_heavy_thrust": "HEAVY THRUST!",
		"badge_cleave": "OVERHEAD CLEAVE!",
		"badge_parry": "PARRY!",
		"badge_block": "BLOCKED!",
		"badge_dodge": "SHADOW DASH!",
		"badge_soul_cleave": "★ SOUL CLEAVE! ★",
		"badge_crit": "CRITICAL STRIKE!",
		"log_floor_entered": "=== You entered floor %d: %s ===",
		"log_player_crit": "[b]CRITICAL STRIKE![/b] You dealt [color=crimson][b]%d[/b][/color] damage to %s!",
		"log_player_hit": "You dealt [color=crimson]%d[/color] damage to %s.",
		"log_player_block": "[color=#60b0ff]Shield block! 50% damage deflected.[/color]",
		"log_player_soul": "[color=#e060ff][b]★ SOUL CLEAVE! Unleashed devastating %d damage! ★[/b][/color]",
		"log_enemy_hit": "%s struck you for [color=red]%d[/color] damage.",
		"log_player_dodge": "You deftly dodged %s's strike!",
		"log_enemy_dodge": "%s evaded your strike!",
		"log_enemy_defeated": "[color=gold]★ %s defeated! Claimed +%d Gold! ★[/color]",
		"log_player_died": "[color=crimson][b]YOU HAVE PERISHED IN THE SPIRE. ASHES TO ASHES.[/b][/color]",
		"log_equipped": "[color=#60b0ff]Equipped: %s (slot: %s). Visual hero appearance updated![/color]",
		"log_salvaged": "[color=gold]Loot salvaged: gained +%d Gold![/color]",
		"log_heal_boon": "[color=#40ff70]Ascension boon: restored +%d HP.[/color]",
		"party_title": "PARTY COMPANIONS (CAMP)",
		"party_subtitle": "Form a tactical squad of up to 4 heroes before storming the Spire.",
		"btn_manage_party": "👥 SQUAD COMPANIONS",
		"party_tank": "The Bulwark (Tank)",
		"party_wanderer": "The Wanderer (Hero)",
		"party_thief": "The Nightshade (Thief/Rogue)",
		"party_cleric": "The Bloodweaver (Healer)",
		"party_tank_desc": "Frontline fortress. Ability: Taunt (redirects attacks, shield block -60% damage). Aura: +20% defense to squad.",
		"party_wanderer_desc": "Primary physical DPS. Builds Soul Cleave gauge for devastating spinning cleave.",
		"party_thief_desc": "Flank rogue. Ability: Shadow step & backstab (x3 crit). Passive: +35% gold find & picks locked chests.",
		"party_cleric_desc": "Occult blood mage. Ability: Blood mending (+25% HP to wounded ally). Heals squad +15% HP after battle.",
		"btn_toggle_active": "In Squad: %s",
		"btn_recruit": "Recruit (%d Gold)",
		"chest_title": "TREASURE ALCOVE: FLOOR %d",
		"chest_subtitle": "The squad discovered an ancient forged gothic chest with a demonic seal.",
		"chest_pick_thief": "🗝 Thief in Party: Pick with Lockpicks (100% Guaranteed!)",
		"chest_use_key": "🔑 Unlock with Spire Key",
		"chest_force": "🔨 Force Lock with Weapon (50% risk to break loot/trap)",
		"chest_leave": "🚪 Leave Chest and Proceed to Elevator",
		"chest_opened_title": "CHEST UNLOCKED!",
		"badge_fusion": "★ FUSION / EVOLUTION ★",
		"badge_taunt": "TAUNT (TANK)!",
		"badge_heal": "BLOOD MENDING!",
		"badge_backstab": "BACKSTAB STRIKE!",
		"fusion_banner": "⚡ FUSION: EVOLVE TO TIER %d ⚡",
		"fusion_desc": "Merge with equipped item (+60% augmented attributes).",
		"slots": {
			"Weapon": "Weapon",
			"Armor": "Armor",
			"Helmet": "Helmet",
			"OffHand": "Shield/OffHand",
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
			"AttackDamage": "Damage",
			"Armor": "Armor",
			"AttackSpeed": "Atk Speed",
			"CritChance": "Crit Chance",
			"CritMultiplier": "Crit Mult",
			"Lifesteal": "Lifesteal",
			"DodgeChance": "Dodge",
			"GoldMultiplier": "Gold Mult"
		},
		"items": {
			"rusty_blade": { "name": "Rusty Spire Cleaver", "desc": "A jagged piece of rusty iron, scarred by countless executions." },
			"dusk_dagger": { "name": "Dusk Dagger", "desc": "Blackened blade dipped in nightshade. Strikes with blinding quickness." },
			"executioner_axe": { "name": "Headsman's Crescent", "desc": "Heavy dark-steel blade that yearns for vertebrae." },
			"flanged_mace": { "name": "Bone-Crusher Flanged Mace", "desc": "Dense spiked bludgeon designed to splinter knightly gothic plate." },
			"runic_greatsword": { "name": "Runic Bastard Greatsword", "desc": "Ancient broadsword etched with glowing glyphs of the fallen paladins." },
			"void_katana": { "name": "Shadow Piercer Nodachi", "desc": "Folded obsidian blade that cuts through reality itself." },
			"blood_scythe": { "name": "Harvester of the Damned", "desc": "Pulses with the stolen heartbeats of fallen climbers." },
			"cursed_soul_eater": { "name": "Soul Devourer Blade", "desc": "Whispers madness into the wielder. Enormous lethality at the price of flesh." },
			"tattered_brigandine": { "name": "Wanderer's Padded Brigandine", "desc": "Stiff leather vest layered with iron rings, smelling of peat smoke." },
			"bone_carapace": { "name": "Carapace of the Unburied", "desc": "Ribcages of ancient foes stitched with rusted wire." },
			"knight_cuirass": { "name": "Black Guard Cuirass", "desc": "Fluted dark-steel armor forged to withstand siege trebuchets." },
			"abyssal_shroud": { "name": "Shroud of the Void Stalker", "desc": "Dark cloth woven from shadows that swallows incoming strikes." },
			"demon_plate": { "name": "Abyssal Juggernaut Plate", "desc": "Forged in the underworld bowels beneath the Spire. Unbreakable." },
			"blood_soaked_shroud": { "name": "Garb of the Crimson Martyr", "desc": "Constantly weeps fresh blood. Grants terrifying regenerative hunger." },
			"iron_sallet": { "name": "Spire Sentry Helm", "desc": "Narrow slit visor with dried blood along the rim." },
			"leather_hood": { "name": "Crypt Stalker Hood", "desc": "Supple shadow-leather cowl that muffles footsteps." },
			"winged_bascinet": { "name": "Valkyrie Winged Bascinet", "desc": "Adorned with tarnished silver wings that channel celestial fury." },
			"shadow_cowl": { "name": "Cowl of the Faceless", "desc": "Obscures the wearer's face in eternal twilight." },
			"crown_of_thorns": { "name": "Martyr's Jagged Crown", "desc": "Pierces the wearer's skull, granting terrifying lethality at great agony." },
			"crown_of_the_spire_king": { "name": "Crown of the Ascended Monarch", "desc": "Radiates sovereign dominion over the damned citadel." },
			"wooden_buckler": { "name": "Reinforced Oak Buckler", "desc": "Oak planks bound with iron rivets to parry incoming blades." },
			"spiked_targe": { "name": "Spiked Iron Targe", "desc": "Fitted with a vicious 8-inch central spike to counter-strike foes." },
			"weeping_shield": { "name": "Buckler of the Weeping Mother", "desc": "Embossed with a sorrowful face that deflects heavy impacts." },
			"grimoire_of_shadows": { "name": "Grimoire of the Blood Moon", "desc": "Bound in ghoul skin, chanting incantations that leach enemy vitality." },
			"aegis_of_the_immortal": { "name": "Aegis of the Sunken Fortress", "desc": "Tower shield blessed by titans, capable of repelling falling meteors." },
			"cursed_skull_totem": { "name": "Totem of the Flayed Prophet", "desc": "Cackling shrunken skull that hungers for mortal combat." },
			"copper_ring": { "name": "Climber's Copper Band", "desc": "Simple etched ring worn by ancient wanderers for good fortune." },
			"rogue_signet": { "name": "Signet of the Shadow Guild", "desc": "Engraved with raven feathers, hastening reflexes." },
			"vampire_fang_pendant": { "name": "Nocturnal Fang Amulet", "desc": "Preserved canine of an elder bat vampire, thirsty for gore." },
			"bloodstone_amulet": { "name": "Gargoyle Eye Talisman", "desc": "Carved from the ocular stone of the Floor 10 sentinel." },
			"heart_of_the_spire": { "name": "Heart of the Nether Citadels", "desc": "Pulsing core of solidified dark ether, empowering all attributes." },
			"ring_of_the_doomed": { "name": "Band of the Cursed Execution", "desc": "Gives fatal precision on critical strikes, sacrificing mortal endurance." }
		},
		"enemies": {
			"feeble_skeleton": "Feeble Skeleton",
			"spire_imp": "Spire Imp",
			"crypt_ghoul": "Crypt Ghoul",
			"tormented_shade": "Tormented Shade",
			"hollow_knight": "Hollow Knight",
			"blood_cultist": "Blood Cultist Zealot",
			"obsidian_gargoyle": "Obsidian Sentry Gargoyle",
			"plague_abomination": "Rotting Plague Abomination",
			"boss_gargoyle": "Gargoyle Overseer Malgorath",
			"cursed_inquisitor": "Cursed Inquisitor",
			"spire_executioner": "Spire Headsman",
			"crypt_lich": "Crypt Arch-Lich",
			"boss_flesh_amalgam": "The Flesh Amalgam of Sorrow",
			"void_stalker": "Eldritch Void Stalker",
			"infernal_colossus": "Infernal Dreadnought",
			"boss_valthor": "Valthor the Soul Extinguisher"
		},
		"enemy_desc": {
			"feeble_skeleton": "Fragile bones clattering in the cold wind of the Spire base.",
			"spire_imp": "Cackling creature with obsidian claws that leaps from rafters.",
			"crypt_ghoul": "Feral flesh-eating scavenger that feasts upon fallen adventurers.",
			"tormented_shade": "Spectral phantom weaving between planes, ignoring physical defense.",
			"hollow_knight": "Suit of rusted gothic plate armor propelled by malevolent spirits.",
			"blood_cultist": "Robed acolyte offering dark incantations and sacrificing vitality for power.",
			"obsidian_gargoyle": "Living stone guardian perched atop high buttresses, deflecting blows.",
			"plague_abomination": "Bloated necrotic juggernaut dripping foul bile and toxic pustules.",
			"boss_gargoyle": "Colossal stone monstrosity perched atop the 10th tier threshold. Summons shockwaves.",
			"cursed_inquisitor": "Fallen templar purging all trespassers with blackened sacred fire.",
			"spire_executioner": "Immense hooded brute swinging a guillotine-sized executioner axe.",
			"crypt_lich": "Ancient sorcerer defying death with unholy blood phylacteries.",
			"boss_flesh_amalgam": "Writhing mass of stitched bodies and wailing faces that secretes virulent venom.",
			"void_stalker": "Creature from the depths between worlds that blinks across space.",
			"infernal_colossus": "Animated molten iron fortress burning with unquenchable hellfire.",
			"boss_valthor": "The immortal architect of the Grim Spire, sovereign ruler of death."
		},
		"upgrades": {
			"Health": { "name": "Fortify Flesh", "bonus": "+12 HP per rank", "desc": "Expands the maximum life essence of the Cursed Wanderer." },
			"Damage": { "name": "Blood Fury", "bonus": "+2.5 Dmg per rank", "desc": "Enhances martial blade potency and strike impact." },
			"Armor": { "name": "Spiritual Hardening", "bonus": "+2 Armor per rank", "desc": "Augments innate deflections against foe strikes." },
			"AttackSpeed": { "name": "Shadow Alacrity", "bonus": "+5% Atk Spd per rank", "desc": "Accelerates weapon recovery and strike cadence." },
			"CritChance": { "name": "Lethal Precision", "bonus": "+1% Crit per rank", "desc": "Heightens likelihood of inflicting devastating strikes." },
			"Lifesteal": { "name": "Vampiric Thirst", "bonus": "+1% Lifesteal per rank", "desc": "Leeches a portion of inflicted damage as life vitality." },
			"GoldMultiplier": { "name": "Covetous Hunger", "bonus": "+8% Gold per rank", "desc": "Multiplies gold extracted from vanquished abominations." }
		}
	}
}

func set_language(lang: String):
	if lang in ["ru", "en"]:
		current_language = lang
		emit_signal("language_changed", current_language)

func get_string(key: String, default_val: String = "") -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"])
	if dict.has(key):
		return dict[key]
	var fallback = STRINGS["ru"]
	if fallback.has(key):
		return fallback[key]
	return default_val if default_val != "" else key

func get_slot_name(slot: String) -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("slots", {})
	return dict.get(slot, slot)

func get_rarity_name(rarity: String) -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("rarities", {})
	return dict.get(rarity, rarity)

func get_stat_name(stat_key: String) -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("stats", {})
	return dict.get(stat_key, stat_key)

func format_stat(stat_key: String, value: Variant) -> String:
	var s_name = get_stat_name(stat_key)
	if stat_key in ["CritChance", "Lifesteal", "DodgeChance", "GoldMultiplier"]:
		var pct = int(round(float(value) * 100.0))
		return "%s: +%d%%" % [s_name, pct]
	elif stat_key == "CritMultiplier":
		var pct = int(round(float(value) * 100.0))
		return "%s: +%d%%" % [s_name, pct]
	elif stat_key == "AttackSpeed":
		var f_val = float(value)
		return "%s: +%.2f" % [s_name, f_val]
	else:
		var i_val = int(value)
		var sign_str = "+" if i_val >= 0 else ""
		return "%s: %s%d" % [s_name, sign_str, i_val]

func get_item_name(item: Dictionary) -> String:
	var id = item.get("id", "")
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("items", {})
	if dict.has(id):
		return dict[id].get("name", item.get("name", id))
	return item.get("name", id)

func get_item_description(item: Dictionary) -> String:
	var id = item.get("id", "")
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("items", {})
	if dict.has(id):
		return dict[id].get("desc", item.get("description", ""))
	return item.get("description", "")

func get_enemy_name(enemy_id: String, default_name: String = "") -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("enemies", {})
	if dict.has(enemy_id):
		return dict[enemy_id]
	return default_name if default_name != "" else enemy_id

func get_enemy_description(enemy_id: String, default_desc: String = "") -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("enemy_desc", {})
	if dict.has(enemy_id):
		return dict[enemy_id]
	return default_desc

func get_upgrade_name(type_name: String, default_name: String = "") -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("upgrades", {})
	if dict.has(type_name):
		return dict[type_name].get("name", default_name)
	return default_name

func get_upgrade_bonus(type_name: String, default_bonus: String = "") -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("upgrades", {})
	if dict.has(type_name):
		return dict[type_name].get("bonus", default_bonus)
	return default_bonus

func get_upgrade_description(type_name: String, default_desc: String = "") -> String:
	var dict = STRINGS.get(current_language, STRINGS["ru"]).get("upgrades", {})
	if dict.has(type_name):
		return dict[type_name].get("desc", default_desc)
	return default_desc
