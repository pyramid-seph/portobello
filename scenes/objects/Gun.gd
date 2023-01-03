extends Marker2D


@export var Bullet: PackedScene
@export var bullet_speed: float = 80.0
@export var cooldown: float = 1.0
@export var ignore_cooldown: bool = false

@onready var _root := $"/root"
@onready var _cooldown_timer := $CooldownTimer


func _ready():
	_start_cooldown_timer()


func _spawn_bullet(direction: Vector2):
	var bullet = Bullet.instantiate()
	bullet.position = global_position
	bullet.direction = direction
	bullet.speed = bullet_speed
	bullet.shooter = owner
	_root.add_child(bullet)


func shoot(direction):
	var can_shoot: bool = ignore_cooldown or _cooldown_timer.is_stopped()
	if can_shoot:
		_spawn_bullet(direction)
		_start_cooldown_timer()
	return can_shoot


func _start_cooldown_timer() -> void:
	if not ignore_cooldown:
		_cooldown_timer.start(cooldown)
