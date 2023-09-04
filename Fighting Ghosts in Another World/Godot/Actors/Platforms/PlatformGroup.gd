extends Node2D




func _ready():
	connect_signals()


func match_child_states(state : bool):
	# prevent recursion
	disconnect_signals()
	for c in get_children():
		c.set_active(state)
	connect_signals()


func connect_signals():
	for c in get_children():
		if c.has_signal("active_state_changed"):
			c.connect("active_state_changed", self, "match_child_states")
func disconnect_signals():
	for c in get_children():
		if c.has_signal("active_state_changed"):
			c.disconnect("active_state_changed", self, "match_child_states")
