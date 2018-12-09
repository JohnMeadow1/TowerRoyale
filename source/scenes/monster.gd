extends Node2D

var boss_object = preload("res://scenes/boss.tscn")

enum {
	MONSTER_GOOD,
	MONSTER_EVIL
}

var life = 500.0
var rage = 0.0
var state = MONSTER_GOOD
var ai_timer = 0.0

var RAGE_MAX = 200.0
var AI_REFRESH = 5.0

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	$rage_bar.visible = true
	$life_bar.visible = false
	
#
#	MONSTER_GOOD
#
func set_monster_emerge(value):
	# Set emerge of the monster (0 - 153)
#	if not ( 0 <= value and value <= 153 ):
#		print("Wrong value in set_monster_emerge(0-100)")
		
	var height = int((value/153.0) * 153.0)
	#$Sprite.set_region_rect(Rect2(min(floor(4 * 120 * (value/153.0)), 360), 0, 120, height))
	$Sprite.set_region_rect(Rect2((int(floor((value / 153.0) * 4))%4) * 120, 0, 120, height))
	$Sprite.set_offset(Vector2(-50, -height))
#	print(Rect2(floor((value/153.0)*4)*120, 0, 120, height))
	
func calm_monster(value):
	if self.rage > 0:
		rage -= value

func handle_monster_rage(delta):
	# Increase monster rage
	self.rage += 14.0 * delta
	
	# Calm monster from channelers
	for ch in get_tree().get_nodes_in_group("channelers"):
		if ch.is_alive() && ch.ray_timer<=0:
			self.calm_monster(delta * 5.5)
	
	# Monster full rage activated
	if self.rage > self.RAGE_MAX:
		for ch in get_tree().get_nodes_in_group("channelers"):
			ch.hp = -1
		self.activate_monster()
	
	self.rage = min(self.rage, self.RAGE_MAX)
	set_monster_emerge(int((self.rage / self.RAGE_MAX) * 152.9))
#
#	MONSTER_EVIl
#
func monster_ai():
	self.ai_timer = AI_REFRESH
	
	pass
	
#
#	TRANSFORM
#
func activate_monster():
	# MONSTER_GOOD --> MONSTER_EVIL
	self.state = MONSTER_EVIL
	$rage_bar.visible = false
	
	$life_bar.value = self.life
	$life_bar.visible = true
	
	# Detroy void
	get_node("../void").void_vanish()
	var boss = boss_object.instance()
	boss.position = global_position+Vector2(50,-100)
	# Stop spawning monster
	globals.spawn_enemies = false
	get_node("../../YSort").add_child(boss)
	
func _process(delta):
	if self.state == MONSTER_GOOD:	
		self.handle_monster_rage(delta)
		$rage_bar.value = self.rage
		
	elif self.state == MONSTER_EVIL:
		self.monster_ai()