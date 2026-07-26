extends Node

var player := AudioStreamPlayer.new()

func _ready():
	add_child(player)
	player.stream = preload("res://assets/sound/JAZZGMTK26_FINAL.wav")
	player.play()
	
func play_music():
	if not player.playing:
		player.play()
