extends Node
# internal
signal enemy_list_modified
signal spawner_enemy_count_modified
# external
signal total_enemy_count_changed
signal all_enemies_defeated

onready var spawners = []
onready var enemies = []

var player_node : Node2D = null
var target_override : Node2D = null setget set_target_override
 
var enemy_list : Array = [] setget set_enemy_list
var spawner_enemy_count : int = 0


func _ready():
	SceneChanger.connect("scene_changed", self, "refresh_lists")
	self.connect("enemy_list_modified", self, "sum_total_count")
	self.connect("spawner_enemy_count_modified", self, "sum_total_count")

func refresh_lists():
	enemies = get_tree().get_nodes_in_group("enemy")
	set_enemy_list(enemies)
	for e in enemy_list:
		e.connect("defeated", self, "erase_enemy", [e])
	
	spawners = get_tree().get_nodes_in_group("spawner")
	for s in spawners:
		s.connect("incremented_num_defeated", self, "sum_spawner_enemy_count")
	sum_spawner_enemy_count()

func set_enemy_list(arr):
	enemy_list = arr
	emit_signal("enemy_list_modified")

func sum_spawner_enemy_count():
	var sum = 0
	for s in spawners:
		sum += s.get_remaining()
	spawner_enemy_count = sum
	emit_signal("spawner_enemy_count_modified")

func sum_total_count():
	var total = enemy_list.size() + spawner_enemy_count
	emit_signal("total_enemy_count_changed", total)
	if total == 0:
		emit_signal("all_enemies_defeated")

func erase_enemy(e):
	if enemy_list.has(e):
		enemy_list.erase(e)
		set_enemy_list(enemy_list)

func set_target_override(node):
	target_override = node
