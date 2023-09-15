extends CanvasLayer


func _process(delta):
	var d = Global.dialog_is_active
	var s = SceneChanger.scene_is_changing
	visible = not d and not s
