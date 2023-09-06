extends KinematicBody2D

signal damaged
signal died

const BULLET_TIME_SCALE = 0.1
const FRAME_FREEZE_SCALE = 0.06
const DEFAULT_SCALE = 1.0

onready var sprite := $AnimatedSprite
onready var coyoteTimer = $CoyoteTimer
onready var jumpBuffer = $JumpBuffer
onready var dustParticles = $DustParticles
onready var movingReticle = $CanvasLayer/MovingReticle
onready var collisionShape = $CollisionShape2D
onready var sfx2d = $SFX2D
onready var hurtbox = $HurtBox

export(int, 0, 200, 5) var move_speed := 80
export(int, 200, 1000, 10) var move_accel := 2000
export(int, 500, 1000, 10) var friction := 400

export(int, 500, 1000, 10) var bullet_time_friction := 200
export(int, 50, 1000, 10) var max_fall_speed := 150
export(int, 0, 1000, 50) var gravity_normal := 450
export(int, 0, 1000, 50) var gravity_jump_cancel := 600
export(int, 0, 300, 5) var jump_strength := 180
export(int, 0, 300, 5) var double_jump_strength := 160
export(float, 0, 0.5, 0.05) var jump_cancel_percent := 0.30
export var projectile : PackedScene = null

var gravity = gravity_normal
var velocity := Vector2.ZERO
var knockback := Vector2.ZERO
var input_direction : float = 0
var frame_freeze := false
var frame_freeze_timer : SceneTreeTimer = null # holds the current frame freeze timer
var just_jumped := false # for coyote time
var just_damaged := false # resets to false once landed
var can_double_jump = false
var bullet_time = false setget set_bullet_time

enum STATES {
	MOVE,
	FELL,
	RESPAWN,
	DEAD
}
var state = STATES.MOVE setget set_state



func _ready():
	CheckpointManager.spawn_location = global_position
	GlobalEnemyLogic.set_player_node(self)

func _physics_process(delta):
	match(state):
		STATES.MOVE:
			# CHECKS
			var is_jumping := false
			var is_double_jumping := false
			var is_jump_cancelled := false
			if not bullet_time:
				is_jumping = not jumpBuffer.is_stopped() && (is_on_floor() or not coyoteTimer.is_stopped())
				is_double_jumping = can_double_jump and just_jumped and Input.is_action_just_pressed("jump")
				is_jump_cancelled = Input.is_action_just_released("jump")
			
			var is_idling : bool = is_on_floor() and input_direction == 0
			var is_running : bool = is_on_floor() and not is_zero_approx(velocity.x)
			var is_falling : bool = velocity.y > 0.0 and not is_on_floor() and not Input.is_action_pressed("jump")
			
			
			# Set velocity
			if is_zero_approx(input_direction):
				if bullet_time:
					velocity.x = move_toward(velocity.x, 0, bullet_time_friction * delta)
				else:
					velocity.x = move_toward(velocity.x, 0, move_accel * delta)
			else:
#				# prevent movement while being knocked back
				if is_zero_approx(knockback.length()):
					velocity.x = move_speed * input_direction
#				velocity.x = move_toward(velocity.x, input_direction * move_speed, move_accel * delta)
			velocity.y += gravity * delta
			velocity.y = min(velocity.y, max_fall_speed) # limit fall speed
			
			# Jump
			if is_jumping:
				velocity.y = -jump_strength
				dustParticles.emit()
				jumpBuffer.stop()
				coyoteTimer.stop()
				just_jumped = true
			elif is_double_jumping:
				print("double jump")
				velocity.y = -double_jump_strength
				dustParticles.emit()
				just_jumped = true
			elif is_jump_cancelled:
				gravity = gravity_jump_cancel
				if velocity.y < 0:
					velocity.y *= jump_cancel_percent
			
			# pre-movement checks
			var was_on_floor = is_on_floor()
			var was_falling = is_falling
			
			# Reset animation_speed
			sprite.speed_scale = 1.0
			
			# set snap distance
			var snap = Vector2.DOWN * 2  if  !is_jumping  else  Vector2.ZERO # snap up to down while not jumping
			# Move
			if knockback.length() > 0:
				knockback.y = max(knockback.y, -jump_strength)
				knockback.y = move_toward(knockback.y, 0, gravity * delta)
				knockback.x = move_toward(knockback.x, 0, friction * delta)
				var _discard = move_and_slide_with_snap(knockback + velocity, snap, Vector2.UP, true, 4, PI/4, false)
			else:
				velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP, true, 4, PI/4, false)
			
			
			# On floor
			if is_on_floor():
				if was_falling:
					dustParticles.emit()
					sprite.play("land")
					sfx2d.play_at_random_pitch(sfx2d.land)
				set_bullet_time(false)
				gravity = gravity_normal
				just_jumped = false
				just_damaged = false
			elif was_on_floor and not just_jumped:
				coyoteTimer.start()
			
			# Update sprite and animation
			if not movingReticle.enabled:
				face_towards(input_direction)
			var is_landing : bool = sprite.playing == true and sprite.animation == "land"
			
			if is_jumping:
				sfx2d.play_at_random_pitch(sfx2d.jump)
				sprite.play("jump")
			elif is_idling and not is_landing:
				sprite.play("idle")
			elif is_running and not is_landing:
				# Scale animation speed to movement speed
				var anim_speed = range_lerp(abs(velocity.x), 0, move_speed, 0.3, 1.0)
				sprite.speed_scale = anim_speed
				
				var moving_backwards = abs(velocity.x - input_direction) > 0
				if movingReticle.enabled and moving_backwards:
						sprite.play("run_backwards")
				else:
					sprite.play("run")
					
				
			elif is_falling and not is_landing:
				sprite.play("fall")


