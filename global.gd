extends Node

signal coins_updated(new_amount)

var coins: int = 0

# Getter/Setter method for coins
func set_coins(value: int) -> void:
	coins = value
	emit_signal("coins_updated", coins)

# Method to add coins
func add_coin(amount: int = 1) -> void:
	set_coins(coins + amount)
