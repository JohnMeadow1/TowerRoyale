extends Node2D


var hp = 100
var alive = true
var animation_offset = 0.0
var frame_offset = 0
var acumulator = 0

func _ready():
	animation_offset = rand_range(0, $source/ray.texture.get_width() )
	frame_offset = randi() % 3
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
	var vector_to = Vector2(get_node("../target").global_position - $source.global_position)
#	$ray.set_scale(Vector2(vector_to.length()*0.7 / ray_size.x, 1.0))
#	$ray.region_rect= Rect2(Vector2(0,0),Vector2(vector_to.length()*0.7*4, 33))
	
	# Set rotation
	$source.rotate(Vector2(1, 0).angle_to(vector_to))

func _process(delta):
	acumulator+= delta
	if acumulator>0.1:
		animation_offset +=8
		acumulator -= 0.1
		frame_offset = (frame_offset+1)%3
	var vector_to = Vector2(get_node("../target").global_position - $source.global_position)
	$source/ray.region_rect = Rect2(Vector2(animation_offset,33*frame_offset),Vector2(vector_to.length()*0.1, 33))
	$source.frame = frame_offset

func _on_body_entered(body):
	if body.has_method("detonate"):
		body.detonate()
		
func get_hit(value):
	hp -= value
	$hp_bar.value = hp