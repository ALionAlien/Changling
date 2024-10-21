extends CharacterBody2D

func _physics_process(delta):
	var gravity = 270
	velocity.y += gravity
	move_and_slide()
