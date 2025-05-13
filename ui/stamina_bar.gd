extends ProgressBar

var flash_color: Color = Color.RED
var flash_timer := 0.0
var flash_duration := 0.3

# For normal color gradient
var last_value: float = 0.0

# Called when the node enters the scene tree
func _ready():
	# Ensure we have a StyleBoxFlat for the bar
	if not get("custom_styles/fill"):
		var style = StyleBoxFlat.new()
		style.bg_color = Color(1, 1, 1)  # Default to white, we will change this later
		add_theme_stylebox_override("fill", style)

# Update the stamina bar, where current_value is the current stamina and max_val is the max stamina
func update_stamina_bar(current_value: float, max_val: float):
	value = current_value  # Update the value of the bar
	max_value = max_val    # Update the max value of the bar

	var percent = clamp(current_value / max_val, 0.0, 1.0)

	# Get the fill style box
	var bar_style = get("custom_styles/fill") as StyleBoxFlat
	if bar_style == null:
		# If the fill doesn't exist, create a new StyleBoxFlat
		bar_style = StyleBoxFlat.new()
		set("custom_styles/fill", bar_style)

	# If flashing, set the flash color
	if flash_timer > 0:
		bar_style.bg_color = flash_color
	else:
		# Otherwise, set the normal color based on the stamina
		bar_style.bg_color = get_stamina_color(percent)

# Returns a color based on the percentage of stamina
func get_stamina_color(percent: float) -> Color:
	if percent >= 0.5:
		# Interpolate from orange to yellow as stamina decreases
		var t = (percent - 0.5) * 2.0
		return Color(1.0, lerp(0.5, 1.0, t), 0.0)  # Orange to Yellow
	else:
		# Interpolate from yellow to gray when stamina is low
		var t = percent * 2.0
		return Color(
			lerp(1.0, 0.4, 1.0 - t),
			lerp(1.0, 0.4, 1.0 - t),
			lerp(0.0, 0.4, 1.0 - t)
		)  # Yellow to Gray

# Function to trigger a flash effect on the stamina bar
func flash_stamina(color: Color):
	flash_color = color
	flash_timer = flash_duration
	update_stamina_bar(value, max_value)  # Update immediately

# Called every frame to update the flash timer
func _process(delta):
	if flash_timer > 0:
		flash_timer -= delta
		if flash_timer <= 0:
			# Revert to normal color when flash ends
			update_stamina_bar(value, max_value)  # Revert to normal gradient color
