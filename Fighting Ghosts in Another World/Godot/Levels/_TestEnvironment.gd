extends Node2D

func _ready():
	MusicPlayer.play_song(MusicPlayer.battle_1)
	$CanvasModulate.visible = true
