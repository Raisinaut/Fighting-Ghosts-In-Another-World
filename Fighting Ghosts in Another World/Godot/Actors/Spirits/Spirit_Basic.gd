extends KinematicBody2D

signal defeated

onready var spawnPosition = $SpawnPosition
onready var stats = $Stats
onready var playerDetection = $PlayerDetection
onready var softCollision = $SoftCollision
onready var sprites = $Sprites
onready var stunTimer = $StunTimer
onready var aggroTimer = $AggroTimer
onready var body = $Sprites/Body
onready var hitbox = $HitBox
onready var hurtbox = $HurtBox

var rng = RandomNumberGenerator.new()
var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var target : Node2D = null
var revealed := false setget set_revealed
var aggressive := false
# Movement Parameters
var max_speed := 50
var max_chase_distance := 300
var max_target_distance := 200

var acceleration := 25
var friction := 15
var stun_duration := 0.5
var time_since_spawn := 0.0
var oscillation_rate = 3

var state = STATES.WAIT setget set_state
enum STATES {
	WAIT,
	CHASE,
	RETURN
}


func _ready():
	set_revealed(false)
	if aggressive:
		set_state(STATES.CHASE)
		set_revealed(true)
	# save spawn position
	spawnPosition.set_as_toplevel(true)
	spawnPosition.global_position = global_position
	# slightly randomize oscillation
	rng.randomize()
	oscillation_rate += rng.randf_range(0, 1)
	stats.connect("hp_depleted", self, "defeated")


# returns tween to allow yielding
func fade_in(duration) -> SceneTreeTween:
	# disable damage
	hitbox.set_disabled(true)
	hurtbox.set_invincible(false)
	# animate fade
	var t = create_tween()
	t.set_ease(Tween.EASE_IN)
	modulate = Color.transparent
	t.tween_property(self, "modulate", Color.white, duration)
	if is_defeated():
		# return if defeated before finished fading in
		return null
	return t

# returns tween to allow yielding
func fade_out(duration) -> SceneTreeTween:
	# disable damage
	hitbox.set_disabled(true)
	# animate fade
	var t = create_tween()
	t.tween_property(self, "modulate", Color.transparent, duration)
	return t


func _physics_process(delta):
	time_since_spawn += delta
	var oscillator = sin(time_since_spawn * oscillation_rate)
	
	# Bobbing
	var bob_velocity = Vector2(0, oscillator * 8)
	bob_velocity = move_and_slide(bob_velocity)
	
	# Knockback
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)

	# gradually reduce shake during stun
	if not stunTimer.is_stopped():
		body.speed_scale = range_lerp(stunTimer.time_left, stun_duration, 0, 1, 0.2)
	
	
	# Move
	if target and stunTimer.is_stopped():
		var chase_height_offset := Vector2(0, -8)
		var direction_to_target = global_position.direction_to(target.global_position + chase_height_offset)
		velocity = velocity.move_toward(direction_to_target * max_speed * max(oscillator, 0.5), acceleration * delta)
		# Flip sprites
		if global_position.direction_to(target.global_position).x < 0:
			for s in sprites.get_children():
				s.flip_h = true
		else:
			for s in sprites.get_children():
				s.flip_h = false
				
		# Return if beyond max chase distance or target is too far
		var chase_distance = global_position.distance_to(spawnPosition.global_position)
		var target_distance = global_position.distance_to(target.global_position)
		if chase_distance > max_chase_distance or target_distance > max_target_distance:
			set_state(STATES.RETURN)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	velocity += softCollision.get_push_vector() * delta * 10
	velocity = move_and_slide(velocity)


# one shot function for state change
func set_state(new_state):
	state = new_state
	match(state):
		STATES.WAIT:
			pass
		STATES.CHASE:
			target = GlobalEnemyLogic.player_node
			# Once encountered don't stay hidden at spawn point
			if not revealed:
				set_revealed(true)
		STATES.RETURN:
			# reset aggro timer
			aggroTimer.stop()
			# reset target
			target = null
			# fade out
			hitbox.set_disabled(true)
			yield(fade_out(1), "finished")
			# teleport back
			global_position = spawnPosition.global_position
			# reset velocity
			velocity = Vector2.ZERO
			# fade in
			yield(fade_in(1), "finished")
			hitbox.set_disabled(false)
			# switch to wait
			set_state(STATES.WAIT)


func set_revealed(new_state):
	revealed = new_state
	if revealed:
		hurtbox.set_invincible(false)
		yield (fade_in(1.5), "finished")
		hitbox.set_disabled(false)
	else:
		modulate = Color.transparent
		hitbox.set_disabled(true)
		hurtbox.set_invincible(true)

## Hitbox interactions ##
func take_damage(amount):
	# chase player
	if target != GlobalEnemyLogic.player_node:
		target = GlobalEnemyLogic.player_node
		aggroTimer.start()
	stats.hp -= amount
	if not is_defeated():
		$HitSFX.play_at_random_pitch()

func take_knockback(amount : float, knockback_vec : Vector2):
	knockback = knockback_vec * amount
	stunTimer.start(stun_duration)
	body.play("shake")

func _on_StunTimer_timeout():
	body.play("default")


## Target Management ##
func _on_PlayerDetection_body_entered(_body):
	if state != STATES.CHASE:
		set_state(STATES.CHASE)
func _on_PlayerDetection_body_exited(_body):
	if not aggressive:
		aggroTimer.start()
func _on_AggroTimer_timeout():
	if target and not playerDetection.overlaps_body(target):
		set_state(STATES.RETURN)


# what happens when we die? This, I guess.
func defeated():
	# prevent collisions with projectiles
	hurtbox.set_invincible(true)
	# play sfx
	$DeafeatedSFX.play_at_random_pitch()
	var fade_tween = fade_out(stun_duration)
	yield(fade_tween, "finished")
	if $DeafeatedSFX.playing:
		yield($DeafeatedSFX, "finished")
	emit_signal("defeated")
	queue_free()


func is_defeated():
	return stats.hp <= 0
