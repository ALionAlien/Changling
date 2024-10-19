extends CharacterBody2D

func _physics_process(delta):
	if Input.is_action_pressed("morph"):
		pass
	move_and_slide()
