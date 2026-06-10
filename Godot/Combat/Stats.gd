class_name Stats
extends Node

signal hp_depleted
signal hp_changed

export var max_hp : int = 3

onready var hp : int = max_hp setget set_hp # set onready to keep export value


func set_hp(value):
	value = clamp(value, 0, max_hp)
	if hp == value:
		return
	hp = value
	emit_signal("hp_changed", hp)
	if hp <= 0:
		emit_signal("hp_depleted")

