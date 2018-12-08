extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func set_monster_emerge(value):
	# Set emerge of the monster (0 - 100)
	if not ( 0 < value < 100 ):
		print("Worng value in set_monster_emerge(0-100)")
		
	$Sprite.set_region_rect(Rect2())
	$Sprite.set_offset(Rect2())
	

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
