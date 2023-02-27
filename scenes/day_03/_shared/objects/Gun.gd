extends Marker2D


@export var Bullet: PackedScene
@export var bullet_speed: float = 80.0
@export var cooldown: float = 1.0
@export var ignore_cooldown: bool = false

var world: Node2D

@onready var _cooldown_timer := $CooldownTimer as Timer


func _ready() -> void:
	_start_cooldown_timer()


func _world_or_default() -> Node2D:
	if world:
		return world
	elif owner and owner.get_parent():
		return owner.get_parent()
	else:
		return get_node("/root")


func _spawn_bullet(direction: Vector2) -> void:
	var bullet = Bullet.instantiate()
	bullet.global_position = global_position
	bullet.direction = direction
	bullet.speed = bullet_speed
	bullet.shooter = owner
	_world_or_default().add_child(bullet)


func shoot(direction: Vector2) -> bool:
	var can_shoot: bool = ignore_cooldown or _cooldown_timer.is_stopped()
	if can_shoot:
		_spawn_bullet(direction)
		_start_cooldown_timer()
	return can_shoot


func _start_cooldown_timer() -> void:
	if not ignore_cooldown:
		_cooldown_timer.start(cooldown)
