extends Node

var is_playing = null

func _ready():
	is_playing = $summon_0
	pass

func _process(delta):
	if is_playing.get_playback_position() >= is_playing.stream.get_length() - delta:
		is_playing = get_child(randi()%3)
		is_playing.play()