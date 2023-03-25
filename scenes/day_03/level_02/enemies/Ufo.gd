extends Area2D


@export var Explosion: PackedScene
@export var speed: float = 87.5
@export var movement_pattern: EnemyMovement.Pattern = EnemyMovement.Pattern.VERTICAL_DOWN:
	get:
		return movement_pattern
	set(mod_value):
		movement_pattern = mod_value
		match (movement_pattern):
			EnemyMovement.Pattern.VERTICAL_DOWN:
				_direction = Vector2.DOWN
			EnemyMovement.Pattern.VERTICAL_UP:
				_direction = Vector2.UP
			EnemyMovement.Pattern.HORIZONTAL_LEFT:
				_direction = Vector2.LEFT
			EnemyMovement.Pattern.HORIZONTAL_RIGHT:
				_direction = Vector2.RIGHT
			EnemyMovement.Pattern.ZIG_ZAG_DOWN:
				_direction = Vector2(1, 1)
			EnemyMovement.Pattern.SQUARE_UP:
				_direction = Vector2.RIGHT
			EnemyMovement.Pattern.SQUARE_DOWN:
				_direction = Vector2.LEFT
			_:
				print_debug("Unknown movement pattern: %s. Will default to VERTICAL_DOWN." % str(mod_value))
				movement_pattern = EnemyMovement.Pattern.VERTICAL_DOWN
				_direction = Vector2.DOWN
		_correct_initial_pos_x()
@export var score_points_gun: int = 0
@export var score_points_mega_gun: int = 0
@export var is_immune_to_bullets: bool = false

var world: Node2D:
	set(value):
		world = value
		if not _is_ready: return
		_bottom_gun.world = value

var _direction: Vector2 = Vector2.DOWN
var _velocity: Vector2 = _direction * speed

@onready var _bottom_gun := $BottomGun
@onready var _top_gun := $TopGun
@onready var _viewport_size: Vector2 = get_viewport_rect().size
@onready var _viewport_width: float = _viewport_size.x
@onready var _viewport_height: float = _viewport_size.y
@onready var _animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _sprite_width: float = _animated_sprite.sprite_frames.get_frame_texture("default", 0).get_width()
@onready var _min_pos_x: float = 0.0
@onready var _max_pos_x: float = _viewport_width - _sprite_width
@onready var _is_ready: bool = true


func _ready() -> void:
	_correct_initial_pos_x()


func _process(delta: float) -> void:
	match (movement_pattern):
		EnemyMovement.Pattern.ZIG_ZAG_DOWN:
			if position.x > _max_pos_x or position.x < _min_pos_x:
				_direction.x *= -1
		EnemyMovement.Pattern.SQUARE_UP:
			if position.x > _max_pos_x or position.x < _min_pos_x:
				_direction.x *= -1
				position.y -= 30 + randi() % 10
		EnemyMovement.Pattern.SQUARE_DOWN:
			if position.x > _max_pos_x or position.x < _min_pos_x:
				_direction.x *= -1
				position.y += 30 + randi() % 10

	_velocity = _direction * speed
	position += _velocity * delta


func fire_bottom_gun() -> bool:
	return _bottom_gun.shoot(Vector2.DOWN)


func fire_top_gun() -> bool:
	return _top_gun.shoot(Vector2.UP)


func kill(killer: Node, killed_by_mega_gun: bool = false) -> void:
	if killer and killer.has_method("add_points_to_score"):
		killer.add_points_to_score(
			score_points_mega_gun if killed_by_mega_gun else score_points_gun
		)
	explode()


func explode() -> void:
	_spawn_explosion()
	queue_free()


func _spawn_explosion() -> void:
	var new_explosion = Explosion.instantiate()
	new_explosion.centered = _animated_sprite.centered
	new_explosion.global_position = global_position
	_world_or_default().add_child(new_explosion)


func _world_or_default() -> Node2D:
	if world:
		return world
	elif owner and owner.get_parent():
		return owner.get_parent()
	else:
		return get_node("/root")


func _correct_initial_pos_x() -> void:
	if not _is_ready: return
	
	match (movement_pattern):
		EnemyMovement.Pattern.SQUARE_UP, EnemyMovement.Pattern.SQUARE_DOWN:
			if position.x >= _max_pos_x:
				_direction = Vector2.LEFT
			if position.x <= _min_pos_x:
				_direction = Vector2.RIGHT
	position.x = clamp(position.x, _min_pos_x, _max_pos_x)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if is_immune_to_bullets:
		_spawn_explosion()
	else:
		var killer = area.shooter if area.is_in_group("bullets") else area
		kill(killer)
