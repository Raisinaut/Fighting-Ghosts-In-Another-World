extends Node2D

export var song_name : String = ""

var _discard = null


func _ready():
	_discard = GlobalEnemyLogic.connect("all_enemies_defeated", self, "_on_all_enemies_defeated")
	
	MusicPlayer.play_song(MusicPlayer.get(song_name))
	$CanvasModulate.visible = true
	Global.start_dialog("ArenaStart").connect("timeline_end", self, "_on_timeline_end")


func _on_all_enemies_defeated():
	Global.start_dialog("ArenaFinished").connect("timeline_end", self, "_on_timeline_end")
	MusicPlayer.end_song()


func _on_timeline_end(timeline_name):
	if timeline_name == "ArenaStart":
		MusicPlayer.play_song(MusicPlayer.get("battle_2"))
		for s in $Spawners.get_children():
			s.active = true
	elif timeline_name == "ArenaFinished":
		MusicPlayer.play_song(MusicPlayer.get(song_name))



