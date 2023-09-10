extends Node

signal finished_throw_tutorial

var dialog_is_active = false
var throw_tutorial_active = false
var throw_tutorial_finished = false setget set_throw_tutorial_finished


func _ready():
	Dialogic.set_variable("throw_input", InputMap.get_action_list("throw")[0].as_text())
	Dialogic.set_variable("charge_input", InputMap.get_action_list("charge")[0].as_text())
	Dialogic.set_variable("jump_input", InputMap.get_action_list("jump")[0].as_text())


func set_throw_tutorial_finished(state : bool):
	if throw_tutorial_finished == state:
		return
	throw_tutorial_finished = state
	emit_signal("finished_throw_tutorial")

func start_dialog(timeline_name):
	var dialog = Dialogic.start(timeline_name)
	dialog.connect("timeline_start", self, "_on_timeline_start")
	dialog.connect("timeline_end", self, "_on_timeline_end")
#	get_tree().get_root().call_deferred("add_child", dialog)
	get_tree().get_root().add_child(dialog)
	return dialog

func _on_timeline_start(_timeline_name):
	dialog_is_active = true

func _on_timeline_end(_timeline_name):
	dialog_is_active = false
