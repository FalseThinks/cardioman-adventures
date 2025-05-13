extends Control

@onready var coin_label = $CoinLabel  # Adjust path if needed

func _ready():
	global.connect("coins_updated", Callable(self, "_on_coins_updated"))
	_on_coins_updated(global.coins)  # Set initial value

func _on_coins_updated(new_amount):
	coin_label.text = "Coins x %d" % new_amount
