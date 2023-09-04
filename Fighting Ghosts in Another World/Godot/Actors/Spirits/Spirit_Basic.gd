extends KinematicBody2D

onready var stats = $Stats
onready var playerDetection = $PlayerDetection
onready var sprites = $Sprites
onready var stunTimer = $StunTimer
onready var body = $Sprites/Body
onready var hitbox = $HitBox
onready var hurtbox = $HurtBox

var rng = RandomNumberGenerator.new()
var target : Node2D = null setget set_target
var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
# Movement Parameters
var max_speed := 20
var acceleration := 10
var friction := 30
var stun_duration := 0.5
var time_since_spawn := 0.0
var oscillation_rate = 3

func set_target(node : Node2D):
	if node.is_in_group("Player"):
		target = node
		
func remove_target(node : Node2D):
	if node == target:
		target = null


func _ready():
	rng.randomize()
	oscillation_rate += rng.randf_range(0, 1)
	stats.connect("hp_depleted", self, "defeated")
	playerDetection.connect("body_entered", self, "set_target")
	playerDetection.connect("body_exited", self, "remove_target")
	fade_in(2)


func fade_in(duration):
#	hurtbox.set_invincible(true)
	hitbox.set_disabled(true)
	
	var t = create_tween()
	t.set_ease(Tween.EASE_IN)
	modulate = Color.transparent
	t.tween_property(self, "modulate", Color.white, duration)
	yield(t, "finished")
	
	if is_defeated():
		# return if defeated before finished fading in
		return
	
	hurtbox.set_invincible(false)
	hitbox.set_disabled(false)
	

func _physics_process(delta):
	time_since_spawn += delta
	var oscillator = sin(time_since_spawn * oscillation_rate)
	
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)
	
	# gradually reduce shake during stun
	if not stunTimer.is_stopped():
		body.speed_scale = range_lerp(stunTimer.time_left, stun_duration, 0, 1, 0.2)
		
	# Follow target
	if target and stunTimer.is_stopped():
		var direction_to_target = global_position.direction_to(target.global_position)
		
		velocity = velocity.move_toward(direction_to_target * max_speed * max(oscillator, 0.5), acceleration * delta)
	# Or slow to a stop
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	# Bob amount
	var bob_velocity = Vector2(0, oscillator * 8)
	
	# Move
	velocity = move_and_slide(velocity)
	bob_velocity = move_and_slide(bob_velocity)
	# Flip sprites
	if target and stunTimer.is_stopped():
		if global_position.direction_to(target.global_position).x < 0:
			for s in sprites.get_children():
				s.flip_h = true
		else:
			for s in sprites.get_children():
				s.flip_h = false

## Hitbox interactions ##
func take_damage(amount):
	stats.hp -= amount
	if stats.hp > 0:
		$HitSFX.play_at_random_pitch()

func take_knockback(amount : float, knockback_vec : Vector2):
	knockback += knockback_vec * amount
	stunTimer.start(stun_duration)
	body.play("shake")

func _on_StunTimer_timeout():
	body.play("default")


# what happens when we die? This, I guess.
func defeated():
	# disable damaging 
	hitbox.set_disabled(true)
	hurtbox.set_invincible(true)
	# play sfx
	$DeafeatedSFX.play_at_random_pitch()
	# animate fade
	var duration = stun_duration
	var t = create_tween()
	t.tween_property(self, "modulate", Color.transparent, duration)
	# delete
	yield(t, "finished")
	# sanity check to make sure sprites don't show
	hide()
	if $DeafeatedSFX.playing:
		yield($DeafeatedSFX, "finished")
	queue_free()

func is_defeated():
	return stats.hp <= 0
