extends ReferenceRect

onready var collision = $Area2D/CollisionShape2D

export(float, 0.1, 2.0, 0.05) var zoom_scale = 1.0


func _ready():
	match_reference_rect()

func match_reference_rect():
	collision.shape.extents = get_rect().size / 2
	collision.position = collision.shape.extents

func get_limit_rect() -> Rect2:
	var limit_rect = Rect2()
	var shape_extents = collision.shape.extents
	limit_rect.position = collision.global_position - shape_extents
	limit_rect.end = collision.global_position + shape_extents
	return limit_rect

func get_limit_left():
	return get_limit_rect().position.x
func get_limit_top():
	return get_limit_rect().position.y
func get_limit_right():
	return get_limit_rect().end.x
func get_limit_bottom():
	return get_limit_rect().end.y


func get_zoom_scale():
	return Vector2(1, 1) * zoom_scale
