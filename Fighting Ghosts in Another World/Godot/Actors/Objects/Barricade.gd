extends StaticBody2D

onready var sprite = $Sprite
onready var collision := $CollisionShape2D
onready var disableSFX

var open := false setget set_open
var position_tween : SceneTreeTween = null
var open_height := 40

var _discard = null


func _ready():
	set_open(false)
	_discard = GlobalEnemyLogic.connect("all_enemies_defeated", self, "set_open", [true])


func set_open(state):
	open = state
	var end_height : int
	if open:
		end_height = open_height
		$DisableSFX.play()
	else:
		end_height = 0
	
	if position_tween:
		position_tween.kill()
	position_tween = create_tween()
	_discard = position_tween.set_ease(Tween.EASE_IN)
	_discard = position_tween.set_trans(Tween.TRANS_QUAD)
#	_discard = position_tween.tween_property(sprite, "region_rect:position:y", end_height, 0.3)
#	_discard = position_tween.tween_property(sprite, "region_rect:size:y", 48 - end_height, 0.3)
	var tween_rect = Rect2(0, end_height, 16, 48 - end_height)
	_discard = position_tween.tween_method(self, "set_region_rect", sprite.region_rect,tween_rect, 0.4 )
	
	collision.set_deferred("disabled", open)


func set_region_rect(rect : Rect2):
	sprite.region_rect.position.y = rect.position.y
	sprite.region_rect.size.y = rect.size.y
