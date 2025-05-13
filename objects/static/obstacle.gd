extends StaticBody2D

var is_destructible = true
var scroll_speed = 300  # Match this with your ground scroll speed

func _ready():
	# Initialize any obstacle-specific properties here
	add_to_group("obstacles")  # For easy access if needed

func _process(delta):
	# Check if the obstacle is far behind the player and can be removed
	var player = get_tree().get_first_node_in_group("player")
	if player and global_position.x < player.global_position.x - 1000:
		queue_free()

func destroy():
	print("Obstacle destroyed!")
	
	# Disable collision to allow the player to pass through immediately
	var collision_shape = $CollisionShape2D
	if collision_shape:
		collision_shape.disabled = true
	
	# Optional: Add destruction animation or effects here
	# var animation_player = $AnimationPlayer
	# if animation_player:
	#     animation_player.play("destroy")
	#     await animation_player.animation_finished
	
	# Queue the obstacle for removal from the scene
	queue_free()
