extends CanvasLayer

var _discard = null


func _ready():
	visible = false
	_discard = Global.connect("changed_dialog_is_active", self, "_on_changed_dialog_is_active")

func _on_changed_dialog_is_active(state):
	$AnimationPlayer.play("Pulse")
	visible = state
