extends CharacterBody2D

#the last thing working on is seperating arm animations. I got to left arm ledge grab in aesprite

enum CHARACTER_STATE{IDLE, WALK, RUN, AIR, WALLGRAB_RIGHT, WALLGRAB_LEFT, AIM,THROW,PUSH}

#character traits
var HasHead : bool = true
var facing_right : bool = true

#jumping stuff
var jump_velocity : float = -400.0
var jump_available:bool = false
var coyote_duration : float = 0.2
var jump_buffer:bool = false
@export var jump_buffer_duration : float = 0.2

#movment constants
#const walk_speed : float = 250.0
#const run_speed : float = 320.0
const walk_speed : float = 248.5
const run_speed : float = 320.0
var walk_cycle : int = 0
var ledge_drop_pushoff : int = 80
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var gravity = 270
@export_range(0,1) var acceleration = 0.1
@export_range(0,1) var decceleration = 0.1

#nodes
@onready var animation_player = $PlayerAnimation
@onready var walk_cycle_clock = $WalkCycleStep
@onready var coyote_timer : Timer = $CoyoteTimer
@onready var jump_buffer_timer : Timer = $JumpBuffer

var character_state:int = CHARACTER_STATE.IDLE:
	set(new_value):
		exit_state(character_state)
		character_state = new_value
		enter_state(character_state)
	get:
		return character_state

#func _ready():
	#animation_player.play("IdleRight")

func _physics_process(delta):
	animation_process()
	#sfvo
	
	floor_constant_speed = true
	set_floor_snap_length(8.0)
	
	$LedgeGrabRight.disabled = (not Input.is_action_pressed("right") and character_state != CHARACTER_STATE.WALLGRAB_RIGHT) or Input.is_action_pressed("down") or character_state not in [CHARACTER_STATE.AIR, CHARACTER_STATE.WALLGRAB_RIGHT] or velocity.y < 0 or (character_state != CHARACTER_STATE.WALLGRAB_RIGHT and $TopCheck.is_colliding())
	$LedgeGrabLeft.disabled = (not Input.is_action_pressed("left") and character_state != CHARACTER_STATE.WALLGRAB_LEFT) or Input.is_action_pressed("down") or character_state not in [CHARACTER_STATE.AIR, CHARACTER_STATE.WALLGRAB_LEFT] or velocity.y < 0 or (character_state != CHARACTER_STATE.WALLGRAB_LEFT and $TopCheck.is_colliding())
	
	if character_state == CHARACTER_STATE.AIR:
		check_ledge_grab()
	
	if is_on_floor():
		if not character_state in [CHARACTER_STATE.WALLGRAB_RIGHT, CHARACTER_STATE.WALLGRAB_LEFT, CHARACTER_STATE.THROW]:
			if (abs(velocity.x) > 0 && abs(velocity.x) < (run_speed - 80.0)):
				character_state = CHARACTER_STATE.WALK
			elif abs(velocity.x) >= (run_speed - 80.0):
				character_state = CHARACTER_STATE.RUN
			#elif Input.is_action_pressed("down") && HasHead:
				#if character_state != CHARACTER_STATE.AIM:
					#character_state = CHARACTER_STATE.AIM
			else:
				character_state = CHARACTER_STATE.IDLE
		elif character_state == CHARACTER_STATE.WALLGRAB_LEFT:
			if not Input.is_action_pressed("right"):
				velocity = Vector2(-1,0)
			if Input.is_action_just_pressed("down"):
				velocity = Vector2(ledge_drop_pushoff,0)
		elif character_state == CHARACTER_STATE.WALLGRAB_RIGHT:
			if not Input.is_action_pressed("left"):
				velocity = Vector2(1,0)
			if Input.is_action_just_pressed("down"):
				velocity = Vector2((ledge_drop_pushoff*-1),0)
		#velocity.y += 2 * delta
		jump_available = true
		coyote_timer.stop()
		if jump_buffer:
			idle_jump()
			jump_buffer = false
	else:
		if jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start(coyote_duration)
		character_state = CHARACTER_STATE.AIR
		if Input.is_action_pressed("jump") && velocity.y < -264:
			velocity.y += (gravity-410) * delta
		else:
			velocity.y += (gravity+410) * delta
			#sjbv
	
	if not character_state in [CHARACTER_STATE.AIM,CHARACTER_STATE.THROW]:
		if Input.is_action_just_pressed("jump"):
			if jump_available:
				idle_jump()
			else:
				jump_buffer = true
				jump_buffer_timer.start(jump_buffer_duration)
		
		var direction = Input.get_axis("left", "right")
		if direction:
			if Input.is_action_pressed("sprint"):
				velocity.x = move_toward(velocity.x, direction * run_speed, run_speed * acceleration)
			else:
				velocity.x = move_toward(velocity.x, direction * walk_speed, walk_speed * acceleration)
		else:
			velocity.x = move_toward(velocity.x, 0, walk_speed * decceleration)
		if velocity.x > 0:
			facing_right = true
		elif velocity.x < 0:
			facing_right = false
	
	move_and_slide()


