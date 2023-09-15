extends CanvasLayer

onready var label = get_node("%TipLabel")

var throw_tip = "Press " + InputMap.get_action_list("throw")[0].as_text() + " to Aim/Throw"


func _ready():
	visible = false

func set_text(tag : String):
	var new_text = get(tag)
	label.text = new_text
