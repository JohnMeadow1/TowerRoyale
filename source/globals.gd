extends Node

	
var monster = null
var debug = null

var spawn_enemies = true
var channelers_num = 5

func _physics_process(delta):
	if debug:
		debug.text = ""