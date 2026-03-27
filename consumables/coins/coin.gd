extends Area2D
signal coin_collected

var anim_timer = 0.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	add_to_group("coins")
	# Randomize start phase for variety
	anim_timer = randf() * 10.0
	
func _process(delta):
	anim_timer += delta
	# Gentle bobbing
	$Sprite2D.position.y = sin(anim_timer * 2.5) * 8.0
	# Subtle pulsing pulse
	var s = 0.12 + sin(anim_timer * 4.0) * 0.01
	$Sprite2D.scale = Vector2(s, s)

func _on_body_entered(body):
	if body.is_in_group("player"):
		emit_signal("coin_collected")
		global.add_coin()
		queue_free()
