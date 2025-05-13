extends Node2D

var obstacle_scene = preload("res://objects/static/obstacle.tscn")
var spawn_timer = 1.5
var elapsed_time = 0
var min_distance_between_obstacles = 100  # Minimum horizontal distance
var last_obstacle_position = Vector2.ZERO
var consecutive_obstacles = 0  # To track consecutive obstacles spawned
var max_consecutive_obstacles = 3  # Max obstacles in a row before space is required

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		last_obstacle_position = Vector2(player.global_position.x + 1200, 2)

func _process(delta):
	elapsed_time += delta

	if elapsed_time >= spawn_timer:
		if can_spawn_obstacle():
			spawn_obstacle()
			elapsed_time = 0
			spawn_timer = randf_range(1.0, 2.5)

func can_spawn_obstacle() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false

	var min_x_position = last_obstacle_position.x + min_distance_between_obstacles
	var next_spawn_x = player.global_position.x + get_viewport().get_visible_rect().size.x * 0.7

	# Ensure we don't spawn too soon, allowing for at least the minimum distance
	return next_spawn_x > min_x_position and consecutive_obstacles < max_consecutive_obstacles

func spawn_obstacle():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# Calculate spawn position based on player
	var screen_width = get_viewport().get_visible_rect().size.x
	var spawn_x = player.global_position.x + screen_width * 0.7
	var spawn_y = 2  # Use the floor Y position for consistency

	# Prevent overlap: Make sure we are not spawning too close to the last obstacle
	if spawn_x <= last_obstacle_position.x + min_distance_between_obstacles:
		return

	var obstacle = obstacle_scene.instantiate()
	obstacle.position = Vector2(spawn_x, spawn_y)
	obstacle.visible = true

	if obstacle.has_node("Sprite2D"):
		obstacle.get_node("Sprite2D").visible = true

	add_child(obstacle)

	# Update last obstacle position and reset consecutive obstacle count
	last_obstacle_position = obstacle.global_position
	consecutive_obstacles += 1

	# If we spawn 3 obstacles in a row, reset the counter and allow a bigger gap for the next set
	if consecutive_obstacles >= max_consecutive_obstacles:
		consecutive_obstacles = 0
		last_obstacle_position.x += min_distance_between_obstacles * 3  # Add extra distance to avoid overlap
