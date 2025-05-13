extends StaticBody2D

@onready var other_ground = get_node("../Ground2")  # Reference to the other ground
@export var ground_width := 1024.0  # Set this to your ground sprite width
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	# Get the width from the sprite if not set
	if ground_width == 0 and $CollisionShape2D/Sprite2D:
		ground_width = $CollisionShape2D/Sprite2D.texture.get_width()
	
	# Ensure player is accessible
	if not player:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if not player:
		return
		
	var camera_pos = player.global_position.x
	var screen_width = get_viewport().get_visible_rect().size.x
	
	# If this ground piece is too far left (off-screen), move it to the right
	if global_position.x + ground_width < camera_pos - screen_width / 2:
		# Place it right after the other ground
		global_position.x = other_ground.global_position.x + ground_width
