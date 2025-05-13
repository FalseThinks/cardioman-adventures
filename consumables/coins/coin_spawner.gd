extends Node2D

var obstacle_scene = preload("res://objects/static/obstacle.tscn")
var coin_scene = preload("res://consumables/coins/coin.tscn")  # preload your coin scene

var spawn_timer = 1.5
var elapsed_time = 0
var min_distance_between_obstacles = 100
var last_obstacle_position = Vector2.ZERO

@export var coin_chance: float = 0.4  # 40% chance to spawn a coin with obstacle

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		last_obstacle_position = Vector2(player.global_position.x + 1200, 0)

func _process(delta):
	elapsed_time += delta
	
	if elapsed_time >= spawn_timer:
		if can_spawn_obstacle():
			spawn_obstacle()
			elapsed_time = 0
			spawn_timer = randf_range(1.0, 2.5)

func can_spawn_obstacle():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return false
		
	var min_x_position = last_obstacle_position.x + min_distance_between_obstacles
	var player_screen_pos = player.global_position.x + get_viewport().get_visible_rect().size.x
	
	return player_screen_pos > min_x_position

func spawn_obstacle():
	var obstacle = obstacle_scene.instantiate()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var screen_width = get_viewport().get_visible_rect().size.x
		var spawn_x = player.global_position.x + screen_width * 1.1
		var ground_y = player.global_position.y

		obstacle.position = Vector2(spawn_x, ground_y)
		last_obstacle_position = obstacle.position
	else:
		obstacle.position = Vector2(1200, 500)

	add_child(obstacle)

	# 🎲 Try to spawn a coin near this obstacle
	if randf() < coin_chance:
		spawn_coin_near(obstacle.position)

func spawn_coin_near(position: Vector2):
	var coin = coin_scene.instantiate()
	# Random offset above the obstacle
	var y_offset = -randf_range(50, 120)
	coin.position = position + Vector2(0, y_offset)
	add_child(coin)

	# Optional: connect collected signal if coin uses it
	if coin.has_signal("coin_collected"):
		coin.connect("coin_collected", _on_coin_collected)

func _on_coin_collected():
	global.add_coin()
