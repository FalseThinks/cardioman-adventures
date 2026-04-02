extends TextureProgressBar

var flash_color: Color = Color.RED
var flash_timer := 0.0
var flash_duration := 0.3

func update_stamina_bar(current_stamina, max_stamina):
	value = current_stamina
	max_value = max_stamina
	var percent_label = get_node_or_null("../StaminaPercentLabel")
	if percent_label:
		percent_label.text = str(round((current_stamina / max_stamina) * 100)) + "%"

	if flash_timer <= 0:
		var percent = clamp(current_stamina / max_stamina, 0.0, 1.0)
		tint_progress = get_stamina_color(percent)

func get_stamina_color(percent: float) -> Color:
	if percent >= 0.5:
		var t = (percent - 0.5) * 2.0
		return Color(1.0, lerp(0.5, 1.0, t), 0.0)  # Orange to Yellow
	else:
		var t = percent * 2.0
		return Color(
			lerp(1.0, 0.4, 1.0 - t),
			lerp(1.0, 0.4, 1.0 - t),
			lerp(0.0, 0.4, 1.0 - t)
		)  # Yellow to Gray

func flash_stamina(color: Color):
	flash_color = color
	flash_timer = flash_duration
	tint_progress = flash_color

func _process(delta):
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			update_stamina_bar(value, max_value)
