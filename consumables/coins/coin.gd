extends Area2D
signal collected

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	add_to_group("coins")
	
func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("coin_collected")
		global.add_coin()
		queue_free()
