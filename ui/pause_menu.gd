extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_BtnResume_pressed():
	get_tree().paused = false
	queue_free()

func _on_BtnQuit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/start_menu.tscn")
