extends Node2D

export var song_name := ""
export var next_scene := ""

var _discard = null


func _ready():
	MusicPlayer.play_song(MusicPlayer.get(song_name))
	# have a timer let the mood sink in
	yield(get_tree().create_timer(3), "timeout")
	var dialog = Global.start_dialog("Introduction")
	dialog.connect("timeline_end", self, "_on_timeline_end")


func _on_timeline_end(_timeline_name):
	MusicPlayer.end_song()
	yield(get_tree().create_timer(MusicPlayer.fade_time), "timeout")
	SceneChanger.goto_scene(next_scene)


func _process(delta):
	$Dust.scroll_offset.y -= 10 * delta
	
