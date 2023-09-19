extends Node2D




func _ready():
	connect_signals()
	level_volume_intensity()


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


func level_volume_intensity():
#	var reduction_amount = 10 * log(get_child_count())
	var reduction_amount = 10 * log_with_base(get_child_count(), 10)
	for c in get_children():
		c.set_relative_volumes(-reduction_amount)
	print(reduction_amount)

func log_with_base(value, base):
	return log(value) / log(base)
