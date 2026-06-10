extends Node2D

func _ready():
	MusicPlayer.play_song(MusicPlayer.battle_1)
	$CanvasModulate.visible = true
	GlobalEnemyLogic.connect("all_enemies_defeated", self, "_on_all_enemies_defeated")
	

func _on_all_enemies_defeated():
	MusicPlayer.end_song()
	Global.start_dialog("ArenaFinished")
	
