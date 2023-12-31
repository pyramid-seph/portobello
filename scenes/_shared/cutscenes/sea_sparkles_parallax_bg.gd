extends ParallaxBackground

@export var scroll_speed: float = 1.0

var _offset_local: float = 0.0

@onready var _viewport_size: Vector2 = get_viewport().get_visible_rect().size
@onready var _bg_layer := $ParallaxLayer as ParallaxLayer


func _ready() -> void:
	_bg_layer.motion_mirroring = Vector2(_viewport_size.x, 0)


func _process(delta: float) -> void:
	_offset_local -= delta * scroll_speed
	scroll_offset = Vector2(_offset_local, 0)
 
