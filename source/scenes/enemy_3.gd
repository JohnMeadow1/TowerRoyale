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
var death_timer = 1.0

func _ready():
	ai_timer = rand_range(0,REFRESH_AI)
	self.SPEED += rand_range(-10.0, 10.0)
	
	self.find_target()

func find_target():
	# Try to attack player, if can't - attack channeler
	ai_timer = rand_range(REFRESH_AI, REFRESH_AI*2)
	
	if find_player():
		pass
	else:
		find_channeler()
	
#	var target_name = "?"
#	if self.current_target and self.current_target.is_in_group("players"):
#		target_name = "PLAYER"
#	if self.current_target and self.current_target.is_in_group("channelers"):
#		target_name = "CHANNELER"
#
#	$target.text = target_name

func find_player():
	# Check if player is near, if it is - attack him
	for player in get_tree().get_nodes_in_group("players"):
		var curr_distance = Vector2(player.global_position - self.global_position).length()
		
		if ( curr_distance < self.PLAYER_ATTACK_DISTANCE ):
			self.current_target = player
			return true
	
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
		if death_timer<0:
			queue_free()

#	update()

func get_hit():
	$CollisionShape2D.disabled = true
	$agony.play()
	$Particles2D.emitting = true
	is_alive = false
	linear_velocity = Vector2()
	$body.rotation = rand_range(0,PI*2)
	

#func _draw():
#	draw_line(Vector2(0.0, 0.0), 100 * self.facing, Color(1.0, 0.0, 1.0), 3.0)	
