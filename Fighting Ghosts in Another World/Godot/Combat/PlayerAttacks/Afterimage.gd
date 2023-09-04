extends Sprite


func _ready():
	var t = create_tween()
	t.tween_property(self, "modulate", Color.transparent, 0.5)
	yield(t, "finished")
	queue_free()
