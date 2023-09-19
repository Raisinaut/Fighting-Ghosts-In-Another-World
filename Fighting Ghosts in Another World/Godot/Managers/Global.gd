extends Node


signal finished_throw_tutorial
signal changed_dialog_is_active(dialog_is_active)
signal device_changed(device)


const DEVICE_KEYBOARD = "keyboard"
const DEVICE_TOUCHSCREEN = "touchscreen"
const DEVICE_XBOX_CONTROLLER = "xbox"
const DEVICE_SWITCH_CONTROLLER = "switch"
const DEVICE_SWITCH_JOYCON_LEFT_CONTROLLER = "switch_left_joycon"
const DEVICE_SWITCH_JOYCON_RIGHT_CONTROLLER = "switch_right_joycon"
const DEVICE_PLAYSTATION_CONTROLLER = "playstation"
const DEVICE_GENERIC = "generic"

# Dialog variables
var dialog_is_active = false setget set_dialog_is_active
var throw_tutorial_active = false
var throw_tutorial_finished = false setget set_throw_tutorial_finished
var current_dialog = null
var current_timeline : String = ""

# Input device variables
var device : String = ""
var device_last_changed_at = 0



func set_dialog_is_active(state):
	dialog_is_active = state
	emit_signal("changed_dialog_is_active", dialog_is_active)

func _ready():
	if OS.has_feature("mobile"):
		update_dialogic_variables(DEVICE_TOUCHSCREEN)
	else:
		update_dialogic_variables(DEVICE_KEYBOARD)
#	self.connect("device_changed", self, "update_dialogic_variables")

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		end_dialog()

# Tell Dialogic to start a timeline
# Ends the previous dialog first, if one exists
func start_dialog(timeline_name):
	if current_dialog:
		end_dialog()
		
	current_timeline = timeline_name
	current_dialog = Dialogic.start(current_timeline)
	current_dialog.connect("timeline_start", self, "_on_timeline_start")
	current_dialog.connect("timeline_end", self, "_on_timeline_end")
	get_tree().get_root().call_deferred("add_child", current_dialog)
	return current_dialog

# Effectively skips dialog by freeing the current node 
#  and signals that that timeline finished
func end_dialog():
	if current_dialog == null:
		return
	current_dialog.emit_signal("timeline_end", current_timeline)

func _on_timeline_start(_timeline_name):
	set_dialog_is_active(true)

func _on_timeline_end(_timeline_name):
	if current_dialog:
		current_dialog.queue_free()
	set_dialog_is_active(false)
	current_dialog = null

func set_throw_tutorial_finished(state : bool):
	if throw_tutorial_finished == state:
		return
	throw_tutorial_finished = state
	emit_signal("finished_throw_tutorial", throw_tutorial_finished)



func update_dialogic_variables(device_name : String):
	match(device_name):
		DEVICE_KEYBOARD:
			Dialogic.set_variable("throw_input", "tap " + InputMap.get_action_list("throw")[0].as_text())
			Dialogic.set_variable("charge_input", "hold " + InputMap.get_action_list("charge")[0].as_text())
			Dialogic.set_variable("jump_input", "press " + InputMap.get_action_list("jump")[0].as_text())
			Dialogic.set_variable("cancel_input", "press " + InputMap.get_action_list("cancel_throw")[0].as_text().to_lower())
		DEVICE_TOUCHSCREEN:
			Dialogic.set_variable("throw_input", "tap the right side of the screen")
			Dialogic.set_variable("charge_input", "swipe left and hold")
			Dialogic.set_variable("jump_input", "swipe up")
			Dialogic.set_variable("cancel_input", "swipe down")


func _input(event: InputEvent) -> void:
	var next_device : String = device

	# Did we just press a key on the keyboard?
	if event is InputEventKey:
		next_device = DEVICE_KEYBOARD
	
	# Did we just touch the screen?
	if event is InputEventScreenTouch:
		next_device = DEVICE_TOUCHSCREEN

	# Did we just use a joypad?
	elif event is InputEventJoypadButton \
		or (event is InputEventJoypadMotion and abs(event.axis_value) > 0.5):
		next_device = get_simplified_device_name(Input.get_joy_name(event.device))

	# Debounce changes because some joypads register twice in Windows for some reason
	var not_changed_just_then = Engine.get_frames_drawn() - device_last_changed_at > Engine.get_frames_per_second()
	if not_changed_just_then:
		device_last_changed_at = Engine.get_frames_drawn()

		device = next_device
		emit_signal("device_changed", device)


# Convert a Godot device identifier to a simplified string
func get_simplified_device_name(raw_name: String) -> String:
	match raw_name:
		"XInput Gamepad", "Xbox Series Controller", "Xbox 360 Controller", \
		"Xbox One Controller":
			return DEVICE_XBOX_CONTROLLER

		"Sony DualSense", "PS5 Controller", "PS4 Controller", \
		"Nacon Revolution Unlimited Pro Controller":
			return DEVICE_PLAYSTATION_CONTROLLER

		"Switch":
			return DEVICE_SWITCH_CONTROLLER
		"Joy-Con (L)":
			return DEVICE_SWITCH_JOYCON_LEFT_CONTROLLER
		"Joy-Con (R)":
			return DEVICE_SWITCH_JOYCON_RIGHT_CONTROLLER

		_:
			return DEVICE_GENERIC

