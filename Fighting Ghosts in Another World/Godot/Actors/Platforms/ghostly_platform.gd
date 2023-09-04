extends StaticBody2D

signal active_state_changed

onready var revertedSprite = $Reverted
onready var wispSprite = $Wisp
onready var mainSprite = $Main
onready var physicsCollision = $PhysicsCollision
onready var detection = $ProjectileDetection
onready var detectionCollision = $ProjectileDetection/DetectionCollision
onready var revertParticles = $RevertParticles
onready var light = $Wisp/Sparkles/Light2D

onready var active_height = 12
onready var reverted_height = 16
onready var light_energy_initial = light.energy

export var lifetime = 6

var active = false setget set_active

var timer = 0
var _discard = null



#func _ready():
#	set_active(false)

func _process(delta):
	if active:
		timer += delta
		# wisp animation
		if timer > 0.06:
			timer = 0
			wispSprite.region_rect.position.x = wrapi(wispSprite.region_rect.position.x + 1, 0, 16)
		# modulate loop pitch
		$Loop.pitch_scale = range_lerp(mainSprite.region_rect.size.y, 0, active_height, 1.0, 0.8) 


func set_active(state):
	if active != state:
		emit_signal("active_state_changed", state)
	active = state
	mainSprite.visible = active
	wispSprite.visible = active
	revertedSprite.visible = not active
	physicsCollision.set_deferred("disabled", not active)
	if active:
		$Activate.play_at_random_pitch()
		$Loop.play()
		flash()
		start_shrinking()
	else:
		$Loop.stop()
		$Deactivate.play_at_random_pitch()
		reset_values(reverted_height)


func start_shrinking():
	reset_values(active_height)
	var t = create_tween()
	_discard = t.set_ease(Tween.EASE_IN)
	_discard = t.set_trans(Tween.TRANS_QUAD)
	_discard = t.tween_property(mainSprite, "region_rect:size:y", 0, lifetime)
	_discard = t.parallel().tween_property(wispSprite, "position:y", 0, lifetime)
	_discard = t.parallel().tween_property(physicsCollision, "shape:extents:y", 0, lifetime)
	_discard = t.parallel().tween_property(physicsCollision, "position:y", 0, lifetime)
	_discard = t.parallel().tween_property(light, "scale", Vector2.ONE * 0.5, lifetime)
	t.connect("finished", self, "set_active", [false])
	yield(t,"finished")
	revertParticles.emitting = true # not in set_active to prevent unwanted triggering


# restore tweened properites
# height dependent
func reset_values(height):
	mainSprite.region_rect.size.y = height
	wispSprite.position.y = height
	physicsCollision.shape.extents.y = height / 2.0
	physicsCollision.position.y = height / 2.0
	detectionCollision.shape.extents.y = height / 2.0
	detectionCollision.position.y = height / 2.0
	light.scale = Vector2.ONE
	light.energy = light_energy_initial


func _on_ProjectileDetection_body_entered(body):
	if not active:
		set_active(true)
		if body.has_method("end"):
			body.end(self) # pass self as reference for body's function


func flash():
	var t = create_tween()
	light.scale = Vector2.ONE * 1.5
	t.set_ease(Tween.EASE_OUT)
	t.set_trans(Tween.TRANS_EXPO)
	t.tween_property(light, "scale", Vector2.ONE, 0.25)
