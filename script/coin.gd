extends Area2D

@export var value := 1

func _on_body_entered(body: Node2D) -> void:
	# Cek apakah body adalah Player
	if body.name == "Player" or body.has_method("add_coin"):
		# Panggil fungsi add_coin di player
		body.add_coin(value)
		
		# Hapus coin
		call_deferred("queue_free")
