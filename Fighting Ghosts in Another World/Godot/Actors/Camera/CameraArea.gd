extends ReferenceRect

onready var collision = $Area2D/CollisionShape2D

export(float, 0.1, 2.0, 0.05) var zoom_scale = 1.0


func _ready():
	match_reference_rect()

func match_reference_rect():
	collision.shape.extents = get_rect().size / 2
	collision.position = collision.shape.extents


func get_limit_left():
	return rect_global_position.x
func get_limit_top():
	return rect_global_position.y
func get_limit_right():
	return rect_size.x
func get_limit_bottom():
	return rect_size.y


func get_zoom_scale():
	return Vector2(1, 1) * zoom_scale
