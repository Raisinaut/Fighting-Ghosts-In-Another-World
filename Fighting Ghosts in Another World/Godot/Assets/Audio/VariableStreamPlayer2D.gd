extends AudioStreamPlayer2D

export(Array, AudioStream) var audio_files: Array
export(Array, AudioStream) var alt_audio_files: Array
export(float, 0.01, 0.2, 0.01) var pitch_variance = 0.2


func _ready():
	randomize()

func play_random():
	select_rand_stream(audio_files)
	play()

func play_random_alt():
	select_rand_stream(alt_audio_files)
	play()

func select_rand_stream(random_pitch = true, array : Array = audio_files):
	var random_index: = randi() % array.size()
	if not random_pitch:
		pitch_scale = 0
	else:
		choose_random_pitch()
	stream = array[random_index]

func play_at_random_pitch():
	if not playing:
		choose_random_pitch()
		play()

func choose_random_pitch():
	pitch_scale = 1 + rand_range(-pitch_variance, pitch_variance)
