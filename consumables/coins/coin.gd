extends Area2D

var anim_timer = 0.0

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	add_to_group("coins")
	anim_timer = randf() * 10.0

func _process(delta):
	anim_timer += delta
	# Bobbing and pulse animation
	$Sprite2D.position.y = sin(anim_timer * 2.5) * 8.0
	var s = 0.12 + sin(anim_timer * 4.0) * 0.01
	$Sprite2D.scale = Vector2(s, s)

	# Magnet: smoothly attract toward player when close
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.distance_to(player.global_position) < 150.0:
		global_position = global_position.lerp(player.global_position, delta * 8.0)

func _on_body_entered(body):
	if body.is_in_group("player"):
		_spawn_particles(global_position, Color(1.0, 0.85, 0.0))
		audio_manager.play_sfx("coin_collect")
		global.add_coin()
		queue_free()

func _spawn_particles(pos: Vector2, color: Color):
	var particles = CPUParticles2D.new()
	get_tree().current_scene.add_child(particles)
	particles.global_position = pos
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.95
	particles.amount = 10
	particles.lifetime = 0.5
	particles.direction = Vector2(0, -1)
	particles.spread = 180.0
	particles.gravity = Vector2(0, 300)
	particles.initial_velocity_min = 60.0
	particles.initial_velocity_max = 130.0
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 5.0
	particles.color = color
	get_tree().create_timer(particles.lifetime + 0.2).timeout.connect(particles.queue_free)
