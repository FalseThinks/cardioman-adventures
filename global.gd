extends Node

signal coins_updated(new_amount)
signal run_ended(summary: Dictionary)

var coins: int = 0

var velocity_level = 0
var stamina_level = 0
var dmg_reduction_level = 0
var dash_cost_level = 0
var jump_cost_level = 0
var dash_cd_level = 0
var apple_level = 0
var sound_muted = false
var current_skin := "default"

# Persistent lifetime stats
var best_distance: int = 0
var total_runs: int = 0
var total_coins_earned: int = 0
var total_obstacles_destroyed: int = 0
var high_scores: Array = []          # top 5 distances
var unlocked_achievements: Array = [] # achievement IDs

# Per-run counters (reset each run, not saved)
var run_distance: int = 0
var run_coins: int = 0
var run_obstacles: int = 0

const SAVE_PATH = "user://savegame.save"

# Shared world constants
const PLAYER_START_X := 571.0
const FLOOR_Y := 823.0
const PIXELS_PER_METER := 100.0
const BIOME_DISTANCE := 500
const BIOME_COLORS := [
	Color(1.0, 1.0, 1.0),       # Day / Grass
	Color(1.0, 0.8, 0.6),       # Sunset / Desert
	Color(0.4, 0.4, 0.6),       # Night / Blue
	Color(0.8, 0.6, 0.8),       # Magic / Purple
	Color(1.0, 0.5, 0.5)        # Lava / Red
]

const MAX_LEVELS := {
	"velocity_level": 10,
	"stamina_level": 10,
	"dmg_reduction_level": 5,
	"dash_cost_level": 4,
	"jump_cost_level": 4,
	"dash_cd_level": 10,
	"apple_level": 8
}

var _save_timer: Timer

func _ready():
	load_data()
	_save_timer = Timer.new()
	_save_timer.wait_time = 2.0
	_save_timer.one_shot = true
	_save_timer.timeout.connect(save_data)
	add_child(_save_timer)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()

# --- Coins ---

func set_coins(value: int) -> void:
	coins = value
	emit_signal("coins_updated", coins)
	_save_timer.start()

func add_coin(amount: int = 1) -> void:
	run_coins += amount
	set_coins(coins + amount)

# --- Per-run tracking ---

func start_run():
	run_distance = 0
	run_coins = 0
	run_obstacles = 0

func add_obstacle_destroyed():
	run_obstacles += 1

func end_run(distance: int) -> Dictionary:
	run_distance = distance
	total_runs += 1
	total_coins_earned += run_coins
	total_obstacles_destroyed += run_obstacles

	var is_new_best = distance > best_distance
	if is_new_best:
		best_distance = distance

	# Insert into high scores (keep top 5, sorted descending)
	high_scores.append(distance)
	high_scores.sort()
	high_scores.reverse()
	if high_scores.size() > 5:
		high_scores.resize(5)

	save_data()

	var summary = {
		"distance": distance,
		"coins": run_coins,
		"obstacles": run_obstacles,
		"is_new_best": is_new_best
	}
	emit_signal("run_ended", summary)
	return summary

# --- Save / Load ---

func save_data():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		var data = {
			"coins": coins,
			"velocity_level": velocity_level,
			"stamina_level": stamina_level,
			"dmg_reduction_level": dmg_reduction_level,
			"dash_cost_level": dash_cost_level,
			"jump_cost_level": jump_cost_level,
			"dash_cd_level": dash_cd_level,
			"apple_level": apple_level,
			"sound_muted": sound_muted,
			"current_skin": current_skin,
			"best_distance": best_distance,
			"total_runs": total_runs,
			"total_coins_earned": total_coins_earned,
			"total_obstacles_destroyed": total_obstacles_destroyed,
			"high_scores": high_scores,
			"unlocked_achievements": unlocked_achievements
		}
		file.store_string(JSON.stringify(data))

func load_data():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json = JSON.new()
			var err = json.parse(content)
			if err == OK:
				var data = json.get_data()
				coins = data.get("coins", 0)
				velocity_level = data.get("velocity_level", 0)
				stamina_level = data.get("stamina_level", 0)
				dmg_reduction_level = data.get("dmg_reduction_level", 0)
				dash_cost_level = data.get("dash_cost_level", 0)
				jump_cost_level = data.get("jump_cost_level", 0)
				dash_cd_level = data.get("dash_cd_level", 0)
				apple_level = data.get("apple_level", 0)
				sound_muted = data.get("sound_muted", false)
				current_skin = data.get("current_skin", "default")
				best_distance = data.get("best_distance", 0)
				total_runs = data.get("total_runs", 0)
				total_coins_earned = data.get("total_coins_earned", 0)
				total_obstacles_destroyed = data.get("total_obstacles_destroyed", 0)
				high_scores = data.get("high_scores", [])
				unlocked_achievements = data.get("unlocked_achievements", [])
				AudioServer.set_bus_mute(0, sound_muted)
