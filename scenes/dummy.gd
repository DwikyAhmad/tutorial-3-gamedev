extends RigidBody2D
@onready var crash = $crash


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    # Atur mode physics yang sesuai untuk RigidBody2D
    freeze = false  # Biarkan objek bergerak
    gravity_scale = 1.0  # Aktifkan gravity
    lock_rotation = true  # Opsional: mencegah rotasi saat terkena hit


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass


func hit(force: Vector2):
    # Fungsi ini akan dipanggil oleh Player saat menyerang
    apply_central_impulse(force)  # Berikan gaya dorong
    crash.play()
