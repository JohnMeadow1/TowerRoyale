extends RigidBody2D

var growl_timer = 4

func _ready():
	
	pass

func _process(delta):
	growl_timer -= delta
	if growl_timer < 0:
		growl_timer = rand_range(2,4)
		get_node("boss"+str(randi()%2) ).play()
