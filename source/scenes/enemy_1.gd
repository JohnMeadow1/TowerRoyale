extends RigidBody2D

# "Speeder Enemy"
# - Run fast
# - Find nearest channeler if available
# - Attack player if near or player attack him
var hp = 5

var SPEED = 30
var FRAMES = 8

var PLAYER_ATTACK_DISTANCE = 100

var current_target = null
var facing = Vector2()
var jump_timer = 1.0

var REFRESH_AI = 1.0
var ai_timer = 0.0

var is_alive = true
var death_timer = 5.0
var attack_timer = 0.0

func _ready():
	self.SPEED += rand_range(-10.0, 10.0)
	
	self.find_target()

func find_target():
	# Try to attack player, if can't - attack channeler
	ai_timer = REFRESH_AI
	
	if globals.channelers_num == 0:
		find_player(true)
	else:
		if find_player(false):
			pass
		else:
			find_channeler()
	

func find_player(ignore_range):
	# Check if player is near, if it is - attack him
	var tmp_target = null
	var tmp_distance = null
	
	for player in get_tree().get_nodes_in_group("players"):
		var curr_distance = Vector2(player.global_position - self.global_position).length()
		
		if ignore_range:
			if !tmp_target or tmp_distance < curr_distance:
				tmp_target = player
				tmp_distance = curr_distance
		else:
			if curr_distance < self.PLAYER_ATTACK_DISTANCE:
				tmp_target = player
				tmp_distance = curr_distance
			
	if tmp_target:
		self.current_target = tmp_target
		return true
	else:
		return false

func find_channeler():
	# Find target to destroy
	
	# Lowest distance
	var lowest_distance = null
	var nearest_channeler = null
	
	for channeler in get_tree().get_nodes_in_group("channelers"):
		var curr_distance = Vector2(channeler.global_position - self.global_position).length()
		
		if ( lowest_distance == null or (curr_distance < lowest_distance and channeler.is_alive())):
			lowest_distance = curr_distance
			nearest_channeler = channeler
			
	# No channeler alive
	if !nearest_channeler:
		return
	
	# Set current target
	self.current_target = nearest_channeler
	return true

func channeler_destroyed():
	# Channeler destroyed, find new target if current invalid
	self.find_target()

func _physics_process(delta):
	if is_alive:
		# Refresh AI
		self.ai_timer -= delta
		if self.ai_timer <= 0.0:
			self.find_target()
			
		# Attack
		if attack_timer > 0:
			attack_timer -= delta
		else:
			var bodies = get_colliding_bodies()
			if bodies:
				if bodies[0].has_method("get_hit") && bodies[0].is_in_group("friendly"):
					attack_timer = 1.0
					bodies[0].get_hit(1)
					if randi()%100 < 2:
						get_node("attack_"+str(randi()%2)).play()
				elif current_target.is_in_group("chnnelers"):
					find_target()
					
		# Move enemy
		self.facing = Vector2(1.0, 0.0)
		if self.current_target:
			facing = Vector2 (self.current_target.global_position - self.global_position).normalized()
		
		position += facing * SPEED * delta
		
		# Update frame
		var orientation = fmod(Vector2(1.0, 0.0).angle_to(facing) + 2*PI, 2*PI)
		$shape/body.frame = int(round(abs(orientation)/(2*PI*(0.125))) + 6)%8
		
		# Jump
		self.jump_timer += 20.0 * delta
		$shape.position.y = abs(sin(self.jump_timer)) * 2.5 - 11
#		print(abs(sin(self.jump_timer)) * 2.5-11)
		
	else:
		death_timer -= delta
		$shape/dead.modulate.a = death_timer/5.0
		if death_timer < 0:
			queue_free()
		
	
func get_hit(value):
	hp -= value
	if hp <= 0:
		$shadow.visible = false
		is_alive        = false
		get_node("agony_"+str(randi()%2)).play()
		$Particles2D.emitting = true
		$shape.disabled = true
		$AnimationPlayer.play("die")
		linear_velocity = Vector2(0,0)
		$shape/dead.flip_h = randi()%2
		


