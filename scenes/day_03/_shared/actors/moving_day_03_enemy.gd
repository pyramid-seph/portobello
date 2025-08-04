class_name MovingDay03Enemy
extends BaseDay03Enemy

@export var speed: float = 0:
	set(value): 
		speed = value
		_on_set_speed()
@export var movement_pattern: SimpleMover.Pattern:
	set(value):
		movement_pattern = value
		_on_set_movement_pattern()

@onready var _simple_mover := $SimpleMover as SimpleMover


func _ready() -> void:
	super()
	_on_set_speed()
	_setup_min_max_x_movement()
	_on_set_movement_pattern()


func _on_set_speed() -> void:
	if is_node_ready():
		_simple_mover.speed = speed


func _on_set_movement_pattern() -> void:
	if is_node_ready():
		_simple_mover.pattern = movement_pattern


func _setup_min_max_x_movement() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	var viewport_width: float = viewport_size.x
	var sprite_width: float = get_width()
	_simple_mover.min_pos_x = 0.0
	_simple_mover.max_pos_x = viewport_width - sprite_width
