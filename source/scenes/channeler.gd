extends Node2D

export var frame = 0

func _ready():
	self.setup_ray()
	$AnimatedSprite.frame = frame
	
func setup_ray():
	# Hook bottom
	var ray_size = $ray.texture.get_size()
	$ray.set_offset(Vector2(0, ray_size.y / 2))
	
	# Set position
	$ray.set_position(Vector2(0.0, 0.0))
	
	# Set size to monster
	var vector_to = Vector2(get_node("../target").global_position - $ray.global_position)
	$ray.set_scale(Vector2(vector_to.length()*0.7 / ray_size.x, 1.0))
	
	# Set rotation
	$ray.rotate(Vector2(1, 0).angle_to(vector_to))

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
