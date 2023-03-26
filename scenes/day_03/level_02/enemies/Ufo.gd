extends Area2D


@export var Explosion: PackedScene
@export var score_points_gun: int = 0
@export var score_points_mega_gun: int = 0
@export var speed: float = 87.5:
	set(value): 
		speed = value
		_on_set_speed()
@export var movement_pattern: SimpleMover.Pattern:
	set(value):
		movement_pattern = value
		_on_set_movement_pattern()
@export var is_immune_to_bullets: bool = false

var world: Node2D:
	set(value): 
		world = value
		_on_set_world()

@onready var _simple_mover := $SimpleMover as SimpleMover
@onready var _bottom_gun := $BottomGun as Gun
@onready var _top_gun := $TopGun as Gun
@onready var _animated_sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _is_ready: bool = true


func _ready() -> void:
	_on_set_world()
	_on_set_speed()
	_setup_min_max_x_movement()
	_on_set_movement_pattern()


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


func _on_set_speed() -> void:
	if _is_ready:
		_simple_mover.speed = speed


func _on_set_movement_pattern() -> void:
	if _is_ready:
		_simple_mover.pattern = movement_pattern


func _on_set_world() -> void:
	if _is_ready:
		_bottom_gun.world = _world_or_default()
		_top_gun.world = _world_or_default()


func _setup_min_max_x_movement() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_width: float = viewport_size.x
	var sprite_width: float = _animated_sprite.sprite_frames.get_frame_texture(
			"default", 0).get_width()
	_simple_mover.min_pos_x = 0.0
	_simple_mover.max_pos_x = viewport_width - sprite_width


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if is_immune_to_bullets:
		_spawn_explosion()
	else:
		var killer = area.shooter if area.is_in_group("bullets") else area
		kill(killer)
