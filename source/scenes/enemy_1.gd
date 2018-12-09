extends Node2D

# "Speeder Enemy"
# - Run fast
# - Find nearest channeler if available
# - Attack player if near or player attack him

var SPEED = 100
var FRAMES = 8

var PLAYER_ATTACK_DISTANCE = 50

var current_target = null
var facing = Vector2()
var ai_timer = 0.0
var jump_timer = 1.0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	self.find_target()

func find_target():
	# Try to attack player, if can't - attack channeler
	ai_timer = 1.5
	
	if find_player():
		return 
		
	find_channeler()
	

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
	var lowest_distance = 0
	var nearest_channeler = null
	
	for channeler in get_tree().get_nodes_in_group("channelers"):
		var curr_distance = Vector2(channeler.global_position - self.global_position).length()
		
		if ( curr_distance < lowest_distance and channeler.is_alive() ):
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
	self.find_channeler()

func _physics_process(delta):
	# Move enemy
	self.facing = Vector2(1.0, 0.0)
	if self.current_target:
		facing = Vector2 (self.current_target.global_position - self.global_position).normalized()
	
	position += facing * SPEED * delta
	
	# Update frame
	var orientation = fmod(Vector2(1.0, 0.0).angle_to(facing) + 2*PI, 2*PI)
	$body.frame = int(round(abs(orientation)/(2*PI*(0.125))) + 6)%8
	
	self.jump_timer += 20.0 * delta
	$body.position.y = abs(sin(self.jump_timer)) * 10.0
	
	update()

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	self.ai_timer -= delta

	# Refresh AI
	if self.ai_timer <= 0.0:
		self.find_target()
		
func _draw():
	draw_line(Vector2(0.0, 0.0), 100 * self.facing, Color(1.0, 0.0, 1.0), 3.0)	
	
	var target_name = "?"
	if self.current_target and self.current_target.is_in_group("players"):
		target_name = "PLAYER"
	if self.current_target and self.current_target.is_in_group("channelers"):
		target_name = "CHANNELER"
		
	var label = Label.new()
	label.text = target_name
	add_child(label)
