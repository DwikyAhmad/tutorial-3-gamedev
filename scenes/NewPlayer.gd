extends CharacterBody2D

# Exported variables
@export var gravity: float = 900.0
@export var walk_speed: int = 300
@export var jump_speed: int = -400
@export var double_jump_speed: int = -300
@export var dash_speed: int = 1000
@export var dash_duration: float = 0.2
@export var crouch_speed: int = 150
@export var crouch_height: float = 0.5
@export var attack_force: int = 800

var can_double_jump: bool = false
var is_crouching: bool = false
var is_walking: bool = false
var is_jumping: bool = false
var is_attacking: bool = false
var attack_timer: float = 0.0
var attack_duration: float = 1.0
var is_dashing: bool = false
var dash_timer: float = 0.0
var last_press_time: float = 0.0
var double_tap_threshold: float = 0.2
var last_press_direction: int = 0

@onready var anim_player = $AnimatedSprite2D
@onready var crouch_collision = $CrouchShape2D
@onready var dash_sfx = $DashSfx
@onready var attack_area = $AttackArea
@onready var collision_shape = $CollisionShape2D
@onready var sprite = $Sprite2D


func _ready():
	# Pastikan attack_area dinonaktifkan saat awal
	attack_area.monitoring = false
	attack_area.monitorable = false


func _physics_process(delta):
	# Update attack timer
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			# Nonaktifkan area serangan saat selesai
			attack_area.monitoring = false
			attack_area.monitorable = false

	# Handle attack input
	if Input.is_action_just_pressed("ui_select") and not is_attacking:  # ui_select adalah spasi
		is_attacking = true
		attack_timer = attack_duration
		# Aktifkan area serangan
		attack_area.monitoring = true
		attack_area.monitorable = true
		# Panggil fungsi untuk mendeteksi dan mendorong objek

	change_sprite()

	velocity.y += delta * gravity

	# Handle crouching
	if Input.is_action_just_pressed("ui_down"):
		crouch()

	if Input.is_action_just_released("ui_down"):
		crouch()

	# Modifikasi kecepatan jalan saat jongkok
	var current_walk_speed = crouch_speed if is_crouching else walk_speed

	# Check if the player is on the floor
	if is_on_floor():
		can_double_jump = true  # Reset double jump when on the floor

	# Handle jumping
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			is_jumping = true
			velocity.y = jump_speed
		elif can_double_jump:
			is_jumping = true
			velocity.y = double_jump_speed
			can_double_jump = false  # Disable double jump until landing

	if Input.is_action_just_released("ui_up"):
		is_jumping = false

	# Handle dashing
	if !is_dashing:
		# Cek double-tap kiri
		if Input.is_action_just_pressed("ui_left"):
			if (
				last_press_direction == -1
				and (Time.get_ticks_msec() - last_press_time) / 1000.0 < double_tap_threshold
			):
				is_dashing = true
				dash_timer = dash_duration
				velocity.x = -dash_speed
			last_press_time = Time.get_ticks_msec()
			last_press_direction = -1

		# Cek double-tap kanan
		elif Input.is_action_just_pressed("ui_right"):
			if (
				last_press_direction == 1
				and (Time.get_ticks_msec() - last_press_time) / 1000.0 < double_tap_threshold
			):
				is_dashing = true
				dash_timer = dash_duration
				velocity.x = dash_speed
			last_press_time = Time.get_ticks_msec()
			last_press_direction = 1

	# Update dash timer
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	# Handle walking
	if !is_dashing:
		if Input.is_action_pressed("ui_left"):
			velocity.x = -current_walk_speed
			is_walking = true
		elif Input.is_action_pressed("ui_right"):
			velocity.x = current_walk_speed
			is_walking = true
		else:
			velocity.x = 0
			is_walking = false
	# "move_and_slide" already takes delta time into account.
	move_and_slide()


func crouch():
	if !is_crouching:
		is_crouching = true
		collision_shape.disabled = true
		crouch_collision.disabled = false
	else:
		is_crouching = false
		collision_shape.disabled = false
		crouch_collision.disabled = true


func change_sprite():
	if is_attacking:
		anim_player.play("attack")
	elif is_jumping:
		anim_player.play("jump")
	elif is_crouching:
		anim_player.play("crouch")
	elif is_dashing:
		dash_sfx.play()
		anim_player.play("dash")
	elif is_walking:
		anim_player.play("walk")

	# else:
	# # if !is_walking and !is_jumping and !is_crouching and !is_dashing:
	# #     sprite.texture = sprite_standing

	else:
		anim_player.play("default")

	if last_press_direction == 1:
		anim_player.flip_h = false
	elif last_press_direction == -1:
		anim_player.flip_h = true


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		if body.has_method("hit"):
			body.hit(Vector2.RIGHT * attack_force)
		else:
			body.apply_central_impulse(Vector2.RIGHT * attack_force)
