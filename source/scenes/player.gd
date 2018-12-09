extends Node2D

var bullet_object = load("res://scenes/bullet.tscn")

export var player_id =0

var hp = 200

const TURNING_SPEED     = PI
const MAX_SPEED         = 500
const MAX_REVERSE_SPEED = -300

var orientation      = 0.0
var acceleration     = 0.0
var facing           = Vector2 ( 0.0, 0.0 )
var thrust   = 0.0

var PI2      = PI*2

var is_playing = null
var shoot_timer = 0.0
var SHOOT_INTERVAL = 1.0
func _ready():
	is_playing = $tracks_1

func _physics_process(delta):
	process_input(delta)
	if shoot_timer >0:
		shoot_timer -= delta
	acceleration = lerp(acceleration, thrust, 0.1)
	facing       = Vector2 ( cos( orientation), sin( orientation ) ) 
	
	orientation = fmod(orientation + PI2, PI2)
	$body.frame = int(round( abs(orientation)/(PI*0.125) ))%16
	$body2.frame = int(round( abs(orientation)/(PI*0.125) ))%16
#	$turret.frame = int(round( abs(orientation)/(PI*0.125) ))%16

	position += facing * acceleration * delta
	$barrel.rotation = orientation
	$CollisionShape2D.rotation = orientation - PI*0.5
	if abs(thrust):
		if !is_playing.playing or is_playing.get_playback_position() >= is_playing.stream.get_length() - delta:
#			is_playing = get_node("tracks_" + str(randi()%2) )
			is_playing.play()
		var bodies = get_colliding_bodies()
		if bodies:
			if bodies[0].has_method("get_hit") :
				bodies[0].get_hit(0.1)
				hp -= 0.1
				$hp_bar.value = hp
	else:
		is_playing.stop()
	
func process_input(dt):
	thrust = 0
#	if Input.is_action_pressed("ui_left"):
	if Input.is_action_pressed("left_player_"+str(player_id)):
#		$body.frame = 2
		orientation -= TURNING_SPEED*dt

#	if Input.is_action_pressed("ui_right"):
	if Input.is_action_pressed("right_player_"+str(player_id)):
#		$body.frame = 1
		orientation += TURNING_SPEED*dt
		
#	if Input.is_action_pressed("ui_up"):
	if Input.is_action_pressed("up_player_"+str(player_id)):
		thrust = MAX_SPEED
			
	if Input.is_action_just_released("up_player_"+str(player_id)):
		is_playing.stop()
#		$body.frame = 0
		
	if Input.is_action_pressed("down_player_"+str(player_id)):
		thrust = MAX_REVERSE_SPEED
#		$body.frame = 3
		
	if Input.is_action_pressed("shoot_player_"+str(player_id)):
		if shoot_timer<=0:
			shoot_timer=SHOOT_INTERVAL
			spawn_bullet()
			$shoot.play()
			$barrel/fire/Particles2D.emitting = true
			$AnimationPlayer.play("fire")
		
func spawn_bullet():
	var new_bullet = bullet_object.instance()
	new_bullet.position = $barrel/fire.global_position
	new_bullet.linear_velocity = Vector2(cos(orientation), sin(orientation)) * 1000
	new_bullet.rotation = orientation
	get_parent().add_child(new_bullet)
	
func get_hit(value):
	hp -= value
	$hp_bar.value = hp

func _on_body_entered(body):
	if body.has_method("detonate"):
		body.detonate()
