extends Node

var current_checkpoint : Node2D = null setget set_current_checkpoint
var spawn_location := Vector2.ZERO


func _ready():
	SceneChanger.connect("changing_scene", self, "clear_checkpoint")

func set_current_checkpoint(c):
	if current_checkpoint:
#		current_checkpoint.set_active(false)
		pass
	current_checkpoint = c

func remove_checkpoint():
#	current_checkpoint.set_active(false)
	current_checkpoint = null

func get_checkpoint_position() -> Vector2:
	if current_checkpoint:
		return current_checkpoint.global_position
	else:
		return spawn_location

func clear_checkpoint():
	current_checkpoint = null
