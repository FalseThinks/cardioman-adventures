extends ParallaxBackground

@export var scroll_speed := 50.0
@export var smooth_factor := 0.1  # Controls how quickly the scrolling adapts

var current_direction := 0.0

func _ready() -> void:
	for layer in get_children():
		if layer is ParallaxLayer:
			layer.visible = true

			# Set motion mirroring to sprite width if not set
			for sprite in layer.get_children():
				if sprite is Sprite2D and sprite.texture:
					if layer.motion_mirroring.x == 0:
						var tex_width = sprite.texture.get_width() * sprite.scale.x
						layer.motion_mirroring.x = tex_width
					sprite.visible = true

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var target_direction := 0.0
	if abs(player.velocity.x) > 0.5:
		target_direction = sign(player.velocity.x)

	current_direction = lerp(current_direction, target_direction, smooth_factor)

	for layer in get_children():
		if layer is ParallaxLayer:
			var motion = layer.motion_offset
			motion.x += current_direction * scroll_speed * delta

			# Prevent overflow — wrap motion_offset based on mirroring
			var wrap_width = layer.motion_mirroring.x
			if wrap_width > 0:
				motion.x = fposmod(motion.x, wrap_width)

			layer.motion_offset = motion