# One-shot state change actions
func set_state(s):
	state = s
	match(state):
		STATES.FELL:
			print("Fell")
			input_direction = 0
			velocity = Vector2.ZERO
			knockback = Vector2.ZERO
			movingReticle.set_enabled(false)
			take_damage(1)
			if $Stats.hp > 0:
				set_state(STATES.RESPAWN)
#			else:
#				set_state(STATES.DEAD)
			hide() # PLACEHOLDER
			
		STATES.RESPAWN:
			print("Respawn")
			# disable all collision
			collisionShape.set_deferred("disabled", true)
			hurtbox.set_invincible(true)
			# tween global_position to last checkpoint
			var t = create_tween()
			t.set_ease(Tween.EASE_IN_OUT)
			t.set_trans(Tween.TRANS_CUBIC)
			t.tween_property(self, "global_position", CheckpointManager.get_checkpoint_position(), .8)
			yield(t, "finished")
			# play respawn animation
			# wait until animation is finished
			# enable all collision
			collisionShape.set_deferred("disabled", false)
#			hurtbox.set_invincible(false) # <<<<<<<<<<<<< uncomment if damage is not taken on fall
#			$Stats.set_hp($Stats.init_hp)
			
			show() # PLACEHOLDER
			
			set_state(STATES.MOVE)
		
		STATES.DEAD:
			print("dead")
			collisionShape.set_deferred("disabled", true)
			hurtbox.set_invincible(true)
			# play death animation
			emit_signal("died")


# Sets input direction and starts buffer timers
func _unhandled_input(event):
	if state != STATES.MOVE:
		return
	
	# Throw
	if event.is_action("throw") and Input.is_action_just_pressed("throw"):
		if not movingReticle.enabled:
			if not is_on_floor():
				set_bullet_time(true)
			movingReticle.set_enabled(true)
		else:
			var m = instance_scene(projectile)
			m.global_position = self.global_position + movingReticle.reticle_offset
			m.direction = movingReticle.get_direction()
			movingReticle.set_enabled(false)
			set_bullet_time(false)
			sfx2d.play_at_random_pitch(sfx2d.launch)
		
	elif Input.is_action_pressed("cancel_throw"):
		movingReticle.set_enabled(false)
		set_bullet_time(false)
	
	# Movement
	if not bullet_time:
		input_direction = Input.get_axis("move_left", "move_right")
		# Input buffer
		if Input.is_action_just_pressed("jump"):
			jumpBuffer.start()


func take_damage(amount):
	if state == STATES.DEAD:
		return
		
	print("damaged")
	# check before setting hp
	# only flash if not dead
	if $Stats.hp - amount > 0:
		sprite.flash(hurtbox.invincibilty_duration)
	emit_signal("damaged")
	$Stats.set_hp($Stats.hp - amount)
	sfx2d.play_at_random_pitch(sfx2d.damaged)
	set_bullet_time(false)
	set_frame_freeze(true)
	just_damaged = true


# sets knockback dependent on current velocity direction
# matching directions results in less knockback to cap speed changes
func take_knockback(_amount : float, knockback_vec : Vector2):
	if state != STATES.MOVE:
		return
	
	knockback.x = sign(knockback_vec.x) * 200
	if sign(knockback.x) == sign(velocity.x):
		knockback.x /= 2
	knockback.y = -150
	if velocity.y < 0:
		knockback.y /= 2


func set_frame_freeze(new_state, duration : float = 0.4):
	frame_freeze = new_state
	print("frame freeze")
	Engine.time_scale = FRAME_FREEZE_SCALE
	frame_freeze_timer = get_tree().create_timer(duration * Engine.time_scale)
	yield(frame_freeze_timer, "timeout")
	if bullet_time:
		Engine.time_scale = BULLET_TIME_SCALE
	else:
		Engine.time_scale = DEFAULT_SCALE
	
	frame_freeze = false


func set_bullet_time(new_state):
	if just_damaged:
		return
	
	bullet_time = new_state
	if bullet_time:
		Engine.time_scale = BULLET_TIME_SCALE
		movingReticle.time_scale_multiplier = Engine.time_scale
		input_direction = 0 # cancel move direction
	else:
		Engine.time_scale = DEFAULT_SCALE
		movingReticle.time_scale_multiplier = Engine.time_scale


# Pretty self-explanatory
func face_towards(direction : float):
	if direction < 0:
		sprite.flip_h = true
		movingReticle.flipped = true
	elif direction > 0:
		sprite.flip_h = false
		movingReticle.flipped = false


func instance_scene(scene : PackedScene) -> Node2D:
	var scene_inst = scene.instance()
	get_tree().get_root().call_deferred("add_child", scene_inst)
	return scene_inst


func _on_AnimatedSprite_frame_changed():
	if sprite.animation == "run" and sprite.frame == 1:
		sfx2d.play_at_random_pitch(sfx2d.footstep)


func _on_Stats_hp_depleted():
	set_state(STATES.DEAD)
