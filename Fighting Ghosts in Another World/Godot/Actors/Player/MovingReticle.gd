extends Node2D

export var draw_line : bool = false

onready var pivot = $Pivot
onready var reticle = $Pivot/Reticle
onready var reticle_sprite = $Pivot/Reticle/Sprite
onready var reticle_range : int = reticle.position.x
onready var reticle_offset := Vector2(0, -8)
# SFX
onready var sweep = $sweep
onready var activate = $activate
# tweens
var slide_tween : SceneTreeTween = null # slides the reticle on enable
# checks
var enabled = false setget set_enabled
var flipped = false setget set_flipped
# parameters
var rot_speed : float = 1.5
var time_scale_multiplier : float = Engine.time_scale
var slide_time : float = 0.2 # seconds
var max_angle = PI/2
var up_tilt = PI/6
# trackers
var time_enabled: float = 0.0
var _discard = null

func _ready():
	hide()


func _physics_process(delta):
	if enabled:
		# since this node is on its own canvas layer, we retreive positions relative to the veiwport
		var target_pos = get_parent().get_parent().get_global_transform_with_canvas().origin
		position = target_pos + reticle_offset
		
		if not slide_tween.is_valid():
			rotate_pivot()
			time_enabled += delta * rot_speed / time_scale_multiplier
			reticle.global_rotation = 0
		
		# account for Engine time scale
		if Engine.time_scale > 0:
			reticle_sprite.speed_scale = 1 / Engine.time_scale
		else:
			reticle_sprite.speed_scale = 0
	
	if draw_line:
		update()


# Draw dashed line to reticle
func _draw():
	if not enabled:
		return
	
	var segment_count = 10
	var segment_length = get_distance() / segment_count
	for i in segment_count:
		var dir = get_direction() 
		var line_start = dir * i * segment_length
		var line_end = line_start + dir * segment_length / 6
		draw_line(line_start, line_end, Color.white, 1.01) 


func get_direction():
	return global_position.direction_to(reticle.global_position)

func get_distance():
	return global_position.distance_to(reticle.global_position)

func rotate_pivot():
	if flipped:
		pivot.rotation = abs(wrapf(time_enabled, max_angle, -max_angle)) - max_angle / 2
		pivot.rotation += up_tilt
	else:
		pivot.rotation = -abs(wrapf(time_enabled, -max_angle, max_angle)) + max_angle / 2
		pivot.rotation -= up_tilt


# SETTERS #
func set_enabled(state):
	enabled = state
	visible = state
	# Slide reticle to start position
	if state == true:
		# stop previous tween
		if slide_tween:
			slide_tween.kill()
			
		# reset values
		rotate_pivot()
		reticle.global_rotation = 0
		reticle.position.x = 0
		
		# tween reticle
		slide_tween = create_tween()
		if flipped:
			_discard = slide_tween.tween_property(reticle, "position:x", -reticle_range, slide_time * Engine.time_scale)
		else:
			_discard = slide_tween.tween_property(reticle, "position:x", reticle_range, slide_time * Engine.time_scale)
		activate.play_at_random_pitch()
		sweep.play()
	else:
		sweep.stop()
		time_enabled = 0
	


func set_flipped(state):
	flipped = state
	if flipped:
		reticle.position.x = -reticle_range
	else:
		reticle.position.x = +reticle_range

