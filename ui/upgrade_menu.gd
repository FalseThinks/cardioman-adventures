extends Control

@onready var coins_label = $Panel/VBoxContainer/CoinsLabel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_ui()

func update_ui():
	coins_label.text = "Coins: " + str(global.coins)
	$Panel/VBoxContainer/BtnVelocity.text = "Velocity+ (Lvl " + str(global.velocity_level) + ") - Cost: " + str(get_cost(global.velocity_level))
	$Panel/VBoxContainer/BtnStamina.text = "Max Stamina+ (Lvl " + str(global.stamina_level) + ") - Cost: " + str(get_cost(global.stamina_level))
	$Panel/VBoxContainer/BtnDmgRed.text = "Dmg Reduction+ (Lvl " + str(global.dmg_reduction_level) + ") - Cost: " + str(get_cost(global.dmg_reduction_level))
	$Panel/VBoxContainer/BtnDashCost.text = "Dash Cost- (Lvl " + str(global.dash_cost_level) + ") - Cost: " + str(get_cost(global.dash_cost_level))
	$Panel/VBoxContainer/BtnJumpCost.text = "Jump Cost- (Lvl " + str(global.jump_cost_level) + ") - Cost: " + str(get_cost(global.jump_cost_level))
	$Panel/VBoxContainer/BtnDashCD.text = "Dash CD- (Lvl " + str(global.dash_cd_level) + ") - Cost: " + str(get_cost(global.dash_cd_level))
	$Panel/VBoxContainer/BtnApple.text = "Apple Recovery+ (Lvl " + str(global.apple_level) + ") - Cost: " + str(get_cost(global.apple_level))

func get_cost(level: int) -> int:
	return 10 + (level * 15)

func _on_BtnVelocity_pressed():
	try_buy("velocity_level")
func _on_BtnStamina_pressed():
	try_buy("stamina_level")
func _on_BtnDmgRed_pressed():
	try_buy("dmg_reduction_level")
func _on_BtnDashCost_pressed():
	try_buy("dash_cost_level")
func _on_BtnJumpCost_pressed():
	try_buy("jump_cost_level")
func _on_BtnDashCD_pressed():
	try_buy("dash_cd_level")
func _on_BtnApple_pressed():
	try_buy("apple_level")

func try_buy(stat_name: String):
	var current_level = global.get(stat_name)
	var cost = get_cost(current_level)
	if global.coins >= cost:
		global.set_coins(global.coins - cost)
		global.set(stat_name, current_level + 1)
		global.save_data()
		update_ui()

func _on_BtnPlayAgain_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/start_menu.tscn")
