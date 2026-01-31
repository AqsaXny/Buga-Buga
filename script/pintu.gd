extends Area2D

# Export file agar kita bisa memilih target scene lewat Inspector (sebelah kanan)
@export_file("*.tscn") var target_scene_path: String

func _ready():
	# Menghubungkan signal secara otomatis lewat kode
	# Ini sama saja dengan tab "Node" > "body_entered" connect
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D):
	# 1. Cek apakah yang masuk adalah Player
	if body.name == "Player":
		
		# 2. Cek variabel 'are_masks_unlocked' milik Player
		# Kita mengakses variabel yang ada di script Player tadi
		if body.are_masks_unlocked == true:
			print("Syarat terpenuhi! Pindah level...")
			call_deferred("pindah_level")
		else:
			print("Pintu Terkunci! Cari Coin/Topeng dulu.")
			# Di sini Anda bisa menambahkan efek suara "Gagal" atau teks UI

func pindah_level():
	# Cek apakah kita lupa mengisi target scene di Inspector
	if target_scene_path == "":
		print("ERROR: Target Scene belum diisi di Inspector Pintu!")
		return
		
	# Pindah Scene
	get_tree().change_scene_to_file(target_scene_path)