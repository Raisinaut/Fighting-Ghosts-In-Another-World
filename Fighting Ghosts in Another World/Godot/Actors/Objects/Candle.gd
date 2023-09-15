extends AnimatedSprite


var rng = RandomNumberGenerator.new()
var foreground = false setget set_foreground
var lit := true

func _ready():
	$Light2D.visible = lit
	rng.randomize()
	var anim_frame_count = frames.get_frame_count("default")
	frame = rng.randi_range(0, anim_frame_count - 1)
	flip_h = bool(rng.randi_range(0, 1))
	$Light2D.texture.fps = rng.randi() % 3 + 2
	playing = true
	
	
# brings it forward on top of characters
func set_foreground(state):
	foreground = state
	if foreground:
		z_index = 1000
	else:
		z_index = 0
