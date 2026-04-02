extends Button

var pause_menu_scene = preload("res://ui/pause_menu.tscn")
var pause_menu_instance: Control = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("pause") and not event.is_echo():
		toggle_pause()

func _pressed() -> void:
	toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused and pause_menu_instance == null:
		return
	if get_tree().paused:
		get_tree().paused = false
		if pause_menu_instance:
			pause_menu_instance.queue_free()
			pause_menu_instance = null
	else:
		get_tree().paused = true
		pause_menu_instance = pause_menu_scene.instantiate()
		get_parent().get_parent().add_child(pause_menu_instance)
