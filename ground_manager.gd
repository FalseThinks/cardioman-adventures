extends Node2D

@onready var ground1 = $Ground1
@onready var ground2 = $Ground2
@onready var ground3 = $Ground3
@export var ground_width := 1072.0
@onready var player = get_tree().get_first_node_in_group("player")

@onready var pieces = [ground1, ground2, ground3]

# Music tracks per biome — filenames without extension, placed in audio/music/
const BIOME_MUSIC := ["biome_day", "biome_sunset", "biome_night", "biome_magic", "biome_lava"]
var _last_biome_index := -1

func _ready():
	# Initial positions
	for i in range(pieces.size()):
		pieces[i].position.x = i * ground_width
		# Shift region_rect to break tiling symmetry
		var sprite = pieces[i].get_node_or_null("Sprite2D")
		if sprite:
			sprite.region_rect.position.x = i * 200 # Different offset for each
	
	if not player:
		await get_tree().process_frame
		player = get_tree().get_first_node_in_group("player")

func _physics_process(_delta):
	if not player: return
	
	var current_player_x = player.global_position.x
	
	# Transition logic for 3 pieces:
	# Keep moving the leftmost piece to the far right as the player moves.
	# Sort pieces by X position to find the left and rightmost.
	pieces.sort_custom(func(a, b): return a.global_position.x < b.global_position.x)
	
	var leftmost = pieces[0]
	var rightmost = pieces[2]
	
	# If player is well into the second piece, move the leftmost to the right.
	# More precisely: if player x > midpoint of second piece.
	if current_player_x > pieces[1].global_position.x + (ground_width / 2.0):
		leftmost.global_position.x = rightmost.global_position.x + ground_width

	# Update colors
	var distance = max(0, current_player_x - global.PLAYER_START_X)
	var meters = int(distance / global.PIXELS_PER_METER)
	var biome_index = (meters / global.BIOME_DISTANCE) % global.BIOME_COLORS.size()
	var target_color = global.BIOME_COLORS[biome_index]

	# Crossfade music when entering a new biome
	if biome_index != _last_biome_index:
		_last_biome_index = biome_index
		audio_manager.play_music(BIOME_MUSIC[biome_index])
	
	for piece in pieces:
		var sprite = piece.get_node_or_null("Sprite2D")
		if sprite:
			sprite.modulate = sprite.modulate.lerp(target_color, 2.0 * _delta)
