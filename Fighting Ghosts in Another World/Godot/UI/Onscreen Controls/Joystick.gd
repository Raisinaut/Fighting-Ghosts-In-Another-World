extends TextureRect

onready var ring = self
onready var pivot = $StickPivot
onready var stick = $StickPivot/Stick

# Measurements
onready var ring_center : Vector2 = ring.rect_global_position + ring.rect_size * 0.5
onready var ring_radius : float = ring.rect_size.x * 0.5
onready var stick_radius : float = stick.texture.get_size().x * stick.scale.x * 0.5
onready var max_stick_distance : float = ring_radius - stick_radius

var enabled : bool = false setget set_enabled
var stiffness = 0.5 # perceived resistance to moving the stick



func set_enabled(state):
	if state == false:
		reset_stick()
	visible = state
	enabled = state



func _process(_delta):
	if enabled:
		feed_joystick_input()


func _input(event):
	if not enabled:
		return
	
	elif event is InputEventScreenTouch:
		if not event.is_pressed():
			reset_stick()

func set_stick_position(drag_pos : Vector2):
	stick.position = (pivot.to_local(drag_pos) * (1.0 - stiffness)).limit_length(max_stick_distance)

func reset_stick():
	stick.position = Vector2.ZERO


# Emulate a joystick by providing inputs to Godot
func feed_joystick_input():
	var tilt_vec = get_tilt_vector()
	var j_x = InputEventJoypadMotion.new()
	var j_y = InputEventJoypadMotion.new()
	j_x.set_axis(JOY_AXIS_0)
	j_y.set_axis(JOY_AXIS_1)
	j_x.set_axis_value(tilt_vec.x)
	j_y.set_axis_value(tilt_vec.y)
	Input.parse_input_event(j_x)
	Input.parse_input_event(j_y)


# Returns a percentage of to stick tilt
# length ranges 0-1, depending on distance from ring center
func get_tilt_vector():
	var stick_distance = stick.position.distance_to(Vector2.ZERO)
	var tilt_percent = range_lerp(stick_distance, 0, max_stick_distance, 0, 1)
	var tilt_vector = Vector2.ZERO.direction_to(stick.position) * tilt_percent
	return tilt_vector
