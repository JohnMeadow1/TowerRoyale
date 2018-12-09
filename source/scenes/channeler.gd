extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var hp = 100
var alive = true

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here	
	self.setup_ray()
	
func take_damage(dmg):
	if not self.alive:
		return
	
	self.hp -= dmg
	$hp_bar.value = self.hp
	
	if self.hp <= 0:
		self.alive = false
		$ray.visible = false

func is_alive():
	return self.alive
	
func setup_ray():
	# Hook bottom
	var ray_size = $ray.texture.get_size()
#	$ray.set_offset(Vector2(0, ray_size.y / 2))
	
	# Set position
	$ray.set_position(Vector2(0.0, 0.0))
	
	# Set size to monster
	var vector_to = Vector2(get_node("../target").global_position - $ray.global_position)
#	$ray.set_scale(Vector2(vector_to.length()*0.7 / ray_size.x, 1.0))
#	$ray.region_rect= Rect2(Vector2(0,0),Vector2(vector_to.length()*0.7*4, 33))
	
	# Set rotation
	$ray.rotate(Vector2(1, 0).angle_to(vector_to))

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
#	$hp_bar.value = self.hp
	pass