extends Node2D

signal bubble()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		bubble.emit()
		queue_free()
