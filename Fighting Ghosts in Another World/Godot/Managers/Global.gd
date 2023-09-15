extends Node

signal finished_throw_tutorial
signal changed_dialog_is_active

var dialog_is_active = false setget set_dialog_is_active
var throw_tutorial_active = false
var throw_tutorial_finished = false setget set_throw_tutorial_finished

var current_dialog = null
var current_timeline : String = ""


func set_dialog_is_active(state):
	dialog_is_active = state
	emit_signal("changed_dialog_is_active", dialog_is_active)

func _ready():
	Dialogic.set_variable("throw_input", InputMap.get_action_list("throw")[0].as_text())
	Dialogic.set_variable("charge_input", InputMap.get_action_list("charge")[0].as_text())
	Dialogic.set_variable("jump_input", InputMap.get_action_list("jump")[0].as_text())

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		end_dialog()

# Tell Dialogic to start a timeline
# Ends the previous dialog first, if one exists
func start_dialog(timeline_name):
	if current_dialog:
		end_dialog()
		
	current_timeline = timeline_name
	current_dialog = Dialogic.start(current_timeline)
	current_dialog.connect("timeline_start", self, "_on_timeline_start")
	current_dialog.connect("timeline_end", self, "_on_timeline_end")
	get_tree().get_root().call_deferred("add_child", current_dialog)
	return current_dialog

# Effectively skips dialog by freeing the current node 
#  and signals that that timeline finished
func end_dialog():
	if current_dialog == null:
		return
	current_dialog.emit_signal("timeline_end", current_timeline)

func _on_timeline_start(_timeline_name):
	set_dialog_is_active(true)

func _on_timeline_end(_timeline_name):
	if current_dialog:
		current_dialog.queue_free()
	set_dialog_is_active(false)
	current_dialog = null

func set_throw_tutorial_finished(state : bool):
	if throw_tutorial_finished == state:
		return
	throw_tutorial_finished = state
	emit_signal("finished_throw_tutorial", throw_tutorial_finished)
