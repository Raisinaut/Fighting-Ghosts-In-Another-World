extends Node2D

onready var camera = $Camera
onready var player = get_node("%Player")

func _ready():
	player.connect("damaged", camera, "small_shake")
	MusicPlayer.play_song(MusicPlayer.battle_1)
