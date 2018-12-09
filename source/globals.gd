extends Node

	
var monster = null
var debug = null

func _physics_process(delta):
	if debug:
		debug.text = ""