extends Control

@onready var coins_label = $MainPanel/VBoxContainer/CoinsLabel
@onready var stats_container = $MainPanel/VBoxContainer/StatsContainer
@onready var main_panel = $MainPanel
@onready var options_panel = $OptionsPanel
@onready var sound_toggle = $OptionsPanel/VBoxContainer/SoundToggle

var achievements_panel: Panel = null
var skins_panel: Panel = null

func _ready():
	options_panel.visible = false
	main_panel.visible = true
	update_ui()
	sound_toggle.button_pressed = not global.sound_muted
	AudioServer.set_bus_mute(0, global.sound_muted)
	_build_achievements_panel()
	_build_skins_panel()
	_animate_panel_in(main_panel)

# ---------- UI update ----------

func update_ui():
	coins_label.text = "Coins: " + str(global.coins)

	var stats = stats_container.get_children()
	stats[0].text = "Velocity: Lvl " + str(global.velocity_level)
	stats[1].text = "Max Stamina: Lvl " + str(global.stamina_level)
	stats[2].text = "Dmg Reduction: Lvl " + str(global.dmg_reduction_level)
	stats[3].text = "Dash Cost: Lvl " + str(global.dash_cost_level)
	stats[4].text = "Jump Cost: Lvl " + str(global.jump_cost_level)
	stats[5].text = "Dash Cooldown: Lvl " + str(global.dash_cd_level)
	stats[6].text = "Apple Recovery: Lvl " + str(global.apple_level)

	var vbox = $MainPanel/VBoxContainer
	_remove_dynamic_labels(vbox)

	var sep_idx = vbox.get_children().find($MainPanel/VBoxContainer/HSeparator2)

	var best_label = Label.new()
	best_label.name = "_DynBest"
	best_label.text = "Best: " + str(global.best_distance) + " m  |  Runs: " + str(global.total_runs)
	best_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	best_label.add_theme_font_size_override("font_size", 14)
	best_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	vbox.add_child(best_label)
	vbox.move_child(best_label, sep_idx)

	if global.high_scores.size() > 0:
		var hs_label = Label.new()
		hs_label.name = "_DynHS"
		var lines = "Top runs: "
		for i in range(global.high_scores.size()):
			if i > 0:
				lines += ", "
			lines += str(global.high_scores[i]) + "m"
		hs_label.text = lines
		hs_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hs_label.add_theme_font_size_override("font_size", 12)
		hs_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		vbox.add_child(hs_label)
		vbox.move_child(hs_label, sep_idx + 1)

func _remove_dynamic_labels(vbox: VBoxContainer):
	for child in vbox.get_children():
		if child.name.begins_with("_Dyn"):
			child.queue_free()

# ---------- Navigation ----------

func _show_panel(panel: Control):
	main_panel.visible = false
	options_panel.visible = false
	if achievements_panel:
		achievements_panel.visible = false
	if skins_panel:
		skins_panel.visible = false
	panel.visible = true
	_animate_panel_in(panel)

func _on_BtnPlay_pressed():
	audio_manager.play_sfx("button_click")
	get_tree().change_scene_to_file("res://main.tscn")

func _on_BtnAchievements_pressed():
	audio_manager.play_sfx("button_click")
	_refresh_achievements_panel()
	_show_panel(achievements_panel)

func _on_BtnSkins_pressed():
	audio_manager.play_sfx("button_click")
	_refresh_skins_panel()
	_show_panel(skins_panel)

func _on_BtnOptions_pressed():
	audio_manager.play_sfx("button_click")
	_show_panel(options_panel)

func _on_BtnBack_pressed():
	audio_manager.play_sfx("button_click")
	_show_panel(main_panel)

func _on_SoundToggle_toggled(toggled_on: bool):
	global.sound_muted = not toggled_on
	AudioServer.set_bus_mute(0, global.sound_muted)
	global.save_data()

# ---------- Achievements Panel ----------

func _build_achievements_panel():
	achievements_panel = _create_styled_panel(Vector2(-220, -300), Vector2(220, 300))
	achievements_panel.visible = false
	add_child(achievements_panel)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_top = 20
	vbox.offset_right = -20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 8)
	achievements_panel.add_child(vbox)

	var title = Label.new()
	title.text = "ACHIEVEMENTS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(title)

	var sep = HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	vbox.add_child(sep)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.name = "AchScroll"
	vbox.add_child(scroll)

	var list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 6)
	list.name = "AchList"
	scroll.add_child(list)

	var back_btn = Button.new()
	back_btn.text = "BACK"
	back_btn.add_theme_font_size_override("font_size", 16)
	back_btn.pressed.connect(_on_BtnBack_pressed)
	vbox.add_child(back_btn)

