extends RigidBody2D

var is_bullet = true

func _ready():
	$Sprite.visible = true

func _physics_process(delta):
	var bodies = get_colliding_bodies()
	if bodies:
		explode()
		if bodies[0].has_method("get_hit") :
			bodies[0].get_hit(randi()%3+1)

func explode():
	$CollisionShape2D.disabled = true
	linear_velocity = Vector2()
	$AnimationPlayer.play("explode")

func _on_animation_finished(anim_name):
	queue_free()
