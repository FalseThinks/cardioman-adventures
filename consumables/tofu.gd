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
		body.current_stamina = min(body.current_stamina + stamina_heal, body.max_stamina)
		body.stamina_bar.update_stamina_bar(body.current_stamina, body.max_stamina)
		_spawn_particles(global_position)
		audio_manager.play_sfx("heal")
		queue_free()

func _spawn_particles(pos: Vector2):
	var particles = CPUParticles2D.new()
	get_tree().current_scene.add_child(particles)
	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.amount = 12
	particles.lifetime = 0.6
	particles.direction = Vector2(0, -1)
	particles.spread = 120.0
	particles.gravity = Vector2(0, 200)
	particles.initial_velocity_min = 40.0
	particles.initial_velocity_max = 100.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = Color(0.3, 0.9, 0.3)
	get_tree().create_timer(particles.lifetime + 0.2).timeout.connect(particles.queue_free)
