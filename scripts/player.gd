extends CharacterBody2D

const SPEED = 300.0

@onready var Anime = $AnimatedSprite2D
var is_moving_right = false
var is_moving_left = false

func _physics_process(_delta: float) -> void:
	# Reset velocity each frame
	velocity.x = 0
	# Handle movement via keyboard input
	if Input.is_action_pressed("ui_right"):
		velocity.x += SPEED
		Anime.play("Right")
	elif Input.is_action_pressed("ui_left"):
		velocity.x -= SPEED
		Anime.play("Left")
	
	# Handle movement via UI buttons
	if is_moving_right:
		velocity.x = SPEED
		Anime.play("Right")
	elif is_moving_left:
		velocity.x = -SPEED
		Anime.play("Left")

	# Stop animation if no movement
	if velocity.x == 0:
		Anime.stop()

	# Apply movement with move_and_slide
	move_and_slide()

# When right button is pressed
func _on_right_pressed() -> void:
	is_moving_right = true
	is_moving_left = false  # Ensure only one direction is active at a time

# When left button is pressed
func _on_left_pressed() -> void:
	is_moving_left = true
	is_moving_right = false

# When either button is released
func _on_released() -> void:
	is_moving_right = false
	is_moving_left = false
	velocity.x = 0
	Anime.stop()
