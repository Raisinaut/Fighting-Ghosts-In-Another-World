extends Node

signal enemy_list_modified
signal enemy_list_cleared

var player_node : Node2D = null setget set_player_node
var target_override : Node2D = null setget set_target_override

var enemy_list : Array = [] setget set_enemy_list



func _ready():
	set_enemy_list(get_tree().get_nodes_in_group("enemy"))
	for e in enemy_list:
		e.connect("defeated", self, "remove_enemy", [e])

func set_enemy_list(arr):
	enemy_list = arr
	emit_signal("enemy_list_modified", enemy_list.size())
	if enemy_list.size() == 0:
		emit_signal("enemy_list_cleared")
	print("Remaining enemies: ", enemy_list.size())

func remove_enemy(e):
	if enemy_list.has(e):
		enemy_list.erase(e)
		set_enemy_list(enemy_list)


func set_player_node(node):
	player_node = node
func set_target_override(node):
	target_override = node

