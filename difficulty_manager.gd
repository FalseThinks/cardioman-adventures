extends Node

# Returns spawning parameters for the given distance in meters.
# Called every frame by the spawner; tiers ramp up over time.
func get_params(meters: int) -> Dictionary:
	if meters < 200:
		# Tutorial zone: slow, no rockets
		return {
			"spawn_min": 2.0, "spawn_max": 3.5,
			"rocket_chance": 0.0,
			"batch_max": 1,
			"consumable_chance": 0.30
		}
	elif meters < 500:
		# Normal: original behavior
		return {
			"spawn_min": 1.0, "spawn_max": 2.5,
			"rocket_chance": 0.30,
			"batch_max": 2,
			"consumable_chance": 0.40
		}
	elif meters < 1000:
		# Heated: faster spawns, more rockets
		return {
			"spawn_min": 0.8, "spawn_max": 2.0,
			"rocket_chance": 0.40,
			"batch_max": 2,
			"consumable_chance": 0.35
		}
	elif meters < 2000:
		# Intense: tight gaps, lots of rockets
		return {
			"spawn_min": 0.6, "spawn_max": 1.5,
			"rocket_chance": 0.50,
			"batch_max": 2,
			"consumable_chance": 0.30
		}
	else:
		# Maximum difficulty
		return {
			"spawn_min": 0.5, "spawn_max": 1.2,
			"rocket_chance": 0.60,
			"batch_max": 2,
			"consumable_chance": 0.25
		}
