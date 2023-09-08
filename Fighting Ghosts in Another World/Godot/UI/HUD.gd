extends CanvasLayer

onready var spiritCount = get_node("%SpiritCount")
onready var spiritCountPos = spiritCount.rect_position
onready var hp = get_node("%HP")

var bump_tween : SceneTreeTween = null
var fade_tween : SceneTreeTween = null



func _ready():
	GlobalEnemyLogic.connect("enemy_list_modified", self, "set_spirit_count")

func set_spirit_count(value : int):
	# make opaque
	if fade_tween:
		fade_tween.kill()
	spiritCount.modulate.a = 1.0
	
	# set ending text
	var end = ""
	if value > 1:
		end = str(value) + " spirits left"
	elif value == 1:
		end = str(value) + " spirit left"
	else:
		end = "all spirits defeated"
	spiritCount.bbcode_text = "[right][wave amp=10 freq=3.0]" + end + "[/wave][/right]"
	
	# animation fx
	spiritCount.rect_position = spiritCountPos
	bump(spiritCount, Vector2(0, -4), 0.4)
	yield(bump_tween, "finished")
	fade_out(spiritCount, 1.0)


func bump(node : Control, pixel_amount : Vector2, duration : float = 0.3, bounce : bool = true):
	if bump_tween:
		bump_tween.kill()
		
	bump_tween = create_tween()
	var start_pos = node.rect_position
	bump_tween.set_trans(Tween.TRANS_QUAD)
	bump_tween.set_ease(Tween.EASE_OUT)
	bump_tween.tween_property(node, "rect_position", node.rect_position - pixel_amount, duration * 0.35)
	if bounce:
		bump_tween.set_ease(Tween.EASE_IN)
		bump_tween.tween_property(node, "rect_position", node.rect_position + pixel_amount + (pixel_amount * 0.5), duration * 0.35)
	bump_tween.set_ease(Tween.EASE_OUT)
	bump_tween.tween_property(node, "rect_position", start_pos, duration * 0.3)


func fade_out(node : Control, duration : float):
	fade_tween = create_tween()
	fade_tween.tween_property(node, "modulate:a", 0.4, duration)
