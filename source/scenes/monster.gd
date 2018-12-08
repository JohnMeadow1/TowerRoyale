extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var emerge = 1.0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func set_monster_emerge(value):
	# Set emerge of the monster (0 - 100)
	if not ( 0 <= value and value <= 100 ):
		print("Wrong value in set_monster_emerge(0-100)")
		
	var height = int((value/100.0) * 100.0)
	$Sprite.set_region_rect(Rect2(0, 0, 100, height))
	$Sprite.set_offset(Vector2(-50, -height))
	

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	emerge += 50 * delta
	emerge = emerge if emerge <= 100.0 else emerge - 100.0
	
	set_monster_emerge(int(emerge))	
