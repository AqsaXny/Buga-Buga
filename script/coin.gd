extends Area2D

@export var value := 1

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" or body.has_method("add_coin"):
		body.add_coin(value)
		call_deferred("queue_free")
