extends Node2D

export(float, 0.01, 0.10, 0.01) var pitch_variance = 0.05

onready var jump = $Jump
onready var land = $Land
onready var footstep = $Footstep
onready var launch = $Launch
onready var damaged = $Damaged
onready var charge = $Charge

func _ready():
	randomize()

func play_at_random_pitch(sound):
	if not sound.playing:
		sound.pitch_scale = get_random_pitch_value()
		sound.play()

func get_random_pitch_value():
	return 1 + rand_range(-pitch_variance, pitch_variance)