func animation_process():
	match character_state:
		CHARACTER_STATE.WALK:
			if facing_right:
				animation_player.play("WalkRight")
			else:
				animation_player.play("WalkLeft")
			animation_player.seek(walk_cycle,false,false)
		CHARACTER_STATE.RUN:
			if facing_right:
				animation_player.play("RunRight")
			else:
				animation_player.play("RunLeft")
			animation_player.seek(walk_cycle,false,false)
		CHARACTER_STATE.AIR:
			var jump_frame : int = 0
			if (velocity.y < -300):
				jump_frame = 0
			elif (velocity.y >= -300) && (velocity.y < -200):
				jump_frame = 1
			elif (velocity.y >= -200) && (velocity.y < -100):
				jump_frame = 2
			elif (velocity.y >= -100) && (velocity.y < 0):
				jump_frame = 3
			elif (velocity.y >= 0) && (velocity.y < 100):
				jump_frame = 4
			elif (velocity.y >= 100) && (velocity.y < 200):
				jump_frame = 5
			else:
				jump_frame = 6
			
			if facing_right:
				animation_player.play("JumpRight")
				animation_player.seek(jump_frame,false,false)
			else:
				animation_player.play("JumpLeft")
				animation_player.seek(jump_frame,false,false)

func idle_jump()->void:
	velocity.y = jump_velocity
	jump_available = false

func exit_state(STATE:int)->void:
	#stop walk cycle
	if STATE not in [CHARACTER_STATE.WALK,CHARACTER_STATE.RUN]:
		if character_state not in [CHARACTER_STATE.WALK,CHARACTER_STATE.RUN]:
			walk_cycle_clock.stop()
	
	match STATE:
		CHARACTER_STATE.IDLE:
			pass

func enter_state(STATE:int)->void:
	match STATE:
		CHARACTER_STATE.IDLE:
			if facing_right:
				animation_player.play("IdleRight")
			else:
				animation_player.play("IdleLeft")
		CHARACTER_STATE.AIM:
			if facing_right:
				animation_player.play("AimRight")
			else:
				animation_player.play("AimLeft")
		CHARACTER_STATE.WALK:
			if walk_cycle_clock.is_stopped():
				walk_cycle = 0
				walk_cycle_clock.start()
		CHARACTER_STATE.RUN:
			if walk_cycle_clock.is_stopped():
				walk_cycle = 0
				walk_cycle_clock.start()
		CHARACTER_STATE.WALLGRAB_LEFT:
			animation_player.play("GrabLeft")
			facing_right = false
		CHARACTER_STATE.WALLGRAB_RIGHT:
			animation_player.play("GrabRight")
			facing_right = true
		CHARACTER_STATE.THROW:
			$Throw.start()
			if facing_right:
				animation_player.play("ThrowRight")
			else:
				animation_player.play("ThrowLeft")

func _on_coyote_timer_timeout():
	jump_available = false

func _on_jump_buffer_timeout():
	jump_buffer = false


func check_ledge_grab()->void:
	if $WallcheckRight.is_colliding() and not $Floorcheck.is_colliding() and velocity.y == 0:
		character_state = CHARACTER_STATE.WALLGRAB_RIGHT
	if $WallcheckLeft.is_colliding() and not $Floorcheck.is_colliding() and velocity.y == 0:
		character_state = CHARACTER_STATE.WALLGRAB_LEFT


func _on_walk_cycle_step_timeout():
	if walk_cycle < 8:
		walk_cycle += 1
	else:
		walk_cycle = 0
	
func _on_throw_timeout():
	pass
	#HasHead = false
	#var head_instance = head_scene.instantiate()
	#head_instance.global_position = Vector2(position.x,position.y-20)
	#if facing_right:
		#head_instance.velocity.x = 300
	#else:
		#head_instance.velocity.x = -300
	#head_instance.velocity.y = -300
	#get_parent().add_child(head_instance)
	#character_state = CHARACTER_STATE.IDLE
