extends CanvasLayer



onready var gestureRegion = $GestureRegion
var right_press_pos : Vector2

var enabled = false setget set_enabled



func _ready():
	self.enabled = OS.has_feature("mobile")
	visible = enabled
	$GestureMenu.set_menu_active(false)


func set_enabled(state):
	enabled = state
	$GestureMenu.menu_active = enabled


func _process(_delta):
	if not OS.has_feature("mobile"):
		return
	
	var d = Global.dialog_is_active
	var s = SceneChanger.scene_is_changing
	var t = Global.throw_tutorial_active
	visible = not d and not s
	$MovementButtons.visible = not t


func _input(event):
	if not enabled:
		return
	
	if Global.dialog_is_active:
		return
	
	if event is InputEventScreenTouch:
		# Right side touch
		if point_in_region(event.position, gestureRegion):
			if event.is_pressed() and $GestureMenu.menu_active == false:
				right_press_pos = event.position
				$GestureMenu.position = right_press_pos
				$GestureMenu.set_menu_active(true)
			else:
				$GestureMenu.set_menu_active(false)

func point_in_region(pos : Vector2, region : TouchScreenButton) -> bool:
	var region_rect = Rect2(region.position, region.shape.extents * 2)
	return region_rect.has_point(pos)
