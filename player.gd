extends CharacterBody2D

@onready var tex_run = preload("res://assets/tracksuit_run.png")
@onready var tex_jump = preload("res://assets/tracksuit_jump.png")
@onready var tex_dash = preload("res://assets/tracksuit_dash.png")
@onready var tex_double_jump = preload("res://assets/tracksuit_double_jump.png")
# === Movement ===
var speed = 300
var jump_power = -600
var gravity = 1200

# === Dash ===
var dash_power = 600
var dash_duration = 0.4
var dash_cooldown = 1.0
var can_dash = true
var is_dashing = false

# === Double Jump ===
var can_double_jump = false
var is_double_jumping = false 
var flip_tween: Tween = null
var floor_y: float = global.FLOOR_Y

# === Stamina & Dash UI ===
var is_game_over = false
var upgrade_menu_scene = preload("res://ui/upgrade_menu.tscn")
@onready var stamina_bar = $"../CanvasLayer/Control/HBox/StaminaBar"
@onready var dash_cd_ui = $"../CanvasLayer/Control/HBox/DashCD"
var dash_cooldown_time_left = 0.0

var max_stamina = 500
var current_stamina = 500
var stamina_drain_rate = 5
var jump_stamina_cost = 5
var dash_stamina_cost = 10
var stamina_penalty_object = 20

# === Camera ===
@onready var camera = $Camera2D

# === Dash Hitbox === (optional, not used directly here)
@onready var dash_hitbox = $DashHitbox

# === Invulnerability ===
var is_invulnerable = false
var invulnerability_time = 1.5
var blink_timer = null

func _ready():
	speed = 300 + global.velocity_level * 50
	max_stamina = 500 + global.stamina_level * 100
	stamina_penalty_object = max(5, 20 - global.dmg_reduction_level * 3)
	jump_stamina_cost = max(1, 5 - global.jump_cost_level * 1)
	dash_stamina_cost = max(2, 10 - global.dash_cost_level * 2)
	dash_cooldown = max(0.5, 3.0 - global.dash_cd_level * 0.2) # Increased base cooldown

	current_stamina = max_stamina
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina

	dash_hitbox.connect("body_entered", Callable(self, "_on_dash_hitbox_body_entered"))
	
	# Configure camera and connections
	add_to_group("player")
	$Camera2D.offset.x = get_viewport_rect().size.x * 0.3
	$Camera2D.limit_left = global_position.x - 10
	$Sprite2D.scale = Vector2(0.7, 0.7)
	$Sprite2D.position.y = 19.0

	if dash_cd_ui:
		dash_cd_ui.max_value = dash_cooldown
		dash_cd_ui.value = dash_cooldown

var anim_time = 0.0
var anim_timer = 0.0

func _process(delta):
	# === Dash UI Update ===
	if not can_dash and not is_dashing:
		var previous_time = dash_cooldown_time_left
		dash_cooldown_time_left -= delta
		if dash_cooldown_time_left <= 0:
			dash_cooldown_time_left = 0
			can_dash = true
			if dash_cd_ui:
				# Ready Shine Effect
				var tween = get_tree().create_tween()
				tween.tween_property(dash_cd_ui, "scale", Vector2(1.2, 1.2), 0.1)
				tween.parallel().tween_property(dash_cd_ui, "modulate", Color(2, 2, 2, 1), 0.1)
				tween.tween_property(dash_cd_ui, "scale", Vector2(1.0, 1.0), 0.2)
				tween.parallel().tween_property(dash_cd_ui, "modulate", Color(1, 1, 1, 1), 0.2)
			
	if dash_cd_ui:
		dash_cd_ui.max_value = dash_cooldown
		if can_dash:
			dash_cd_ui.value = dash_cooldown
			var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.01) * 0.05
			dash_cd_ui.scale = Vector2(pulse, pulse)
		else:
			dash_cd_ui.value = clamp(dash_cooldown - dash_cooldown_time_left, 0, dash_cooldown)
			dash_cd_ui.scale = Vector2(1.0, 1.0)
			
	if is_game_over:
		$Sprite2D.frame = 0
		return

	if is_on_floor() and not is_dashing:
		floor_y = global_position.y
		if is_double_jumping:
			$Sprite2D.scale = Vector2(0.7, 0.7)
		is_double_jumping = false
		$Sprite2D.texture = tex_run
		$Sprite2D.hframes = 4
		$Sprite2D.vframes = 3
		$Sprite2D.scale = Vector2(0.7, 0.7)
		$Sprite2D.position.y = 19.0
		$Sprite2D.flip_h = false
		if velocity.x > 0:
			anim_timer += delta * (velocity.x / speed) * 12.0
			$Sprite2D.frame = int(anim_timer) % 12
		else:
			$Sprite2D.frame = 0
	else:
		if is_dashing:
			$Sprite2D.texture = tex_dash
			$Sprite2D.hframes = 2
			$Sprite2D.vframes = 4
			$Sprite2D.scale = Vector2(0.7, 0.7)
			$Sprite2D.position.y = 30.0
			$Sprite2D.flip_h = false
			anim_timer += delta * 16.0
			$Sprite2D.frame = int(anim_timer) % 8
		elif is_double_jumping:
			$Sprite2D.texture = tex_double_jump
			$Sprite2D.hframes = 4
			$Sprite2D.vframes = 2
			$Sprite2D.scale = Vector2(0.7, 0.7)
			$Sprite2D.position.y = 19.0
			# High speed spin (cycle through all 8 frames)
			anim_timer += delta * 14.0
			$Sprite2D.frame = int(anim_timer) % 8
		else:
			$Sprite2D.texture = tex_jump
			$Sprite2D.hframes = 4
			$Sprite2D.vframes = 2
			$Sprite2D.scale = Vector2(0.7, 0.7)
			$Sprite2D.position.y = 19.0
			if velocity.y < -100:
				$Sprite2D.frame = 1 # Rising
			elif velocity.y > 100:
				$Sprite2D.frame = 3 # Falling
			else:
				$Sprite2D.frame = 2 # High point

