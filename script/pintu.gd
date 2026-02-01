extends Area2D

@export_file("*.tscn") var target_scene_path: String

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	if body.name == "Player":
		if body.are_masks_unlocked == true:
			print("Syarat terpenuhi! Pindah level...")
			call_deferred("pindah_level")
		else:
			print("Pintu Terkunci! Cari Coin/Topeng dulu.")
			# Di sini Anda bisa menambahkan efek suara "Gagal" atau teks UI

func pindah_level():
	if target_scene_path == "":
		print("ERROR: Target Scene belum diisi di Inspector Pintu!")
		return
		
	get_tree().change_scene_to_file(target_scene_path)