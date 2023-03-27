extends Area2D


@export var speed: float = 0:
	set(value): 
		speed = value
		_on_set_speed()
@export var movement_pattern: SimpleMover.Pattern:
	set(value):
		movement_pattern = value
		_on_set_movement_pattern()
@export var score_points_pickup: int = 0

@onready var _is_ready: bool = true
@onready var _animated_sprite = $AnimatedSprite2D as AnimatedSprite2D
@onready var _simple_mover = $SimpleMover as SimpleMover
@onready var _viewport: Rect2 = get_viewport_rect()


func _ready() -> void:
	_on_set_speed()
	_setup_min_max_x_movement()
	_on_set_movement_pattern()
	var frames_count = _animated_sprite.sprite_frames.get_frame_count("default")
	_animated_sprite.frame = randi() % frames_count
	_animated_sprite.play()


func pick_up(picker) -> void:
	if picker.has_method("add_points_to_score"):
		picker.add_points_to_score(score_points_pickup)
	if picker.has_method("power_up_by"):
		picker.power_up_by(1)
	queue_free()


func is_ready() -> bool:
	return _is_ready


func _on_set_speed() -> void:
	if is_ready():
		_simple_mover.speed = speed


func _on_set_movement_pattern() -> void:
	if is_ready():
		_simple_mover.pattern = movement_pattern


func _setup_min_max_x_movement() -> void:
	_simple_mover.min_pos_x = 0.0
	_simple_mover.max_pos_x = _viewport.size.x


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
