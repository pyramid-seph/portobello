extends ParallaxBackground

@export var scroll_speed: float = 16.0
@export var cloud: PackedScene
@export var wave: PackedScene

@onready var bg_layer := $BgLayer
@onready var base_window_size := Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
)

var _offset_local: float = 0.0


func _ready() -> void:
	bg_layer.motion_mirroring = base_window_size
	_generate_bg_layer()


func _process(delta) -> void:
	_offset_local += delta * scroll_speed
	set_scroll_offset(Vector2(0, _offset_local))


func _get_sprite_size() -> Vector2:
	var reference_sprite = cloud.instantiate()
	var frame = reference_sprite.frames.get_frame("default", 0)
	var size = Vector2(frame.get_width(), frame.get_height())
	reference_sprite.queue_free()
	return size


func _spawn_bg_sprite(col: int, row: int, cell_size: Vector2) -> void:
	var bg_sprite
	var bg_sprite_chance = randi() % 60
	match bg_sprite_chance:
		0, 1:
			bg_sprite = cloud.instantiate()
		2, 3:
			bg_sprite = wave.instantiate()
	if bg_sprite != null:
		bg_sprite.position = Vector2(col * cell_size.x, row * cell_size.y)
		bg_layer.add_child(bg_sprite)


func _generate_bg_layer() -> void:
	var cell_size = _get_sprite_size()
	var hcell_count = int(ceil(base_window_size.x / cell_size.x))
	var vcell_count = int(ceil(base_window_size.y / cell_size.y))
	var cell_count = hcell_count * vcell_count

	var row = -1
	for i in range(cell_count):
		var col = i % hcell_count
		if col == 0:
			row += 1
		_spawn_bg_sprite(col, row, cell_size)
