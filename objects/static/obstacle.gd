extends StaticBody2D

@export var is_destructible: bool = true
@export var scroll_speed: float = 650.0  # Used only for dynamic rocket obstacles
var is_rocket: bool = false
var player: Node2D = null

func _ready() -> void:
	add_to_group("obstacles")
	player = get_tree().get_first_node_in_group("player")
	
	if is_rocket:
		# Use the existing sprite inside CollisionShape2D
		var sprite = $CollisionShape2D/Sprite2D
		sprite.texture = preload("res://assets/gigarette.png")
		sprite.flip_h = true  # Orient cigarette so lit end faces player (left)
		sprite.scale = Vector2(0.09, 0.09)
		sprite.position = Vector2(0, -10)
		
		# Shrink collision to match cigarette body
		var cs = RectangleShape2D.new()
		cs.size = Vector2(100, 28)
		$CollisionShape2D.shape = cs
		$CollisionShape2D.position = Vector2(0, 0)
		
		if has_node("Area2D/CollisionShape2D"):
			var acs = RectangleShape2D.new()
			acs.size = Vector2(110, 36)
			$Area2D/CollisionShape2D.shape = acs
			$Area2D/CollisionShape2D.position = Vector2(0, 0)
		
		# Enable smoke particles from the lit end
		if has_node("SmokeParticles"):
			var smoke = $SmokeParticles
			# Lit end is right side of cigarette (flip_h=true so filter end is left)
			# In world space cigarette travels left, so lit end is at right (+x)
			smoke.position = Vector2(50, -18)
			smoke.emitting = true

func _physics_process(delta: float) -> void:
	# --- Static behavior ---
	if player:
		if global_position.x < player.global_position.x - 1000:
			queue_free()
		
		# Simple destroy condition
		if not is_rocket and player.global_position.x == global_position.x and player.global_position.y <= global_position.y:
			destroy()
		
	# --- Dynamic Rocket movement ---
	if is_rocket:
		global_position.x -= scroll_speed * delta

func destroy() -> void:
	print("Obstacle destroyed!")

	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", true)

	# Stop smoke on destroy
	if has_node("SmokeParticles"):
		$SmokeParticles.emitting = false

	# Optional animation
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("destroy")
		$AnimationPlayer.connect("animation_finished", Callable(self, "queue_free"))
	else:
		queue_free()

func _on_area_2d_body_entered(body: Node) -> void:
	if is_rocket and body.is_in_group("player"):
		if not body.is_invulnerable and not body.is_dashing:
			body.take_damage()
		destroy()
