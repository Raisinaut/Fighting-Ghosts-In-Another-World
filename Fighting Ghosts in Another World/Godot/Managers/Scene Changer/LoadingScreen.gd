extends CanvasLayer

onready var loadingBar = $Background/MarginContainer/CenterContainer/VBoxContainer/LoadingBar
onready var loadingLabel = $Background/MarginContainer/CenterContainer/VBoxContainer/Label
onready var animator = $AnimationPlayer
onready var background = $Background

signal faded_in
signal faded_out


func _ready():
	background.visible = true
	animator.play("FADE_IN_SCREEN")
	yield(animator, "animation_finished")
	animator.play("FADE_LOAD")


func set_loading_value(value : float, show_progress : bool):
#	if !loadingBar:
#		return
	loadingLabel.visible = show_progress
	loadingBar.hide()
	loadingBar.value = value


func fade_out():
	animator.play("FADE_OUT_SCREEN")


func _on_AnimationPlayer_animation_finished(anim_name):
	match(anim_name):
		"FADE_IN_SCREEN":
			emit_signal("faded_in")
		"FADE_OUT_SCREEN":
			emit_signal("faded_out")
			queue_free()
