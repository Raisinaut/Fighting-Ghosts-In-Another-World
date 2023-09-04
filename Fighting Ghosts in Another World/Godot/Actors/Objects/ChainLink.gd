extends RigidBody2D

onready var sprite = $Sprite
onready var joint = $PinJoint2D


func set_attached_nodes(a : String = "", b : String = ""):
	joint.node_a = a
	joint.node_b = b

func set_turned(alternate : bool):
	if alternate:
		sprite.frame = 0
	else:
		sprite.frame = 1
