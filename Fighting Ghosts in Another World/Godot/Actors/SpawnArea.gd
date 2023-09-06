extends ReferenceRect

export var MAX_ENEMIES = 3
export (PackedScene) var enemy_to_spawn = null

var rng = RandomNumberGenerator.new()
var spawnTimer : SceneTreeTimer = null

var spawn_time = 2
var spawn_time_variance := 1.0

var _discard = null

func _ready():
	rng.randomize()
	start_timer_varied()


# Creates an enemy instance if under limit
func _on_SpawnTimer_timeout():
	if enemy_to_spawn == null:
		print("No enemy assigned to " + self.name)
		return
	
	var spawned_enemy_count = get_tree().get_nodes_in_group(self.name).size()
	var offset = Vector2.ZERO
	offset.x = rng.randf_range(0, rect_size.y)
	offset.y = rng.randf_range(0, rect_size.y)
	if spawned_enemy_count < MAX_ENEMIES:
		# Instance enemy
		var enemy_inst : Node2D = enemy_to_spawn.instance()
		call_deferred("add_child", enemy_inst)
		enemy_inst.global_position = offset
		enemy_inst.aggressive = true
		enemy_inst.add_to_group(self.name)
	start_timer_varied()


func start_timer_varied():
	var varied_time = spawn_time + rng.randf_range(-spawn_time_variance, spawn_time_variance)
	spawnTimer = get_tree().create_timer(varied_time)
	_discard = spawnTimer.connect("timeout", self, "_on_SpawnTimer_timeout")
