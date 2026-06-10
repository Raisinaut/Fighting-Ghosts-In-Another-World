extends HBoxContainer

export var icon : PackedScene = null

#var flash_tween : SceneTreeTween = null
var bump_tween : SceneTreeTween = null
var _discard = null



func set_max(value : int):
	for i in value:
		var inst = icon.instance()
		call_deferred("add_child", inst)
	yield(get_tree(), "idle_frame")
	set_current(value)

func set_current(value : int):
	var all_icons = get_children()
	for i in all_icons.size():
		var empty : bool = (i >= value)
		all_icons[i].texture.current_frame = int(empty)
		if not empty:
			flash(all_icons[i])

func flash(node : Control, duration : float = 0.4):
	node.modulate = Color.white * 20
	
#	if flash_tween:
#		flash_tween.kill() 
	var flash_tween = create_tween()
	_discard = flash_tween.set_ease(Tween.EASE_OUT)
	_discard = flash_tween.set_trans(Tween.TRANS_CIRC)
	_discard = flash_tween.tween_property(node, "modulate", Color.white, duration)
