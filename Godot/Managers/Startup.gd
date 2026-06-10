extends Node

export var initial_scene : String = ""

# immediately load first scene
func _ready():
	SceneChanger.goto_scene(initial_scene)
