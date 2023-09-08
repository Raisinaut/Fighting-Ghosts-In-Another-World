extends Stats

signal mp_changed

export var max_mp : int = 3

onready var mp : int = max_mp setget set_mp # set onready to keep export value


func set_mp(value):
	value = clamp(value, 0, max_mp)
	print("MP: ", value)
	if mp == value:
		return
	mp = value
	emit_signal("mp_changed", mp)

func restore_mp(value):
	set_mp(mp + value)
