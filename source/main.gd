extends Node2D

var SPAWN_TIME_RUNNER = 5.0
var R = 300.0
	
var spawner_timer = 0.0

var enemy_object = load("res://scenes/enemy_1.tscn")

func _ready():
	globals.debug = $CanvasLayer/GUI/debug/RichText

func _process(delta):
	self.spawner_timer -= delta
	
	if self.spawner_timer <= 0.0:
		self.spawn_enemy()

func spawn_enemy():
	self.spawner_timer = SPAWN_TIME_RUNNER
	
	var random = rand_range(0, PI*2)
	var new_pos = Vector2(cos(random) * R, sin(random) * R)
	
	var new_enemy = self.enemy_object.instance()
	new_enemy.position = new_pos
	$YSort.add_child(new_enemy)
	
	print("Enemy spawned: ", new_pos)

func _draw():
	pass