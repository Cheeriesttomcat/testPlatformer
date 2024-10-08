#**************************************************************************************
#
#	Player Stuff
#
#	Author CheeriestTomcat
#	Created 6/24/24
#   Last Modified 10/2/2024
#
#
#**************************************************************************************
extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const BOUNCE_VELOCITY = -200.0
#const BOING_TIME = .5
var Slide = 1
#Set hurt stuff
const PAINTIME = .5
const OWW = 300
var pain = false
#ladder checker
var on_ladder := false
var climbin := false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
# Player health
#var health = 10 
func _physics_process(delta):
	#Deal with character impact
	if pain == true:
		$PainTimer.one_shot = true
		$PainTimer.start(PAINTIME)
		pain = false
		climbin = false
		anim.play("hurt")

	# Add the gravity.
	if !climbin and !is_on_floor():
		velocity.y += gravity * delta

	if $PainTimer.is_stopped():
		# Handle jump.
		if (Input.is_action_pressed("ui_accept") and is_on_floor()) or (Input.is_action_just_pressed("ui_accept") and climbin):
			#get_node("AnimatedSprite2D").animation != "hurt":
			anim.play("jump")
			velocity.y = JUMP_VELOCITY
			climbin = false
			$Boing.play()
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction = Input.get_axis("ui_left", "ui_right")
		var down = Input.is_action_pressed("ui_down")
		var up = Input.is_action_pressed("ui_up")
		if direction == -1:
			get_node("AnimatedSprite2D").flip_h = true
		elif direction == 1:
			get_node("AnimatedSprite2D").flip_h = false
		if on_ladder and (up or down) and !Input.is_action_just_pressed("ui_accept"):
			velocity.x = 0
			climbin = true
			anim.play("climb")
			if up:
				velocity.y = -SPEED * .5
			elif down:
				velocity.y = SPEED * .5
				#anim.play_backwards("climb")
		elif direction:
			#if get_node("AnimatedSprite2D").animation != "hurt":
			if down and is_on_floor():
				velocity.x = move_toward(velocity.x, 0, (SPEED * Slide))
				anim.play("crouch")
			else:
				velocity.x = direction * SPEED
				if velocity.y == 0:
					anim.play("run")
				climbin = false
#			else:
#				velocity.x = move_toward(velocity.x, 0, SPEED)
#				anim.play("crouch")
		elif climbin:
			velocity.y = 0
			anim.pause()
		else:
			#if get_node("AnimatedSprite2D").animation != "hurt":
			velocity.x = move_toward(velocity.x, 0, (SPEED * Slide))
			if velocity.y == 0 and is_on_floor():
				if !down:
			#		if get_node("AnimatedSprite2D").animation != "hurt":
					anim.play("idle")
				else:
					anim.play("crouch")
		if (velocity.y > 0) and !climbin:
		# get_node("AnimatedSprite2D").animation != "hurt":
			anim.play("fall")
	move_and_slide()
	
	#Death Script
	if Game.PlayerHp <= 0:
		queue_free()
		get_tree().change_scene_to_file("res://main.tscn")
		

#Ladder Checker
func _on_ladder_checker_body_entered(body):
	on_ladder = true
	#print("On ladder")

func _on_ladder_checker_body_exited(body):
	on_ladder = false
	#print("Off ladder")


func _on_visible_on_screen_notifier_2d_screen_exited():
	Game.PlayerHp = 0
#		queue_free()
#		get_tree().change_scene_to_file("res://main.tscn")
