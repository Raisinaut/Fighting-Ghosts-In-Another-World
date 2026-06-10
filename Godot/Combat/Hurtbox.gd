# Allows its owner to detect hits and take damage
class_name HurtBox
extends Area2D

signal invincibility_started
signal invincibility_ended

export var automatic_invincibility := false
export(float, 0.1, 3, 0.1) var invincibilty_duration = 2.0 # seconds

var invincible = false setget set_invincible
var i_timer : SceneTreeTimer = null
var _discard = null


func _init() -> void:
	# The hurtbox should detect hits but not deal them. This variable does that.
	monitorable = false


func _ready() -> void:
	_discard = connect("area_entered", self, "_on_area_entered")
	_discard = connect("invincibility_started", self, "_on_invincibility_started")
	_discard = connect("invincibility_ended", self, "_on_invincibility_ended")

func _on_area_entered(hitbox):
	if hitbox.owner == self:
		return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
	if owner.has_method("take_knockback"):
		var knockback_vec = -global_position.direction_to(hitbox.global_position)
		owner.take_knockback(hitbox.knockback, knockback_vec)
	
	# double check this export variable if experiencing issues
	if automatic_invincibility:
		start_invincibility(invincibilty_duration)
	
	hitbox.emit_signal("detected", self)


## Invincibility ##
func set_invincible(state):
	invincible = state
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

func start_invincibility(duration : float = invincibilty_duration):
	self.set_invincible(true)
	# start invincibility timer
	i_timer = get_tree().create_timer(duration)
	_discard = i_timer.connect("timeout", self, "set_invincible", [false])

func _on_invincibility_started():
	set_deferred("monitoring", false)
func _on_invincibility_ended():
	set_deferred("monitoring", true)
