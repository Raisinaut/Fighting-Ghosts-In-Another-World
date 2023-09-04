extends Node2D


func _ready():
	for candle in $CandleHolder/Candles.get_children():
		candle.set_foreground(false)
