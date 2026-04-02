extends Node

signal coins_updated(new_amount)

var coins: int = 0

var velocity_level = 0
var stamina_level = 0
var dmg_reduction_level = 0
var dash_cost_level = 0
var jump_cost_level = 0
var dash_cd_level = 0
var apple_level = 0
var sound_muted = false

const SAVE_PATH = "user://savegame.save"

# Shared world constants — referenced by player, ground, parallax, UI, spawner
const PLAYER_START_X := 571.0
const FLOOR_Y := 823.0
const PIXELS_PER_METER := 100.0
const BIOME_DISTANCE := 500  # meters per biome
const BIOME_COLORS := [
	Color(1.0, 1.0, 1.0),       # Day / Grass
	Color(1.0, 0.8, 0.6),       # Sunset / Desert
	Color(0.4, 0.4, 0.6),       # Night / Blue
	Color(0.8, 0.6, 0.8),       # Magic / Purple
	Color(1.0, 0.5, 0.5)        # Lava / Red
]

# Max upgrade levels — derived from the clamp floors in player.gd _ready()
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

# Getter/Setter method for coins
func set_coins(value: int) -> void:
	coins = value
	emit_signal("coins_updated", coins)
	# Debounced save: starts a 2s timer; resets if called again before it fires
	_save_timer.start()

# Method to add coins
func add_coin(amount: int = 1) -> void:
	set_coins(coins + amount)

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
			"sound_muted": sound_muted
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
				AudioServer.set_bus_mute(0, sound_muted)
