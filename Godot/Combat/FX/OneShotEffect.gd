extends AnimatedSprite

onready var soundEffect = $SoundEffect

var _discard = null
var stream_to_set : AudioStream= null

func _init():
	visible = false

func _ready():
	_discard = connect("animation_finished", self, "stop")
	set_sfx(stream_to_set)
	start()

func start():
	show()
	soundEffect.play_at_random_pitch()
	play("default")
	var t = create_tween()
	var t_duration = frames.get_frame_count("default") / frames.get_animation_speed("default")
#	t.set_trans(Tween.TRANS_CUBIC)
#	t.set_ease(Tween.EASE_OUT)
	_discard = t.tween_property($Light2D, "texture_scale", $Light2D.texture_scale + 0.1, t_duration)
	_discard = t.parallel().tween_property($Light2D, "position:x", -8, t_duration)
	_discard = t.parallel().tween_property($Light2D, "color", Color.transparent, t_duration)

func stop():
	hide()
	if soundEffect.playing:
		yield(soundEffect, "finished")
	queue_free()

func set_sfx(s : AudioStream):
	soundEffect.stream = s
