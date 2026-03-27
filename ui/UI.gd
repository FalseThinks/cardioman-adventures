extends Control

@onready var coin_label = $HBox/CoinLabel
@onready var meter_label = $HBox/MeterLabel

var player: Node2D

func _ready():
	global.connect("coins_updated", Callable(self, "_on_coins_updated"))
	_on_coins_updated(global.coins)  # Set initial value

func _on_coins_updated(new_amount):
	coin_label.text = "Coins x %d" % new_amount

func _process(delta):
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if player:
		var distance = max(0, player.global_position.x - 571)
		var meters = int(distance / 100.0)
		meter_label.text = str(meters) + " m"
