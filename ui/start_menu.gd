extends Control

@onready var coins_label = $MainPanel/VBoxContainer/CoinsLabel
@onready var stats_container = $MainPanel/VBoxContainer/StatsContainer
@onready var main_panel = $MainPanel
@onready var options_panel = $OptionsPanel
@onready var sound_toggle = $OptionsPanel/VBoxContainer/SoundToggle

func _ready():
	options_panel.visible = false
	main_panel.visible = true
	update_ui()
	sound_toggle.button_pressed = not global.sound_muted
	AudioServer.set_bus_mute(0, global.sound_muted)

func update_ui():
	coins_label.text = "Coins: " + str(global.coins)
	var stats = stats_container.get_children()
	stats[0].text = "Velocity: Lvl " + str(global.velocity_level)
	stats[1].text = "Max Stamina: Lvl " + str(global.stamina_level)
	stats[2].text = "Dmg Reduction: Lvl " + str(global.dmg_reduction_level)
	stats[3].text = "Dash Cost: Lvl " + str(global.dash_cost_level)
	stats[4].text = "Jump Cost: Lvl " + str(global.jump_cost_level)
	stats[5].text = "Dash Cooldown: Lvl " + str(global.dash_cd_level)
	stats[6].text = "Apple Recovery: Lvl " + str(global.apple_level)

func _on_BtnPlay_pressed():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_BtnOptions_pressed():
	main_panel.visible = false
	options_panel.visible = true

func _on_BtnBack_pressed():
	options_panel.visible = false
	main_panel.visible = true

func _on_SoundToggle_toggled(toggled_on: bool):
	global.sound_muted = not toggled_on
	AudioServer.set_bus_mute(0, global.sound_muted)
	global.save_data()
