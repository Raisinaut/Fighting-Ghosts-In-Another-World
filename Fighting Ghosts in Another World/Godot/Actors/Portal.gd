extends ReferenceRect

onready var collision = $Area2D/CollisionShape2D

export var to_level : String = ""

func _ready():
	match_collision_to_reference()


func match_collision_to_reference():
	var center = rect_position + (rect_size / 2)
	collision.shape = RectangleShape2D.new()
	collision.shape.extents = rect_size / 2
	collision.global_position = center


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		SceneChanger.goto_scene(to_level, false, Color.black)

