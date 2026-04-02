extends Area2D

@export var stamina_heal = 50
var anim_timer = 0.0
var bob_offset = 0.0

func _ready():
	stamina_heal = 50 + (global.apple_level * 15)
	if not is_connected("body_entered", _on_body_entered):
		connect("body_entered", _on_body_entered)

func _process(delta):
	# Spin through apple animation frames
	anim_timer += delta * 10.0
	var sprite = $Sprite2D
	sprite.frame = int(anim_timer) % 17
	
	# Gentle bobbing up and down
	bob_offset += delta * 3.0
	sprite.position.y = sin(bob_offset) * 5.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.current_stamina += stamina_heal
		if body.current_stamina > body.max_stamina:
			body.current_stamina = body.max_stamina
		body.stamina_bar.update_stamina_bar(body.current_stamina, body.max_stamina)
		queue_free()
