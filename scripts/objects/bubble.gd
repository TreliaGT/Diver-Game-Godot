extends Path2D

signal bubble()

@onready var process = $PathFollow2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		bubble.emit()
		queue_free()


func _ready() -> void:
	var random_float = randf() 
	process.progress_ratio = random_float
