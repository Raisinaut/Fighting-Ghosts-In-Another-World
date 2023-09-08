extends KinematicBody2D

signal impacted_target

export var afterimage_scene : PackedScene = null
export var impact_scene : PackedScene = null

onready var hitbox = $HitBox
onready var afterimageTimer = $AfterimageTimer

var direction := Vector2.ZERO
var speed = 200
var max_bounces = 2
var bounce_count = 0

export var bounce_sfx : AudioStream  = null
export var fizzle_sfx : AudioStream = null
export var hit_sfx : AudioStream = null


func _ready():
	afterimageTimer.start()
	hitbox.connect("detected", self, "_on_hitbox_detected")


func _on_hitbox_detected(detecting_node):
	if detecting_node.is_in_group("absorbent") or detecting_node.get_parent().is_in_group("absorbent"):
		emit_signal("impacted_target")
		end(detecting_node)


func _physics_process(delta):
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		# instance impact effect
		var impact : AnimatedSprite = instance_under_root(impact_scene)
		impact.global_position = collision.position
		impact.rotation = collision.normal.angle() + PI # direction of normal
		if bounce_count < max_bounces:
			direction = direction.bounce(collision.normal)
			impact.rotation = direction.angle() + PI # direction of bounce
			impact.stream_to_set = bounce_sfx
		# bouncing
		if bounce_count < max_bounces:
			bounce_count += 1
		else:
			impact.stream_to_set = fizzle_sfx
			queue_free()

# the final collision
func end(hit_node):
	var impact : AnimatedSprite = instance_under_root(impact_scene)
	var direction_to_node = global_position.direction_to(hit_node.global_position)
	impact.rotation = direction_to_node.angle()
	impact.global_position = global_position + direction_to_node * 8
	impact.stream_to_set = hit_sfx
	queue_free()


func _on_AfterimageTimer_timeout():
	var a : Sprite = instance_under_root(afterimage_scene)
	a.global_position = global_position


func instance_under_root(scene : PackedScene):
	var inst = scene.instance()
	get_tree().get_root().call_deferred("add_child", inst)
	return inst


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