func _physics_process(delta):
	# === Gravity ===
	velocity.y += gravity * delta

	if is_game_over:
		move_and_slide()
		return

	# === Horizontal Movement ===
	velocity.x = dash_power if is_dashing else speed

	if is_on_floor():
		can_double_jump = true

	# === Jumping ===
	if Input.is_action_just_pressed("jump") and current_stamina >= jump_stamina_cost:
		if is_on_floor():
			velocity.y = jump_power
			current_stamina -= jump_stamina_cost
		elif can_double_jump:
			velocity.y = jump_power
			current_stamina -= jump_stamina_cost
			can_double_jump = false
			do_flip()

	# === Dashing ===
	if Input.is_action_just_pressed("dash") and can_dash and current_stamina >= dash_stamina_cost:
		dash()

	# === Stamina Drain ===
	current_stamina -= stamina_drain_rate * delta
	current_stamina = clamp(current_stamina, 0, max_stamina)
	stamina_bar.update_stamina_bar(current_stamina, max_stamina)
	
	if current_stamina == 0 and not is_game_over:
		trigger_game_over()


	move_and_slide()

func take_damage():
	print("Taking damage from obstacle/projectile!")
	current_stamina -= stamina_penalty_object
	stamina_bar.flash_stamina(Color.RED)
	start_invulnerability()

# === Dash ===
func dash():
	current_stamina -= dash_stamina_cost
	can_dash = false
	is_dashing = true
	print("Dash started!")

	var dash_timer = get_tree().create_timer(dash_duration)
	dash_timer.timeout.connect(func():
		print("Dash ended!")
		end_dash()
	)

func end_dash():
	# Reset dash
	velocity.x = speed  # Return to regular movement speed
	is_dashing = false  # Set dashing state to false
	
	# Create cooldown timer in _process handles can_dash = true now
	dash_cooldown_time_left = dash_cooldown

# This function handles the collision between the DashHitbox and an obstacle
func _on_dash_hitbox_body_entered(body: Node) -> void:
	if body is StaticBody2D and body.has_method("destroy"):
		if is_dashing:
			# When dashing, always destroy obstacles
			global.add_coin()
			body.destroy()
		else:
			# Check if collision is from the left side
			var player_right = global_position.x + $CollisionShape2D.shape.size.x / 2.0
			var obstacle_left = body.global_position.x - body.get_node("CollisionShape2D").shape.size.x / 2.0
			var is_frontal_collision = player_right >= obstacle_left and global_position.x < body.global_position.x
			
			if is_frontal_collision:
				if is_invulnerable:
					# During invulnerability, just destroy the obstacle for left-side collisions
					body.destroy()
				else:
					# Not invulnerable, take damage
					print("Taking damage from obstacle!")
					current_stamina -= stamina_penalty_object
					stamina_bar.flash_stamina(Color.RED)
					start_invulnerability()
					body.destroy()

# === Invulnerability Blink ===
func start_invulnerability():
	is_invulnerable = true
	print("Player is now invulnerable")

	blink_timer = Timer.new()
	blink_timer.wait_time = 0.15
	blink_timer.one_shot = false
	blink_timer.timeout.connect(_on_blink_timeout)
	add_child(blink_timer)
	blink_timer.start()

	await get_tree().create_timer(invulnerability_time).timeout

	is_invulnerable = false
	print("Player is no longer invulnerable")

	if blink_timer:
		blink_timer.stop()
		blink_timer.queue_free()
		blink_timer = null
		$Sprite2D.visible = true

func _on_blink_timeout():
	$Sprite2D.visible = !$Sprite2D.visible

# Removed redundant coin collection signals

func trigger_game_over():
	is_game_over = true
	velocity.x = 0
	var menu = upgrade_menu_scene.instantiate()
	$"../CanvasLayer".add_child(menu)
	get_tree().paused = true

# === Double Jump Flip ===
func do_flip():
	is_double_jumping = true
	$Sprite2D.rotation = 0
	if flip_tween and flip_tween.is_valid():
		flip_tween.kill()
	# Curl into ball for double jump
	flip_tween = get_tree().create_tween()
	flip_tween.tween_property($Sprite2D, "scale", Vector2(0.7, 0.7), 0.1)
