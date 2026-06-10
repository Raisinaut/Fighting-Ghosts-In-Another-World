extends AudioStreamPlayer2D

export(Array, AudioStream) var audio_files: Array


func _ready():
	randomize()

func play(from_position : float = 0.0):
	select_rand_stream(audio_files)
	seek(from_position)
	playing = true

func select_rand_stream(array : Array = audio_files):
	var random_index: = randi() % array.size()
	stream = array[random_index]
