extends Node

export var fade_time : float = 4

export var exploring : AudioStream = null
export var foreboding : AudioStream = null
export var battle_1 : AudioStream = null
export var battle_2 : AudioStream = null

onready var currentSong = $CurrentSong
onready var volume_default = currentSong.volume_db

var volume_tween : SceneTreeTween = null


func play_song(new_song : AudioStream):
	if currentSong.playing:
		end_song()
	# play new song
	currentSong.stop()
	currentSong.volume_db = volume_default
	currentSong.stream = new_song
	currentSong.play()

# fade audio
func end_song():
	var volume_tween = create_tween()
	volume_tween.set_ease(Tween.EASE_IN)
	volume_tween.set_trans(Tween.TRANS_CIRC)
	volume_tween.tween_property(currentSong, "volume_db", -80, fade_time)
	yield(volume_tween, "finished")
