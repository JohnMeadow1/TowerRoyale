extends Node2D
var velocity = Vector2( 0.0, 0.0 )
var thrust   = 0.0
var speed    = 0.0


const TURNING_SPEED = PI
const MAX_SPEED = 500
const MAX_REVERSE_SPEED = -100
var orientation      = 0.0
var acceleration     = 0.0
var facing           = Vector2 ( 0.0, 0.0 )
var drag             = 0.0
var skid_size_front  = 0.0
var skid_size_back   = 0.0
var PI2              = PI*2

var is_playing = null

func _ready():
	is_playing = $tracks_1

func _physics_process(delta):
	process_input(delta)
	
	acceleration = lerp(acceleration, thrust, 0.1)
	facing       = Vector2 ( cos( orientation), sin( orientation ) ) 
	
	orientation = fmod(orientation + PI2, PI2)
	$body.frame = int(round( abs(orientation)/(PI*0.125) ))%16
	$body2.frame = int(round( abs(orientation)/(PI*0.125) ))%16
#	$turret.frame = int(round( abs(orientation)/(PI*0.125) ))%16

	position += facing * acceleration * delta
	$barrel.rotation = orientation
	if abs(thrust):
		if !is_playing.playing or is_playing.get_playback_position() >= is_playing.stream.get_length() - delta:
#			is_playing = get_node("tracks_" + str(randi()%2) )
			is_playing.play()
	else:
		is_playing.stop()
	
func process_input(dt):
	thrust = 0
	if Input.is_action_pressed("ui_left"):
#		$body.frame = 2
		orientation -= TURNING_SPEED*dt

	if Input.is_action_pressed("ui_right"):
#		$body.frame = 1
		orientation += TURNING_SPEED*dt
		
	if Input.is_action_pressed("ui_up"):
		thrust = MAX_SPEED
			
	if Input.is_action_just_released("ui_up"):
		is_playing.stop()
#		$body.frame = 0
		
	if Input.is_action_pressed("ui_down"):
		thrust = MAX_REVERSE_SPEED
#		$body.frame = 3
		
	if Input.is_action_pressed("ui_select"):
		if !$shoot.playing:
			$shoot.play()
			$barrel/fire/Particles2D.emitting = true
			$AnimationPlayer.play("fire")
		

#func _draw():
#	draw_vector(Vector2(), facing  * 100, Color(1,0,1), 3)
	
func draw_vector( origin, vector, color, arrow_size ):
	if vector.length_squared() > 1:
		var points    = []
		var direction = vector.normalized()
		vector += origin
		vector -= direction * arrow_size*2
		points.push_back( vector + direction * arrow_size*2  )
		points.push_back( vector + direction.rotated(  PI / 1.5 ) * arrow_size * 2 )
		points.push_back( vector + direction.rotated( -PI / 1.5 ) * arrow_size * 2 )
		draw_polygon( PoolVector2Array( points ), PoolColorArray( [color] ) )
		vector -= direction * arrow_size * 1
		draw_line( origin, vector, color, arrow_size )