extends Node2D

export var song_name : String = ""


func _ready():
	MusicPlayer.play_song(MusicPlayer.get(song_name))
	$CanvasModulate.visible = true
