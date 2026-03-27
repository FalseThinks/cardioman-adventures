extends ParallaxBackground

@export var scroll_speed := 50.0
@export var smooth_factor := 0.1  # Controls how quickly the scrolling adapts

var biomes = [
	Color(1.0, 1.0, 1.0),       # Day Normal / Grass
	Color(1.0, 0.8, 0.6),       # Sunset / Desert
	Color(0.4, 0.4, 0.6),       # Night / Blue
	Color(0.8, 0.6, 0.8),       # Magic / Purple
	Color(1.0, 0.5, 0.5)        # Lava / Red
]

var current_direction := 0.0

func _ready() -> void:
	for layer in get_children():
		if layer is ParallaxLayer:
			layer.visible = true

			# Only proceed if the layer has children
			if layer.get_child_count() == 0:
				continue

			var first_sprite := layer.get_child(0)
			if first_sprite is Sprite2D and first_sprite.texture:
				var tex_width:float = first_sprite.texture.get_width() * first_sprite.scale.x

				# Duplicate sprite for seamless wrap if only one exists
				if layer.get_child_count() == 1:
					var clone := first_sprite.duplicate()
					clone.position.x += tex_width
					layer.add_child(clone)

				# Set motion mirroring to match one sprite width
				layer.motion_mirroring.x = tex_width

				# Ensure all sprites are visible
				for sprite in layer.get_children():
					if sprite is Sprite2D:
						sprite.visible = true

func _process(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var target_direction := 0.0
	if abs(player.velocity.x) > 0.5:
		target_direction = sign(player.velocity.x)

	current_direction = lerp(current_direction, target_direction, smooth_factor)

	var distance = max(0, player.global_position.x - 571)
	var meters = int(distance / 100.0)
	var biome_index = (meters / 500) % biomes.size()
	var target_color = biomes[biome_index]

	for layer in get_children():
		if layer is ParallaxLayer:
			var motion = layer.motion_offset
			motion.x += current_direction * scroll_speed * delta

			# Wrap the motion offset to prevent overflow
			var wrap_width = layer.motion_mirroring.x
			if wrap_width > 0:
				motion.x = fposmod(motion.x, wrap_width)

			layer.motion_offset = motion
			
			for sprite in layer.get_children():
				if sprite is Sprite2D:
					sprite.modulate = sprite.modulate.lerp(target_color, 2.0 * delta)
