extends Node2D

const DifficultyManager = preload("res://difficulty_manager.gd")

var obstacle_scene = preload("res://objects/static/obstacle.tscn")
var coin_scene = preload("res://consumables/coins/coin.tscn")
var tofu_scene = preload("res://consumables/tofu.tscn")

var spawn_timer = 2.0
var elapsed_time = 0.0
var min_distance_between_batches = 1500
var last_spawn_x = 0.0

var player: Node = null
var difficulty_manager: Node = null

func _ready():
	difficulty_manager = DifficultyManager.new()
	add_child(difficulty_manager)

	player = get_tree().get_first_node_in_group("player")
	if not player:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")

	if player:
		last_spawn_x = player.global_position.x + 800

func _get_meters() -> int:
	if not player:
		return 0
	return int(max(0, player.global_position.x - global.PLAYER_START_X) / global.PIXELS_PER_METER)

func _process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return

	elapsed_time += delta
	var params = difficulty_manager.get_params(_get_meters())

	if elapsed_time >= spawn_timer:
		var screen_width = get_viewport().get_visible_rect().size.x
		var spawn_x = player.global_position.x + screen_width * 1.5

		if spawn_x >= last_spawn_x + min_distance_between_batches:
			spawn_obstacle_batch(spawn_x, params)
			last_spawn_x = spawn_x
			elapsed_time = 0.0
			spawn_timer = randf_range(params["spawn_min"], params["spawn_max"])

func spawn_obstacle_batch(start_x: float, params: Dictionary):
	var obstacle_count = randi_range(1, params["batch_max"])
	var ground_y = player.floor_y if player else global.FLOOR_Y

	for i in range(obstacle_count):
		var obstacle = obstacle_scene.instantiate()
		var offset_x = (i * randf_range(700, 1100)) + 600

		if randf() < params["rocket_chance"]:
			obstacle.is_rocket = true

		add_child(obstacle)
		obstacle.global_position = Vector2(start_x + offset_x, ground_y + 10)
		obstacle.visible = true

		var sprite_node = obstacle.find_child("Sprite2D")
		if sprite_node:
			sprite_node.visible = true

		if randf() < params["consumable_chance"] and not obstacle.is_rocket:
			var item
			if randf() < 0.25:
				item = tofu_scene.instantiate()
			else:
				item = coin_scene.instantiate()

			# Parent to spawner (not obstacle) so item survives obstacle destruction
			add_child(item)
			item.global_position = Vector2(start_x + offset_x, (ground_y + 10) - randf_range(50, 120))
