extends Node2D

signal coin()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		coin.emit()
		queue_free()
