extends ReferenceRect

export var timeline_name : String = ""

onready var collision = $Area2D/CollisionShape2D


func _ready():
	match_collision_to_reference()

func match_collision_to_reference():
	var center = rect_position + (rect_size / 2)
	collision.shape = RectangleShape2D.new()
	collision.shape.extents = rect_size / 2
	collision.global_position = center

func _on_Area2D_body_entered(_body):
	if timeline_name != "":
		Global.start_dialog(timeline_name)
