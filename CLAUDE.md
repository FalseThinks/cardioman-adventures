# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cardioman Adventures is a 2D endless runner/platformer game built with **Godot Engine 4.6** using **GDScript**. The game is mobile-optimized and features a character that runs continuously, jumps/dashes over obstacles, and collects coins to buy upgrades.

## Development Commands

This is a pure Godot project with no external build tooling. Development workflow:

- **Run the game**: Open the project in Godot 4.6 and press F5, or use `godot --path .` from the terminal
- **Export**: Use Godot's built-in export system (Project → Export)
- **No linting/testing tools** are configured — testing is done by running the game in the Godot editor

## Architecture

### Entry Points

- **`main.tscn`** — Root scene loaded on startup
- **`global.gd`** — Autoload singleton (persistent across scene reloads); manages global game state, coin tracking, upgrade levels, and JSON save/load (`user://savegame.save`)

### Core Systems

**Player (`player.gd` / `player.tscn`)**
- `CharacterBody2D` with constant rightward velocity
- Jump (Space, double-jump capable), Dash (X key) — both cost stamina
- Stamina drains continuously; reaching 0 triggers game over
- 1.5s invulnerability after taking damage (visual blink)
- All stats are driven by upgrade levels read from `global.gd`

**Infinite Ground (`ground_manager.gd`)**
- Cycles 3 ground pieces leftward; recycles the rearmost piece to the front
- Biome system: 5 biomes (Day→Sunset→Night→Magic→Lava) cycle every 500m with lerp color transitions

**Obstacle Spawning (`objects/static/object_static_spawner.gd`)**
- Spawns obstacles at random intervals (1–2.5s) in batches
- 30% chance for "rocket" obstacles (move leftward), 40% chance for a consumable on top
- Obstacles yield a coin when destroyed by dashing

**Upgrade/Save System (`global.gd` + `ui/upgrade_menu.gd`)**
- Upgrades: `velocity_level`, `stamina_level`, `dmg_reduction_level`, `dash_cost_level`, `jump_cost_level`, `dash_cd_level`, `apple_level`
- Upgrade cost formula: `10 + (level * 15)` coins
- `global.set_coins()` saves immediately; `global.load_data()` runs at startup

### Signal Flow

- `global.coins_updated` signal → `ui/coin_label.gd` updates the HUD display
- Player emits nothing directly; game-over logic calls `get_tree().reload_current_scene()`

### Scene Hierarchy (main.tscn)

```
Main
├── Player
├── CanvasLayer
│   ├── Control (HUD: UI.gd, stamina_bar.gd, coin_label.gd)
│   └── ParallaxBackground
├── GroundManager (3 repeating ground pieces)
└── ObjectsManager
    ├── ObstaclesManager → StaticObjectsSpawner
    └── ConsumablesManager
```

### Key Files

| File | Purpose |
|---|---|
| `global.gd` | Singleton: game state, upgrades, save/load |
| `player.gd` | All player input, movement, stamina, collision |
| `ground_manager.gd` | Infinite scrolling ground + biome colors |
| `parallax_background.gd` | Parallax layers matching biome palette |
| `objects/static/object_static_spawner.gd` | Obstacle/consumable spawning logic |
| `objects/static/obstacle.gd` | Obstacle behavior, destruction, rocket variant |
| `consumables/tofu.gd` | Stamina recovery item (heals `50 + apple_level * 15`) |
| `ui/upgrade_menu.gd` | Post-death shop UI |
| `ui/UI.gd` | HUD: coin count and distance display |
| `ui/stamina_bar.gd` | Stamina bar with color gradient + damage flash |
