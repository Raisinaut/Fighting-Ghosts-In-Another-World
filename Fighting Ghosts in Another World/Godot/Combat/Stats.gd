class_name Stats
extends Node

signal hp_depleted

export var init_hp : int = 3

var hp : int = init_hp setget set_hp


func set_hp(value):
	hp = value
	if hp <= 0:
		emit_signal("hp_depleted")

