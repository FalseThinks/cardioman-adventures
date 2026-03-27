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

const SAVE_PATH = "user://savegame.save"

func _ready():
	load_data()

# Getter/Setter method for coins
func set_coins(value: int) -> void:
	coins = value
	emit_signal("coins_updated", coins)
	save_data()

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
			"apple_level": apple_level
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
