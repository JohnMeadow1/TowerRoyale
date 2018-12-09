extends RigidBody2D

# "Speeder Enemy"
# - Run fast
# - Find nearest channeler if available
# - Attack player if near or player attack him

var SPEED = 250
var FRAMES = 8

var PLAYER_ATTACK_DISTANCE = 400.0

var current_target = null
var facing = Vector2()
var jump_timer = 0.0

var REFRESH_AI = 1.0
var ai_timer = 0.0
var is_alive  = true
var death_timer = 3.0
var attack_timer = 0.0

func _ready():
	ai_timer = rand_range(0,REFRESH_AI)
	self.SPEED += rand_range(-10.0, 10.0)
	self.jump_timer += rand_range(0.0, 25.0)
	
	self.find_target()

func find_target():
	# Try to attack player, if can't - attack channeler
	ai_timer = rand_range(REFRESH_AI, REFRESH_AI*2)
	
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
	# Refresh AI
	if is_alive:
		self.ai_timer -= delta
	
		if self.ai_timer <= 0.0:
			self.find_target()
		if attack_timer>0:
			attack_timer -= delta
		else:
			var bodies = get_colliding_bodies()
			if bodies:
				if bodies[0].has_method("get_hit") && bodies[0].is_in_group("friendly"):
					ai_timer = 0.5
					bodies[0].get_hit(0.05)
					if randi()%100 < 2:
						get_node("attack_"+str(randi()%2)).play()

		# Move enemy
		self.facing = Vector2(1.0, 0.0)
		if self.current_target:
			facing = Vector2 (self.current_target.global_position - self.global_position).normalized()
		
		position += facing * SPEED * delta
		
		# Update frame
		var orientation = fmod(Vector2(1.0, 0.0).angle_to(facing) + 2*PI, 2*PI)
		$body.frame = int(round(abs(orientation)/(2*PI*(0.125))) + 6)%8
		$CollisionShape2D.rotation = orientation + PI * 0.5
		# Jump
		self.jump_timer += 25.0 * delta
		$body.position.y = abs(sin(self.jump_timer)) * 8.0
	else:
		death_timer -= delta
		$dead.modulate.a = death_timer/5.0
		if death_timer < 0:
			queue_free()


func get_hit(value):
	$CollisionShape2D.disabled = true
	$agony.play()
	$Particles2D.emitting = true
	is_alive = false
	linear_velocity = Vector2()
	$body.visible = false
	$dead.visible = true
	$dead.flip_h = randi()%2
#	$body.rotation = rand_range(0,PI*2)



func _on_body_entered(body):
	if attack_timer<=0 :
		body.get_hit(0.5)
		attack_timer = 0.5
