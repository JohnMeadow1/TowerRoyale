extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var VANISH_TIME = 2.0

var vanish_timer = 0.0
var vanishing = false

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass
	
func void_vanish():
	self.vanish_timer = VANISH_TIME
	self.vanishing = true
	$void_mask.enabled = false

func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	if self.vanishing:
		vanish_timer -= delta
		vanish_timer = max(0.0, vanish_timer)
		
#		var proc = ( max(self.vanish_timer + abs(sin(self.vanish_timer)), 0) / self.VANISH_TIME )
		var proc = ( vanish_timer / self.VANISH_TIME )
#		print(proc)
		self.set_scale(Vector2(proc * 4.0, proc * 4.0))
		
		if vanish_timer <= 0.0:
			queue_free()
			$"../monster".queue_free()
			self.vanishing = false
	
