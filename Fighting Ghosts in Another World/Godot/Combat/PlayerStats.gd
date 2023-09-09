extends Stats

signal mp_changed
signal mp_full

export var max_mp : int = 3

onready var mp : int = max_mp setget set_mp # set onready to keep export value
onready var restoreMP := $RestoreMP
onready var restoreParticles := $RestoreParticles

var _discard = null


func _process(delta):
	restoreParticles.global_position = get_parent().global_position

func _ready():
	_discard = connect("hp_changed", self, "_on_hp_changed")
	_discard = connect("mp_changed", self, "_on_mp_changed")
	$HUD.hp.set_max(max_hp)
	$HUD.mp.set_max(max_mp)

func set_mp(value):
	value = clamp(value, 0, max_mp)
	print("MP: ", value)
	if value == mp:
		return
	elif value > mp:
		restoreMP.play()
		restoreParticles.emitting = true
	mp = value
	emit_signal("mp_changed", mp)
	if mp == max_mp:
		emit_signal("mp_full")

func restore_mp(value):
	set_mp(mp + value)


func _on_hp_changed(value):
	$HUD.hp.set_current(value)
func _on_mp_changed(value):
	$HUD.mp.set_current(value)
