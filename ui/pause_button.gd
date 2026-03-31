extends Button

@onready var paused_label: Label = $"../PausedLabel"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	paused_label.process_mode = Node.PROCESS_MODE_ALWAYS
	paused_label.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		toggle_pause()

func _pressed() -> void:
	toggle_pause()

func toggle_pause() -> void:
	get_tree().paused = !get_tree().paused
	paused_label.visible = get_tree().paused
