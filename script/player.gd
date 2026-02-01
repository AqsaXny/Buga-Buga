extends CharacterBody2D

var NORMAL_SPEED = 100.0
var DASH_SPEED = 400.0
var JUMP_VELOCITY = -270.0
var GRAVITY = 980.0

enum MaskType { NONE, BIRU, MERAH, HIJAU }
var current_mask: MaskType = MaskType.NONE
var are_masks_unlocked := false # Coin akan mengubah ini menjadi true

var jump_count := 0
var max_jumps := 1
var gravity_direction := 1 # 1 = Bawah, -1 = Atas (Untuk Topeng Biru)
var is_dashing := false

# --- NODES ---
@onready var sprite_no_mask: AnimatedSprite2D = $Sprite_NoMask
@onready var sprite_merah: AnimatedSprite2D = $Sprite_MaskMerah
@onready var sprite_biru: AnimatedSprite2D = $Sprite_MaskBiru
@onready var sprite_hijau: AnimatedSprite2D = $Sprite_MaskHijau
@onready var camera: Camera2D = $Camera

@export var ghost_scene: PackedScene
@onready var mati_point: Marker2D = $MatiAnim
var is_dead := false

func _ready():
	update_sprite_visibility()

func add_coin(jml: int):
	are_masks_unlocked = true
	
# INPUT KEYBOARD
func _input(event):
	if is_dead or not are_masks_unlocked:
		return

	# Biru
	if event.is_action_pressed("key_1") or (event is InputEventKey and event.keycode == KEY_1):
		change_mask(MaskType.BIRU)

	# Merah
	elif event.is_action_pressed("key_2") or (event is InputEventKey and event.keycode == KEY_2):
		change_mask(MaskType.MERAH)

	# Hijau
	elif event.is_action_pressed("key_3") or (event is InputEventKey and event.keycode == KEY_3):
		change_mask(MaskType.HIJAU)

	elif event is InputEventKey and event.pressed and event.keycode == KEY_0:
		if current_mask != MaskType.NONE:
			change_mask(MaskType.NONE)

func change_mask(new_mask: MaskType):
	current_mask = new_mask
	gravity_direction = 1
	up_direction = Vector2.UP
	camera.rotation = 0
	max_jumps = 1
	is_dashing = false
	rotation_degrees = 0 
	
	match current_mask:
		MaskType.BIRU:
			gravity_direction = -1
			up_direction = Vector2.DOWN
			camera.rotation_degrees = 180

			rotation_degrees = 180
			
		MaskType.HIJAU:
			max_jumps = 2
			
		MaskType.MERAH:
			pass

	update_sprite_visibility()

func update_sprite_visibility():
	sprite_no_mask.visible = false
	sprite_merah.visible = false
	sprite_biru.visible = false
	sprite_hijau.visible = false
	
	match current_mask:
		MaskType.NONE: sprite_no_mask.visible = true
		MaskType.MERAH: sprite_merah.visible = true
		MaskType.BIRU: sprite_biru.visible = true
		MaskType.HIJAU: sprite_hijau.visible = true

func get_active_sprite() -> AnimatedSprite2D:
	match current_mask:
		MaskType.MERAH: return sprite_merah
		MaskType.BIRU: return sprite_biru
		MaskType.HIJAU: return sprite_hijau
		_: return sprite_no_mask

func _physics_process(delta: float) -> void:
	if is_dead: return

	# GRAVITASI Topeng Biru
	if not is_on_floor():
		velocity.y += (GRAVITY * gravity_direction) * delta

	# LOMPAT Topeng Hijau
	if is_on_floor():
		jump_count = 0
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or jump_count < max_jumps:
			velocity.y = JUMP_VELOCITY * gravity_direction
			jump_count += 1
			get_active_sprite().play("jump")

	# Topeng Merah
	var current_speed = NORMAL_SPEED
	
	if current_mask == MaskType.MERAH and Input.is_action_pressed("ui_focus_next"):
		current_speed = DASH_SPEED
	# if current_mask == MaskType.MERAH: current_speed = DASH_SPEED

	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Kontrol Topeng Biru
	if current_mask == MaskType.BIRU:
		direction = direction
	
	if direction != 0:
		velocity.x = direction * current_speed
		var moving_left_world = direction < 0

		if current_mask == MaskType.BIRU:
			get_active_sprite().flip_h = not moving_left_world
		else:
			get_active_sprite().flip_h = moving_left_world


		if is_on_floor():
			get_active_sprite().play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		if is_on_floor():
			get_active_sprite().play("idle")

	move_and_slide()

# MATI & RESPAWN
func die():
	if is_dead: return
	is_dead = true
	
	sprite_no_mask.visible = false
	sprite_merah.visible = false
	sprite_biru.visible = false
	sprite_hijau.visible = false

	var ghost = ghost_scene.instantiate()
	get_parent().add_child(ghost)
	ghost.global_position = global_position
	
	get_tree().create_timer(1.2).timeout.connect(respawn)

func respawn():
	get_tree().reload_current_scene()
