extends Node2D

var speed: float = 0.5
var is_going_forward: bool = true
signal endgame()

@onready var path = $Path2D/PathFollow2D
@onready var sprite = $Path2D/PathFollow2D/Sharksprite/Sprite2D

func _ready() -> void:
	# Start at the beginning of the path
	path.progress_ratio = 0
	# Start moving along the path
	set_process(true)

func _process(delta: float) -> void:
	# Move along the path
	if is_going_forward:
		path.progress_ratio += speed * delta
		if path.progress_ratio  >=  0.9:
			# When reaching the end, flip direction
			is_going_forward = false
			sprite.flip_h = false  # Flip the sprite horizontally
	else:
		path.progress_ratio -= speed * delta
		if path.progress_ratio <= 0.1:
			# When reaching the start, flip direction
			is_going_forward = true
			sprite.flip_h = true  # Restore the original sprite direction


func _on_sharksprite_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		endgame.emit()
		
