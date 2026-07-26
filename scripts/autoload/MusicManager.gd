extends Node

@onready var player: AudioStreamPlayer = $AudioStreamPlayer

func play_music():
	if !player.playing:
		player.play()