func _refresh_achievements_panel():
	var list = achievements_panel.get_node("VBox/AchScroll/AchList")
	for child in list.get_children():
		child.queue_free()

	# Wait a frame so freed nodes are gone before adding new ones
	await get_tree().process_frame

	var defs = achievements.get_all()
	var unlocked = global.unlocked_achievements

	for def in defs:
		var is_unlocked = def["id"] in unlocked
		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)

		var icon = Label.new()
		icon.text = "[*]" if is_unlocked else "[ ]"
		icon.add_theme_font_size_override("font_size", 14)
		icon.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4) if is_unlocked else Color(0.5, 0.5, 0.5))
		icon.custom_minimum_size.x = 30
		hbox.add_child(icon)

		var info = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 2)

		var title_lbl = Label.new()
		title_lbl.text = def["title"]
		title_lbl.add_theme_font_size_override("font_size", 14)
		title_lbl.add_theme_color_override("font_color", Color(1, 1, 1) if is_unlocked else Color(0.6, 0.6, 0.6))
		info.add_child(title_lbl)

		var desc_lbl = Label.new()
		desc_lbl.text = def["desc"]
		desc_lbl.add_theme_font_size_override("font_size", 11)
		desc_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7) if is_unlocked else Color(0.4, 0.4, 0.4))
		info.add_child(desc_lbl)

		hbox.add_child(info)
		list.add_child(hbox)

# ---------- Skins Panel ----------

func _build_skins_panel():
	skins_panel = _create_styled_panel(Vector2(-200, -250), Vector2(200, 250))
	skins_panel.visible = false
	add_child(skins_panel)

	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_top = 20
	vbox.offset_right = -20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 10)
	skins_panel.add_child(vbox)

	var title = Label.new()
	title.text = "SKINS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	vbox.add_child(title)

	var sep = HSeparator.new()
	sep.add_theme_constant_override("separation", 8)
	vbox.add_child(sep)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.name = "SkinScroll"
	vbox.add_child(scroll)

	var list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	list.name = "SkinList"
	scroll.add_child(list)

	var back_btn = Button.new()
	back_btn.text = "BACK"
	back_btn.add_theme_font_size_override("font_size", 16)
	back_btn.pressed.connect(_on_BtnBack_pressed)
	vbox.add_child(back_btn)

func _refresh_skins_panel():
	var list = skins_panel.get_node("VBox/SkinScroll/SkinList")
	for child in list.get_children():
		child.queue_free()

	await get_tree().process_frame

	# Import SKINS dict from player.gd at class level
	const PlayerSkins = preload("res://player.gd")

	for skin_key in PlayerSkins.SKINS.keys():
		var is_selected = global.current_skin == skin_key
		var skin_name = skin_key.capitalize()

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)

		# Preview icon: load the run texture and show a small preview
		var preview = TextureRect.new()
		preview.custom_minimum_size = Vector2(50, 50)
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var run_tex = load(PlayerSkins.SKINS[skin_key]["run"])
		if run_tex:
			preview.texture = run_tex
		hbox.add_child(preview)

		var info = VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label = Label.new()
		name_label.text = skin_name
		name_label.add_theme_font_size_override("font_size", 16)
		name_label.add_theme_color_override("font_color", Color(1, 1, 1))
		info.add_child(name_label)

		if is_selected:
			var equipped = Label.new()
			equipped.text = "Equipped"
			equipped.add_theme_font_size_override("font_size", 12)
			equipped.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
			info.add_child(equipped)
		else:
			var select_btn = Button.new()
			select_btn.text = "Select"
			select_btn.add_theme_font_size_override("font_size", 12)
			select_btn.pressed.connect(_on_skin_selected.bind(skin_key))
			info.add_child(select_btn)

		hbox.add_child(info)
		list.add_child(hbox)

func _on_skin_selected(skin_key: String):
	global.current_skin = skin_key
	global.save_data()
	audio_manager.play_sfx("button_click")
	_refresh_skins_panel()

# ---------- Shared helpers ----------

func _create_styled_panel(offset_min: Vector2, offset_max: Vector2) -> Panel:
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = offset_min.x
	panel.offset_top = offset_min.y
	panel.offset_right = offset_max.x
	panel.offset_bottom = offset_max.y
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.122, 0.122, 0.161, 0.941)
	style.border_color = Color(0.361, 0.820, 0.380, 1.0)
	style.set_border_width_all(4)
	style.set_corner_radius_all(16)
	style.shadow_color = Color(0, 0, 0, 0.5)
	style.shadow_size = 15
	panel.add_theme_stylebox_override("panel", style)

	return panel

func _animate_panel_in(panel: Control):
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.92, 0.92)
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
