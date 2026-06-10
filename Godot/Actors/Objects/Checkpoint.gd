extends Node2D

onready var playerDetection = $PlayerDetection

var active = false setget set_active


func _ready():
	hide()
	playerDetection.connect("body_entered", self, "activate")


func activate(_body):
	CheckpointManager.set_current_checkpoint(self)
	set_active(true)


func set_active(state):
	active = state
