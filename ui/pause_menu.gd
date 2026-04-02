extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	modulate.a = 0.0
	var tween = get_tree().create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "modulate:a", 1.0, 0.15)

func _on_BtnResume_pressed():
	audio_manager.play_sfx("button_click")
	get_tree().paused = false
	queue_free()

func _on_BtnQuit_pressed():
	audio_manager.play_sfx("button_click")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/start_menu.tscn")
