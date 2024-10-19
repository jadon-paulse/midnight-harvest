extends CharacterBody2D


const SPEED = 300.0
const GRAVITY : int = 4200
const JUMP_VELOCITY : int = -1300


func _physics_process(delta):
	velocity.y += GRAVITY * delta 
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle_movement")
		else:	
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
			else:
				$AnimatedSprite2D.play("idle_movement")
	else: 
		$AnimatedSprite2D.play("idle_movement")
		
	move_and_slide()
