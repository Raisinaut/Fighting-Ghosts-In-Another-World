extends Camera2D

export(float, 0.5, 5.0, 0.05) var zoom_speed = 2.0

onready var screenShake = $ScreenShake
onready var player_node = get_tree().get_nodes_in_group("Player")[0]
onready var areaDetection = $AreaDetection

var current_area = null
var zoom_tween : SceneTreeTween = null
var target_offset := Vector2(0, -8)

var _discard = null



func _ready():
	player_node.connect("damaged", self, "small_shake")


func small_shake() -> void:
	screenShake.start(0.15, 20, 4, 0)


func _physics_process(_delta):
	if player_node.is_charging():
		tween_zoom(Vector2.ONE * 0.9, 0.5)
	else:
		tween_zoom(Vector2.ONE, 1)
	global_position = player_node.global_position + target_offset


func tween_zoom(zoom_vec : Vector2, duration : float = 1):
	zoom_tween = create_tween()
	_discard = zoom_tween.set_ease(Tween.EASE_IN)
	_discard = zoom_tween.tween_property(self, "zoom", zoom_vec, duration)


func _on_AreaDetection_area_entered(area):
	current_area = area
	var limit_rect = area.owner
	limit_left = limit_rect.get_limit_left()
	limit_top = limit_rect.get_limit_top()
	limit_right = limit_rect.get_limit_right()
	limit_bottom = limit_rect.get_limit_bottom()
#	var t = create_tween()
#	t.set_trans(Tween.TRANS_QUAD)
#	t.set_ease(Tween.EASE_OUT)
#	t.tween_method(self, "set_limit_left", float(limit_left), limit_rect.get_limit_left(), 0.4)
#	t.tween_method(self, "set_limit_top", float(limit_top), limit_rect.get_limit_top(), 0.4)
#	t.tween_method(self, "set_limit_right", float(limit_right), limit_rect.get_limit_right(), 0.4)
#	t.tween_method(self, "set_limit_bottom", float(limit_bottom), limit_rect.get_limit_bottom(), 0.4)

#func set_limit_left(val):
#	limit_left = val
#func set_limit_top(val):
#	limit_top = val
#func set_limit_right(val):
#	limit_right = val
#func set_limit_bottom(val):
#	limit_bottom = val


