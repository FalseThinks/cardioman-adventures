extends Control

@onready var coins_label = $Panel/VBoxContainer/CoinsLabel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_ui()
	_animate_in()

func _animate_in():
	modulate.a = 0.0
	var panel = $Panel
	panel.scale = Vector2(0.92, 0.92)
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_parallel(true)
	tween.tween_property(self, "modulate:a", 1.0, 0.25)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

func update_ui():
	coins_label.text = "Coins: " + str(global.coins)
	_set_btn_text($Panel/VBoxContainer/BtnVelocity, "Velocity+", "velocity_level")
	_set_btn_text($Panel/VBoxContainer/BtnStamina, "Max Stamina+", "stamina_level")
	_set_btn_text($Panel/VBoxContainer/BtnDmgRed, "Dmg Reduction+", "dmg_reduction_level")
	_set_btn_text($Panel/VBoxContainer/BtnDashCost, "Dash Cost-", "dash_cost_level")
	_set_btn_text($Panel/VBoxContainer/BtnJumpCost, "Jump Cost-", "jump_cost_level")
	_set_btn_text($Panel/VBoxContainer/BtnDashCD, "Dash CD-", "dash_cd_level")
	_set_btn_text($Panel/VBoxContainer/BtnApple, "Apple Recovery+", "apple_level")

func _set_btn_text(btn: Button, label: String, stat_name: String):
	var lvl = global.get(stat_name)
	var max_lvl = global.MAX_LEVELS[stat_name]
	if lvl >= max_lvl:
		btn.text = label + " (MAX)"
		btn.disabled = true
	else:
		btn.text = label + " (Lvl " + str(lvl) + ") - Cost: " + str(get_cost(lvl))
		btn.disabled = false

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
	if current_level >= global.MAX_LEVELS[stat_name]:
		return
	var cost = get_cost(current_level)
	if global.coins >= cost:
		global.set_coins(global.coins - cost)
		global.set(stat_name, current_level + 1)
		global.save_data()
		audio_manager.play_sfx("purchase")
		update_ui()
	else:
		audio_manager.play_sfx("purchase_fail")

func _on_BtnPlayAgain_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/start_menu.tscn")
