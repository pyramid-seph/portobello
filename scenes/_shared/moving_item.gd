class_name MovingItem
extends Item


@export var speed: float:
	set(value): 
		speed = value
		_on_set_speed()
@export var movement_pattern: SimpleMover.Pattern:
	set(value):
		movement_pattern = value
		_on_set_movement_pattern()

@onready var _simple_mover = $SimpleMover as SimpleMover
@onready var _viewport: Rect2 = get_viewport_rect()


func _ready() -> void:
	super()
	_on_set_speed()
	_setup_min_max_x_movement()
	_on_set_movement_pattern()


func _on_set_speed() -> void:
	if is_ready():
		_simple_mover.speed = speed


func _on_set_movement_pattern() -> void:
	if is_ready():
		_simple_mover.pattern = movement_pattern


func _setup_min_max_x_movement() -> void:
	var texture: Texture2D = get_animated_sprite().sprite_frames.get_frame_texture("default", 0)
	_simple_mover.min_pos_x = 0.0
	_simple_mover.max_pos_x = _viewport.size.x - texture.get_width()
