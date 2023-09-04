# Detected by HurtBox
class_name HitBox
extends Area2D

signal detected

export var damage := 1
export var knockback := 10

var disabled = false setget set_disabled


func set_disabled(state):
	disabled = state
	set_deferred("monitorable", not disabled)
