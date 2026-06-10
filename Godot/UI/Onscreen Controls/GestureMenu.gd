extends Node2D

onready var buttons = $Buttons.get_children()
onready var center = $Buttons/Center
onready var up = $Buttons/Up
onready var left = $Buttons/Left
onready var down = $Buttons/Down

var menu_active : bool setget set_menu_active



func _ready():
	set_menu_active(false)

# Enable buttons while active
func set_menu_active(state):
	menu_active = state
	if menu_active:
		for b in buttons:
			b.show()
	else:
		for b in buttons:
			b.hide()

# Throw
func _input(event):
	if not menu_active:
		return
	if event is InputEventScreenTouch:
		if not event.is_pressed():
			var release_distance = event.position.distance_to(center.global_position + get_center_offset(center))
			if release_distance < get_center_offset(center).length():
				parse_action("throw", true)
				parse_action("throw", false)
				print("throw")

func parse_action(action_name : String, p : bool):
	var e := InputEventAction.new()
	e.set_action(action_name)
	e.pressed = p
	Input.parse_input_event(e)


# Jump full height
func _on_up_pressed():
	set_menu_active(false)
	print("jump full height")
func _on_up_released():
	pass


# Charge
func _on_left_pressed():
	left.passby_press = false
	left.modulate = Color.transparent
	for b in buttons:
		if b != left:
			b.hide()
	print("charge start")
func _on_left_released():
	left.modulate = Color.white
	left.passby_press = true
	set_menu_active(false)
	print("charge end")


# Cancel Throw
func _on_down_pressed():
	set_menu_active(false)
	print("cancel throw")


func get_center_offset(button : TouchScreenButton) -> Vector2:
	var offset := Vector2.ZERO
	if button.shape is CircleShape2D:
		offset = Vector2.ONE * button.shape.radius / button.scale.x
	elif button.shape is RectangleShape2D:
		offset = button.shape.extents / button.scale.x
	return offset

