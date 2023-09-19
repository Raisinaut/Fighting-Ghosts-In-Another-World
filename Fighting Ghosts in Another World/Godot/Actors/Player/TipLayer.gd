extends CanvasLayer

onready var label = get_node("%TipLabel")

# tagged tips
onready var throw_tip = Dialogic.get_variable("throw_input") + " to Aim/Throw"


func _ready():
	visible = false

func set_text(tag : String):
	var new_text = get(tag)
	new_text[0] = new_text[0].to_upper()
	label.text = new_text
