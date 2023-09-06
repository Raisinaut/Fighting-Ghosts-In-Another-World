extends StaticBody2D

onready var sprite = $Sprite
onready var collision := $CollisionShape2D

var open := false setget set_open
var position_tween : SceneTreeTween = null
var open_height := -40

var _discard = null


func _ready():
	set_open(false)
	_discard = GlobalEnemyLogic.connect("enemy_list_cleared", self, "set_open", [true])


func set_open(state):
	open = state
	var end_height : int
	if open:
		end_height = open_height
	else:
		end_height = 0
	
	if position_tween:
		position_tween.kill()
	position_tween = create_tween()
	_discard = position_tween.set_ease(Tween.EASE_IN)
	_discard = position_tween.set_trans(Tween.TRANS_QUAD)
	_discard = position_tween.tween_property(sprite, "position:y", end_height, 0.4)
	
	collision.disabled = open
