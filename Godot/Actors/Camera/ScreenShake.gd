extends Node

const TRANS = Tween.TRANS_SINE
const EASE = Tween.EASE_IN_OUT

onready var camera = get_parent()

var amplitude = 0
var priority = 0
var alternate_shake_direction = false
var rng = RandomNumberGenerator.new()


func _ready():
	rng.randomize()


func start(duration = 0.2, frequency = 15, new_amplitude = 16, new_priority = 0):
	if (new_priority >= self.priority):
		self.priority = new_priority
		self.amplitude = new_amplitude
		
		$Duration.start(duration)
		$Frequency.start(1 / float(frequency))
		
		_new_shake()


func _new_shake():
	var shake_vec = Vector2()
	var tween = create_tween()
	var dampen = range_lerp($Duration.time_left, 0, $Duration.wait_time, 0, 1)
	
	shake_vec.x = amplitude
	shake_vec.y = rng.randf_range(-amplitude, amplitude)
	shake_vec *= dampen
	# swap directions for every shake
	if alternate_shake_direction:
		shake_vec.x *= -1
	
	tween.set_trans(TRANS)
	tween.set_ease(EASE)
	tween.tween_property(camera, "offset", shake_vec, $Frequency.wait_time)
	
	alternate_shake_direction = true


# restore offset
func _reset():
	var tween = create_tween()
	tween.tween_property(camera, "offset", Vector2.ZERO, $Frequency.wait_time)
	
	priority = 0

# continue shaking
func _on_Frequency_timeout():
	_new_shake()
# end shaking
func _on_Duration_timeout():
	_reset()
	$Frequency.stop()
