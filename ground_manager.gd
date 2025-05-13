extends Node2D

@onready var ground1 = $Ground1
@onready var ground2 = $Ground2
@export var ground_width := 1024.0
@onready var player = get_tree().get_first_node_in_group("player")

# Track when we last repositioned each ground piece
var ground1_last_reposition = 0
var ground2_last_reposition = 0
# Safety buffer to prevent rapid repositioning
var reposition_buffer = 100

func _ready():
	# Set up initial positions
	ground1.position.x = 0
	ground2.position.x = ground_width
	
	# Ensure we have the player
	if not player:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if not player:
		return
		
	var camera_pos = player.global_position.x
	var screen_width = get_viewport().get_visible_rect().size.x
	var half_screen = screen_width / 2
	
	# Check ground pieces with a larger threshold to ensure they're completely off-screen
	var check_pos = camera_pos - half_screen - 450  # Add extra safety margin
	
	# Use absolute position tracking to avoid issues
	var current_player_x = player.global_position.x
	
	# Check if ground1 is off-screen and hasn't been repositioned recently
	if ground1.position.x + ground_width < check_pos and current_player_x > ground1_last_reposition + reposition_buffer:
		# Move it to the right
		ground1.position.x = ground2.position.x + ground_width
		ground1_last_reposition = current_player_x
		
	# Check if ground2 is off-screen and hasn't been repositioned recently
	if ground2.position.x + ground_width < check_pos and current_player_x > ground2_last_reposition + reposition_buffer:
		# Move it to the right
		ground2.position.x = ground1.position.x + ground_width
		ground2_last_reposition = current_player_x
