extends Node2D

var obstacle_scene = preload("res://objects/static/obstacle.tscn")
var coin_scene = preload("res://consumables/coins/coin.tscn")
var tofu_scene = preload("res://consumables/tofu.tscn")
var spawn_timer = 1.5
var elapsed_time = 0
var min_distance_between_batches = 1500  # Distance between batches of obstacles
var last_spawn_x = 0.0
var spawn_y = 470.0  # Fixed position just above the floor
var obstacle_width = 0

func _ready():
	var player = get_tree().get_first_node_in_group("player")

	if player:
		# Store the player's initial X position when the scene starts
		last_spawn_x = player.global_position.x + 800

	# Set the spawn_y to the fixed value above the floor
	# If you want to calculate the height dynamically, make sure it's set correctly (e.g., floor height).
	# Here it's fixed at 550 for now.

func _process(delta):
	elapsed_time += delta

	if elapsed_time >= spawn_timer:
		var player = get_tree().get_first_node_in_group("player")
		if not player:
			return

		# Get screen width for spawn position calculation
		var screen_width = get_viewport().get_visible_rect().size.x
		var spawn_x = player.global_position.x + screen_width * 1.5

		# Avoid multiple spawn batches happening too close to each other
		if spawn_x >= last_spawn_x + min_distance_between_batches:
			spawn_obstacle_batch(spawn_x)
			last_spawn_x = spawn_x
			elapsed_time = 0
			spawn_timer = randf_range(1.0, 2.5)  # Randomize spawn interval for variety

func spawn_obstacle_batch(start_x: float):
	var obstacle_count = randi_range(1, 2)  # Randomly spawn 1 to 2 obstacles to reduce clutter
	var player = get_tree().get_first_node_in_group("player")
	var ground_y = player.floor_y if player else global.FLOOR_Y
	
	# Ensure obstacles spawn at a fixed height
	for i in range(obstacle_count):
		var obstacle = obstacle_scene.instantiate()
		
		# Give a massive flat buffer between spawned batch nodes to prevent overlapping
		var offset_x = (i * randf_range(700, 1100)) + 600
		
		# Set is_rocket BEFORE add_child so _ready() can configure the rocket properly
		if randf() < 0.3:
			obstacle.is_rocket = true
			
		add_child(obstacle) # Add the obstacle to the scene
		
		obstacle.global_position = Vector2(start_x + offset_x, ground_y + 10)  # Anchor to player feet
		obstacle.visible = true

		var sprite_node = obstacle.find_child("Sprite2D")
		if sprite_node:
			sprite_node.visible = true

		if randf() < 0.4 and not obstacle.is_rocket:
			var item
			if randf() < 0.25:
				item = tofu_scene.instantiate()
			else:
				item = coin_scene.instantiate()

			# Parent to spawner (not obstacle) so item survives when obstacle is destroyed
			add_child(item)
			item.global_position = Vector2(start_x + offset_x, (ground_y + 10) - randf_range(50, 120))

		# Add the obstacle to the scene
		# Removed duplicate add_child(obstacle)
