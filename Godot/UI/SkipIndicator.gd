extends CanvasLayer

onready var parentContainer = $MarginContainer
onready var skipLabel = get_node("%SkipLabel")
onready var skipButton = get_node("%SkipButton")

var _discard = null



func _ready():
	visible = false

	if OS.has_feature("mobile"):
		skipLabel.hide()
		skipButton.show()
	else:
		skipLabel.show()
		skipButton.hide()
	
	skipLabel.text = "Press " + InputMap.get_action_list("skip_dialog")[0].as_text() + " to skip"
	_discard = Global.connect("changed_dialog_is_active", self, "_on_changed_dialog_is_active")


func _on_changed_dialog_is_active(state):
	$AnimationPlayer.play("Pulse")
	visible = state
	parentContainer.modulate.a = int(not visible)
	var t = create_tween()
	t.tween_property(parentContainer, "modulate:a", int(visible), 0.5)


func _on_SkipButton_pressed():
	var skip_event_press = InputEventAction.new()
	skip_event_press.action = "skip_dialog"
	skip_event_press.pressed = true
	Input.parse_input_event(skip_event_press)
	var skip_event_release = InputEventAction.new()
	skip_event_release.action = "skip_dialog"
	skip_event_release.pressed = false
	Input.parse_input_event(skip_event_release)
