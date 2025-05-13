extends CharacterBody2D

# Character movement variables
var speed = 300
var jump_power = -600
var gravity = 1200
var dash_power = 600
var dash_duration = 0.4
var dash_cooldown = 1.0
var can_dash = true
var is_dashing = false

@onready var stamina_bar = $"../CanvasLayer/Control/StaminaBar"
@onready var dash_hitbox = $DashHitbox  # Reference to DashHitbox node

var max_stamina = 500
var current_stamina = 500
var stamina_drain_rate = 5
var jump_stamina_cost = 5
var dash_stamina_cost = 10
var stamina_penalty_object = 20

var is_invulnerable = false
var invulnerability_time = 1.5 # seconds
var blink_timer = null

func _ready():
	current_stamina = max_stamina
	stamina_bar.max_value = max_stamina
	stamina_bar.value = current_stamina

	dash_hitbox.connect("body_entered", Callable(self, "_on_dash_hitbox_body_entered"))
	
	# Configure camera and connections
	add_to_group("player")
	$Camera2D.offset.x = get_viewport_rect().size.x * 0.3
	$Camera2D.limit_left = global_position.x - 10
	connect_to_coins()
	
	# Connect to any coins that spawn later
	get_tree().connect("node_added", Callable(self, "_on_node_added"))

func _physics_process(delta):
	# Apply gravity
	velocity.y += gravity * delta

	# Horizontal movement (always running, except during dashing)
	if not is_dashing:
		velocity.x = speed
	else:
		velocity.x = dash_power  # Dash speed while dashing
	
	# Handle jumping
	if Input.is_action_just_pressed("jump") and is_on_floor() and current_stamina >= jump_stamina_cost:
		velocity.y = jump_power
		current_stamina -= jump_stamina_cost

	# Handle dashing
	if Input.is_action_just_pressed("dash") and can_dash and current_stamina >= dash_stamina_cost:
		dash()

	# Drain stamina over time
	current_stamina -= stamina_drain_rate * delta
	current_stamina = clamp(current_stamina, 0, max_stamina)
	stamina_bar.update_stamina_bar(current_stamina, max_stamina)

	# Apply movement and handle collisions
	var collision = move_and_collide(velocity * delta, true) # Test collision only
	if collision:
		var collider = collision.get_collider()
		if collider is StaticBody2D and collider.has_method("destroy"):
			var normal = collision.get_normal()
			
			# Handle different collision scenarios based on direction and player state
			if is_dashing:
				# When dashing, destroy obstacles regardless of direction
				collider.destroy()
			elif is_invulnerable:
				# During invulnerability, only destroy obstacles on LEFT collision (frontal)
				# Normal.x > 0 means collision from the left
				if normal.x > 0:
					collider.destroy()
			else:
				# Not dashing or invulnerable, take damage only from frontal collision
				if normal.x > 0:
					print("Frontal collision with obstacle! Taking damage...")
					current_stamina -= stamina_penalty_object
					stamina_bar.flash_stamina(Color.RED)  # <- ADD THIS LINE
					start_invulnerability()
					collider.destroy()
	
	# Actually move the player
	move_and_slide()

func dash():
	current_stamina -= dash_stamina_cost
	can_dash = false
	is_dashing = true  # Set dashing state to true
	
	print("Dash started!")
	
	# Create a timer to end the dash
	var dash_timer = get_tree().create_timer(dash_duration)
	dash_timer.timeout.connect(func():
		print("Dash ended!")
		end_dash()
	)

func end_dash():
	# Reset dash
	velocity.x = speed  # Return to regular movement speed
	is_dashing = false  # Set dashing state to false
	
	# Create cooldown timer
	var cooldown_timer = get_tree().create_timer(dash_cooldown)
	cooldown_timer.timeout.connect(func(): can_dash = true)

# This function handles the collision between the DashHitbox and an obstacle
func _on_dash_hitbox_body_entered(body: Node) -> void:
	if body is StaticBody2D and body.has_method("destroy"):
		if is_dashing:
			# When dashing, always destroy obstacles
			global.add_coin()
			body.destroy()
		else:
			# Check if collision is from the left side
			var player_right = global_position.x + $CollisionShape2D.shape.extents.x
			var obstacle_left = body.global_position.x - body.get_node("CollisionShape2D").shape.extents.x
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

func start_invulnerability() -> void:
	is_invulnerable = true
	print("Player is now invulnerable")

	# Start blinking effect
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
	$Sprite2D.visible = !$Sprite2D.visible  # Toggle visibility for blinking

func is_overlapping_static() -> bool:
	for body in get_overlapping_bodies():
		if body is StaticBody2D:
			return true
	return false

func get_overlapping_bodies() -> Array:
	return dash_hitbox.get_overlapping_bodies()

func connect_to_coins():
	var existing_coins = get_tree().get_nodes_in_group("coins")
	for coin in existing_coins:
		if !coin.is_connected("coin_collected", Callable(self, "_on_coin_collected")):
			coin.connect("coin_collected", Callable(self, "_on_coin_collected"))

func _on_node_added(node):
	if node.is_in_group("coins"):
		node.connect("coin_collected", Callable(self, "_on_coin_collected"))

func _on_coin_collected():
	global.add_coin()
