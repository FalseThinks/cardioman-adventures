extends Node

signal achievement_unlocked(id: String, title: String)

# Each achievement: {id, title, desc, check: Callable -> bool}
var _definitions: Array = []

# Toast UI (created once, reused)
var _toast_label: Label = null
var _toast_tween: Tween = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_define_achievements()
	global.connect("run_ended", _on_run_ended)
	_create_toast()

func _define_achievements():
	_definitions = [
		# Distance milestones
		{"id": "dist_100",  "title": "First Steps",       "desc": "Run 100m",               "check": func(): return global.best_distance >= 100},
		{"id": "dist_500",  "title": "Cardio Starter",    "desc": "Run 500m",               "check": func(): return global.best_distance >= 500},
		{"id": "dist_1000", "title": "Endurance Runner",  "desc": "Run 1000m",              "check": func(): return global.best_distance >= 1000},
		{"id": "dist_2000", "title": "Marathon Man",       "desc": "Run 2000m",              "check": func(): return global.best_distance >= 2000},
		{"id": "dist_5000", "title": "Unstoppable",        "desc": "Run 5000m",              "check": func(): return global.best_distance >= 5000},
		# Coin milestones
		{"id": "coins_50",  "title": "Pocket Change",     "desc": "Earn 50 coins total",    "check": func(): return global.total_coins_earned >= 50},
		{"id": "coins_200", "title": "Coin Collector",    "desc": "Earn 200 coins total",   "check": func(): return global.total_coins_earned >= 200},
		{"id": "coins_500", "title": "Rich Runner",       "desc": "Earn 500 coins total",   "check": func(): return global.total_coins_earned >= 500},
		# Obstacle milestones
		{"id": "obs_10",    "title": "Smasher",           "desc": "Destroy 10 obstacles",   "check": func(): return global.total_obstacles_destroyed >= 10},
		{"id": "obs_50",    "title": "Wrecking Ball",     "desc": "Destroy 50 obstacles",   "check": func(): return global.total_obstacles_destroyed >= 50},
		{"id": "obs_200",   "title": "Demolition Expert", "desc": "Destroy 200 obstacles",  "check": func(): return global.total_obstacles_destroyed >= 200},
		# Run count
		{"id": "runs_5",    "title": "Persistent",        "desc": "Complete 5 runs",        "check": func(): return global.total_runs >= 5},
		{"id": "runs_25",   "title": "Dedicated",         "desc": "Complete 25 runs",       "check": func(): return global.total_runs >= 25},
		# Single-run feats
		{"id": "run_coins_20", "title": "Gold Rush",      "desc": "Earn 20 coins in one run", "check": func(): return global.run_coins >= 20},
		{"id": "run_obs_10",   "title": "Dash Master",    "desc": "Destroy 10 obstacles in one run", "check": func(): return global.run_obstacles >= 10},
	]

func _on_run_ended(_summary: Dictionary):
	check_all()

func get_all() -> Array:
	return _definitions

func check_all():
	for def in _definitions:
		if def["id"] in global.unlocked_achievements:
			continue
		if def["check"].call():
			_unlock(def)

func _unlock(def: Dictionary):
	global.unlocked_achievements.append(def["id"])
	global.save_data()
	emit_signal("achievement_unlocked", def["id"], def["title"])
	_show_toast(def["title"])
	audio_manager.play_sfx("achievement")

# --- Toast popup ---

func _create_toast():
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	canvas.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas)

	_toast_label = Label.new()
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.add_theme_font_size_override("font_size", 18)
	_toast_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
	_toast_label.anchors_preset = Control.PRESET_CENTER_TOP
	_toast_label.position.y = -50
	_toast_label.modulate.a = 0.0
	canvas.add_child(_toast_label)

func _show_toast(title: String):
	_toast_label.text = "Achievement: " + title
	_toast_label.position.y = -50
	_toast_label.modulate.a = 0.0

	# Recenter horizontally
	var vp_width = _toast_label.get_viewport_rect().size.x
	_toast_label.position.x = vp_width / 2.0 - 150

	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()

	_toast_tween = get_tree().create_tween()
	_toast_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# Slide in
	_toast_tween.set_parallel(true)
	_toast_tween.tween_property(_toast_label, "position:y", 20.0, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	_toast_tween.tween_property(_toast_label, "modulate:a", 1.0, 0.2)
	# Hold, then fade out
	_toast_tween.set_parallel(false)
	_toast_tween.tween_interval(2.0)
	_toast_tween.tween_property(_toast_label, "modulate:a", 0.0, 0.5)
