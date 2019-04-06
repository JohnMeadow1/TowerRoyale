extends Node2D


export var hp = 500.0
var max_hp = hp
export var alive = true
var animation_offset = 0.0
var frame_offset = 0
var acumulator = 0
var agony_timer = 0.0
var ray_timer = 0

func _ready():
	max_hp = hp
	$hp_bar.max_value = hp
	animation_offset = rand_range(0, $source/ray.texture.get_width() )
	frame_offset = randi() % 3
	self.setup_ray()
	self.set_hp_bar()
	
func get_hit(dmg):
	if not self.alive:
		return
	
	self.hp -= dmg
	set_hp_bar()
	ray_timer = ray_timer + dmg * 0.2
	ray_timer = min (2,ray_timer)
	if self.hp <= 0:
		self.alive = false
		self.agony_timer = 3.0
		globals.channelers_num -= 1
		$shutdown.play()
		$AnimationPlayer.play("die")
		$hp_bar.visible = false
		$Particles2D.emitting = false

func set_hp_bar():
	$hp_bar.value = self.hp
	$hp_bar.modulate.g = min(1, (hp/max_hp)*2) 
	$hp_bar.modulate.r = clamp(2- hp/max_hp*2, 0 , 1 )
	
	
func is_alive():
	return self.alive
	
func setup_ray():
	var vector_to = get_node("../target").global_position - $source.global_position
	$Particles2D.position = vector_to.normalized() * (vector_to.length()-66) + Vector2(1,-30)
	$source.rotate(Vector2(1, 0).angle_to(vector_to))
	

func _process(delta):
	acumulator += delta
	if self.alive:
		# Generate animating ray
		if acumulator > 0.1:
			animation_offset +=8
			acumulator -= 0.1
			frame_offset = (frame_offset+1)%3
		
		var vector_to = get_node("../target").global_position - $source.global_position
		$source/ray.region_rect = Rect2(Vector2(animation_offset,33*frame_offset),Vector2(vector_to.length()-100, 33))
		$source.frame = frame_offset
		if ray_timer>0:
			ray_timer -= delta
			if ray_timer>0:
				$source.visible = false
				$Particles2D.emitting = false
			else:
				$source.visible = true
				$Particles2D.emitting = true
			
	else:
		self.agony_timer -= delta
		
		var height = 0.0
		if agony_timer > 0.0:
			height = (sin(10.0 * agony_timer - PI/2.0) + 1.0) / 2.0
			
		$"source".set_modulate(Color(1.0, 1.0, 1.0, height * 1.0))

func _on_body_entered(body):
	if body.has_method("detonate"):
		body.detonate()
