extends AnimatedSprite

export var alternate_texture : Texture = null
onready var original_texture : Texture = frames.animations[0].frames[0].atlas
onready var flashTimer := $FlashTimer
onready var toggleTimer := $ToggleTimer

var alternate_texture_enabled := false setget set_alternate_texture_enabled
var _discard


func _ready():
	material.set_shader_param("flash", false)
	_discard = toggleTimer.connect("timeout", self, "toggle_flash")


func _on_AnimatedSprite_animation_finished():
	if animation == "land":
		stop()
	if not flashTimer.is_stopped():
		pass

# change to an identical texture that has a swapped palette
func set_alternate_texture_enabled(state : bool):
	# return if unchanged
	if state == alternate_texture_enabled:
		return
	# Select texture
	var new_texture = null
	if state == true:
		new_texture = alternate_texture
	else:
		new_texture = original_texture
	# update 
	for a in frames.animations:
		for f in a.frames:
			f.atlas = new_texture
	# set new state
	alternate_texture_enabled = state


func flash(duration):
	flashTimer.start(duration)
	toggle_flash()

func toggle_flash():
	if flashTimer.is_stopped():
		material.set_shader_param("flash", false)
		return
	var current_state = material.get_shader_param("flash")
	material.set_shader_param("flash", not current_state)
	toggleTimer.start()

