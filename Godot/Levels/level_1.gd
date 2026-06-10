extends Node2D

export var song_name : String = ""

var _discard = null



func _ready():
	_discard = Global.connect("finished_throw_tutorial", self, "_on_finished_throw_tutorial")
	_discard = GlobalEnemyLogic.connect("all_enemies_defeated", self, "_on_all_enemies_defeated")
	
	MusicPlayer.play_song(MusicPlayer.get(song_name))
	$CanvasModulate.visible = true
	
	if not Global.throw_tutorial_finished:
		Global.start_dialog("TutThrowA").connect("timeline_end", self, "_on_timeline_end")
		Global.throw_tutorial_active = true
		

func _on_timeline_end(timeline_name):
	if timeline_name == "TutThrowA":
		$TipLayer.set_text("throw_tip")
		$TipLayer.visible = true

func _on_finished_throw_tutorial(finished):
	if finished:
		Global.start_dialog("TutThrowB")
		$TipLayer.visible = false

func _on_all_enemies_defeated():
	Global.start_dialog("FirstDoorUnlock")
	get_node("%ExitBarricade").set_open(true)

