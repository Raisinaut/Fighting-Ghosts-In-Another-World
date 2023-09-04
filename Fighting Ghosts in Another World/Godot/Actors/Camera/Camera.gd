extends Camera2D

export(float, 0.5, 5.0, 0.05)var zoom_speed = 2

onready var screenShake = $ScreenShake

var current_area = null


func small_shake() -> void:
	screenShake.start(0.15, 20, 4, 0)

func _physics_process(delta):
	var player_node = get_tree().get_nodes_in_group("Player")[0]
	global_position = player_node.global_position

func _on_AreaDetection_area_entered(area):
	current_area = area
	var limit_rect = area.owner
	limit_left = limit_rect.get_limit_left()
	limit_top = limit_rect.get_limit_top()
	limit_right = limit_rect.get_limit_right()
	limit_bottom = limit_rect.get_limit_bottom()
