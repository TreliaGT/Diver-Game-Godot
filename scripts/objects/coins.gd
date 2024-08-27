extends Path2D

signal coin()

@onready var process = $PathFollow2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		coin.emit()
		queue_free()


func _ready() -> void:
	if(process):
		var random_float = randf() 
		process.progress_ratio = random_float
