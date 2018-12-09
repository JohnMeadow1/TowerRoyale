extends Node2D

var SPAWN_TIME = 0.2
var R = 2000.0
	
var spawner_timer = 0.0

var enemy_array = [
	load("res://scenes/enemy_1.tscn"),
	load("res://scenes/enemy_2.tscn"),
	load("res://scenes/enemy_3.tscn")
]

var enemy_prob = [65, 20, 15]

func _ready():
	randomize()
#	$GridContainer/ViewportContainer2/Viewport2.world_2d = $GridContainer/ViewportContainer/Viewport.world_2d
#	globals.debug = $CanvasLayer/GUI/debug/RichText

func _process(delta):
	if globals.spawn_enemies:
		self.spawner_timer -= delta
	
	if self.spawner_timer <= 0.0:
		self.spawn_enemy()

func spawn_enemy():
	self.spawner_timer = SPAWN_TIME
	
	# Randomize position
	var random = rand_range(0, PI*2)
	var new_pos = Vector2(cos(random) * R, sin(random) * R)
	
	# Randomize enemies by probability
	var tmp_rand = randi() % 100
	var enemy_num = 0
	while (tmp_rand - enemy_prob[enemy_num]) > 0:
		tmp_rand -= enemy_prob[enemy_num]
		enemy_num += 1
	
	# Spawn group of EvilDogs
	var number = 1
	if enemy_num == 2:
		number = rand_range(5, 10)
	
	# Spawn enemy
	while(number > 0):
		var new_enemy = self.enemy_array[enemy_num].instance()
		new_enemy.position = new_pos + Vector2(rand_range(-50.0, 50.0), rand_range(-50.0, 50.0))
		$YSort.add_child(new_enemy)
		number -= 1

func _draw():
	pass