extends Node


var player_node : Node2D = null setget set_player_node
var target_override : Node2D = null setget set_target_override


func set_player_node(node):
	player_node = node
func set_target_override(node):
	target_override = node

