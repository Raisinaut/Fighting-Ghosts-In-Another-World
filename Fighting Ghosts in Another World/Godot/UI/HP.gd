extends HBoxContainer

export var heart_scene : PackedScene = null



func set_max(value : int):
	for i in value:
		var heart_inst = heart_scene.instance()
		call_deferred("add_child", heart_inst)
	yield(get_tree(), "idle_frame")
	set_current(value)

func set_current(value : int):
	var all_hearts = get_children()
	for i in all_hearts.size():
		var empty : bool = (i >= value)
		all_hearts[i].texture.current_frame = int(empty)
