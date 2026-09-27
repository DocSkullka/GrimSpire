# Техническая Архитектура GrimSpire

## 1. Архитектурный паттерн: Clean Core + Engine View

Для максимальной масштабируемости, надежности и тестируемости используется подход с изоляцией ядра игры:

```text
┌────────────────────────────────────────────────────────┐
│               PRESENTATION LAYER (GODOT 4)             │
│  - 2D Canvas & Shaders (Darkest Dungeon / Don't Starve)│
│  - Particle Systems (Blood, Embers, Fog)               │
│  - UI Windows (Draft Modal, Blood Altar, HP Bars)      │
│  - Sound & FMOD/AudioStreamPlayer                      │
└───────────────────────────▲────────────────────────────┘
                            │ Subscribes to events / calls API
┌───────────────────────────▼────────────────────────────┐
│              CORE SIMULATION ENGINE (C# .NET 8)         │
│  - Models (Character, Enemy, Stats, Item)              │
│  - CombatEngine (Deterministic Tick-based Simulation)  │
│  - FloorGenerator (Difficulty scaling & Bosses)        │
│  - ItemDraftService (Rarity weights & Draft rules)     │
│  - MetaProgression (Persistent gold & attributes)      │
└────────────────────────────────────────────────────────┘
```

---

## 2. Ключевые компоненты Core

1. `GrimSpire.Core.Models.Stats`:
   - Неизменяемая запись (`record`) со сложением через `operator +`.
   - Защита от переполнения и ограничение капов (Dodge capped at 75%, Crit capped at 100%).
2. `GrimSpire.Core.Combat.CombatEngine`:
   - Детерминированный боевой движок (с возможностью передачи фиксированного `seed`).
   - Логирует дискретные события `CombatEvent` (`Attack`, `DamageDealt`, `Evaded`, `CriticalHit`, `Healed`, `UnitDefeated`).
   - Позволяет как воспроизводить анимации в реальном времени, так и мгновенно считать бой за 0.001 сек.
3. `GrimSpire.Core.Progression.FloorGenerator`:
   - Алгоритм процедурной генерации этажей с масштабированием сложности:
     $$\text{EnemyMultiplier} = 1.0 + (\text{Floor} \times 0.12)$$
   - Гарантированный босс на этажах $10, 20, 30 \dots$.
4. `GrimSpire.Core.Progression.ItemDraftService`:
   - Генератор наград по формуле распределения вероятностей редкости в зависимости от текущей высоты башни.
5. `GrimSpire.Core.Progression.MetaProgression`:
   - Управление банком золота и деревом прокачки.

---

## 3. Схема интеграции с Godot 4

В Godot 4 проект настраивается в режиме .NET (C#):
1. В `project.godot` подключается сборка `GrimSpire.Core.dll`.
2. Создается узел `GameManager.cs` (Autoload / Singleton), который держит инстанс `TowerRunManager`.
3. При сражении узел `CombatScene` слушает событие `CombatResult.Events`:
   - Каждое событие триггерит анимацию удара персонажа, воспроизведение звука попадания, появление всплывающей цифры урона (Damage Popup) и сдвиг полоски здоровья.
   - Игрок может нажать кнопку "2x / 4x Speed" или "Skip to Result" в любой момент!
