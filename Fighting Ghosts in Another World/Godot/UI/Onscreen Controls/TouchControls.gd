extends CanvasLayer



onready var regionRight = $RegionRight
onready var regionLeft = $RegionLeft
var right_press_pos : Vector2

var enabled = false setget set_enabled



func _ready():
	self.enabled = OS.has_feature("mobile")


func set_enabled(state):
	enabled = state
	$Joystick.enabled = enabled
	$GestureMenu.menu_active = enabled


func _process(_delta):
	var d = Global.dialog_is_active
	var s = SceneChanger.scene_is_changing
	visible = not d and not s


func _input(event):
	if not enabled:
		return
	
	if Global.dialog_is_active:
		return
	
	if event is InputEventScreenTouch:
		# Right side touch
		if point_in_region(event.position, regionRight):
			if event.is_pressed() and $GestureMenu.menu_active == false:
				right_press_pos = event.position
				$GestureMenu.position = right_press_pos
				$GestureMenu.set_menu_active(true)
			else:
				$GestureMenu.set_menu_active(false)
		
		# Left side touch
		if point_in_region(event.position, regionLeft):
				if event.is_pressed():
					$Joystick.set_stick_position(event.position)
				else:
					$Joystick.reset_stick()
	
	if event is InputEventScreenDrag:
		if point_in_region(event.position, regionLeft):
			$Joystick.set_stick_position(event.position)

func point_in_region(pos : Vector2, region : TouchScreenButton) -> bool:
	var region_rect = Rect2(region.position, region.shape.extents * 2)
	return region_rect.has_point(pos)
