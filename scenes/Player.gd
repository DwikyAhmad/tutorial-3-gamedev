extends CharacterBody2D

@export var gravity = 900.0
@export var walk_speed = 300
@export var jump_speed = -400
@export var double_jump_speed = -300
@export var dash_speed = 1000
@export var dash_duration = 0.2
@export var crouch_speed = 150
@export var crouch_height = 0.5

@onready var collisionShape = $CollisionShape2D
@onready var sprite = $Sprite2D

var can_double_jump = false
var is_crouching = false
var is_walking = false
var is_jumping = false

# Variabel untuk dash
var is_dashing = false
var dash_timer = 0.0
var last_press_time = 0.0
var double_tap_threshold = 0.2 # Waktu maksimum antara double-tap (dalam detik)
var last_press_direction = 0 # 1 untuk kanan, -1 untuk kiri

var standingCshape = preload("res://resources/PlayerStanding.tres")
var crouchingCshape = preload("res://resources/PlayerCrouch.tres")

var spriteStanding = preload("res://assets/kenney_platformercharacters/PNG/Adventurer/Poses/adventurer_idle.png")
var spriteWalking = preload("res://assets/kenney_platformercharacters/PNG/Adventurer/Poses/adventurer_walk2.png")
var spriteJumping = preload("res://assets/kenney_platformercharacters/PNG/Adventurer/Poses/adventurer_jump.png")
var spriteCrouch = preload("res://assets/kenney_platformercharacters/PNG/Adventurer/Poses/adventurer_duck.png")
var spriteSlide = preload("res://assets/kenney_platformercharacters/PNG/Adventurer/Poses/adventurer_slide.png")

func _physics_process(delta):
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
        can_double_jump = true # Reset double jump when on the floor

    # Handle jumping
    if Input.is_action_just_pressed('ui_up'):
        if is_on_floor():
            is_jumping = true
            velocity.y = jump_speed
        elif can_double_jump:
            is_jumping = true
            velocity.y = double_jump_speed
            can_double_jump = false # Disable double jump until landing

    if Input.is_action_just_released('ui_up'):
        is_jumping = false

    # Handle dashing
    if !is_dashing:
        # Cek double-tap kiri
        if Input.is_action_just_pressed("ui_left"):
            if last_press_direction == -1 and (Time.get_ticks_msec() - last_press_time) / 1000.0 < double_tap_threshold:
                is_dashing = true
                dash_timer = dash_duration
                velocity.x = -dash_speed
            last_press_time = Time.get_ticks_msec()
            last_press_direction = -1
            
        # Cek double-tap kanan
        elif Input.is_action_just_pressed("ui_right"):
            if last_press_direction == 1 and (Time.get_ticks_msec() - last_press_time) / 1000.0 < double_tap_threshold:
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
        collisionShape.shape = crouchingCshape
        collisionShape.position.y = 22
    else:
        is_crouching = false
        collisionShape.shape = standingCshape
        collisionShape.position.y = 8

func change_sprite():
    if is_walking:
        sprite.texture = spriteWalking
        if last_press_direction == 1:
            sprite.flip_h = false
        elif last_press_direction == -1:
            sprite.flip_h = true
    if is_jumping:
        sprite.texture = spriteJumping
    if is_crouching:
        sprite.texture = spriteCrouch
    if is_dashing:
        sprite.texture = spriteSlide

    if !is_walking and !is_jumping and !is_crouching and !is_dashing:
        sprite.texture = spriteStanding
