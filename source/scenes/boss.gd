extends RigidBody2D

var bullet_object = preload("res://scenes/bullet_boss.tscn")

var growl_timer     = 4
var attack_timer    = 5
var bullet_iterator = 0
var attack_ray_timer = 6
var ray_iterator = 0
var target = null
func _ready():
	
	pass

func _process(delta):
	growl_timer -= delta
	if growl_timer < 0:
		growl_timer = rand_range(2,4)
		get_node("boss"+str(randi()%2) ).play()
	attack_ray_timer -= delta
	if attack_ray_timer < 0:
		if target:
			$ray_sprite.rotation = Vector2(1,0).angle_to(target.position-$ray_sprite.global_position) + rand_range(-0.02,0.02)
			ray_iterator += delta
			for body in $ray_sprite/Area2D.get_overlapping_bodies():
				if body.is_in_group("players"):
					body.get_hit(rand_range(0.1,0.5))
			if ray_iterator >=2:
				$ray_sprite.visible = false
				ray_iterator = 0
				target = 0
				attack_ray_timer = rand_range(2,5)
				$ray_sprite/Area2D/Shape2D.disabled = true
		else:
			var distance = 10000
			for player in get_tree().get_nodes_in_group("players"):
				if (player.position - $ray_sprite.global_position).length() < distance:
					distance = (player.position - $ray_sprite.global_position).length()
					target = player
			if distance>1000:
				target = null
				attack_ray_timer = rand_range(2,4)
			else:
				$ray.play()
				$ray_sprite.visible = true
				$ray_sprite/Area2D/Shape2D.disabled = false
		
	attack_timer -= delta
	if attack_timer < 0:
		var angle = deg2rad(bullet_iterator*10)
		var facing = Vector2(cos(angle),sin(angle))
		var new_bullet = bullet_object.instance()
		new_bullet.position = $bullet_point1.global_position
		new_bullet.linear_velocity = facing*400
		new_bullet.rotation = angle
		get_parent().add_child(new_bullet)
		$bullet.play()
		new_bullet = bullet_object.instance()
		new_bullet.position = $bullet_point2.global_position
		new_bullet.linear_velocity = facing*400
		new_bullet.rotation = angle
		get_parent().add_child(new_bullet)
		bullet_iterator += 1
		if bullet_iterator>= 36:
			attack_timer = 3
			bullet_iterator = 0
			
