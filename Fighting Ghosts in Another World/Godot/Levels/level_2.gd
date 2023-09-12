extends Node2D

export var song_name : String = ""

var _discard = null


func _ready():
	MusicPlayer.play_song(MusicPlayer.get(song_name))
	_discard = GlobalEnemyLogic.connect("all_enemies_defeated", self, "_on_all_enemies_defeated")
	
	$CanvasModulate.visible = true

func _on_all_enemies_defeated():
	get_node("%ExitBarricade").set_open(true)
