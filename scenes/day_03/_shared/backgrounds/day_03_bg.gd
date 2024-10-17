extends Parallax2D


@export var cloud: PackedScene
@export var wave: PackedScene
@export var mega_gun_flash_duration_sec: float = 0.08
@export var mega_gun_flash_color: Color = Color8(255, 0, 255)
@export var sea_color: Color = Color8(255, 0, 255)

var _tween: Tween

@onready var solid_color_rect: ColorRect = $SolidColorRect
@onready var bg_layer: Node2D = $BgLayer
@onready var base_window_size: Vector2 = get_viewport().get_visible_rect().size


func _ready() -> void:
	solid_color_rect.color = sea_color
	solid_color_rect.set_deferred("size", base_window_size)
	repeat_size = Vector2(0.0, base_window_size.y)
	_generate_bg_layer()


func _get_sprite_size() -> Vector2:
	var reference_sprite: AnimatedSprite2D = cloud.instantiate()
	var frame = reference_sprite.sprite_frames.get_frame_texture("default", 0)
	var size = Vector2(frame.get_width(), frame.get_height())
	reference_sprite.queue_free()
	return size


func _spawn_bg_sprite(col: int, row: int, cell_size: Vector2) -> void:
	var bg_sprite: AnimatedSprite2D
	var bg_sprite_chance: int = randi() % 60
	match bg_sprite_chance:
		0, 1:
			bg_sprite = cloud.instantiate()
		2, 3:
			bg_sprite = wave.instantiate()
	if bg_sprite != null:
		bg_sprite.position = Vector2(col * cell_size.x, row * cell_size.y)
		bg_layer.add_child(bg_sprite)


func _generate_bg_layer() -> void:
	var cell_size: Vector2 = _get_sprite_size()
	var hcell_count: int = ceili(base_window_size.x / cell_size.x)
	var vcell_count: int = ceili(base_window_size.y / cell_size.y)
	var cell_count: int = hcell_count * vcell_count
	
	var row: int = -1
	for i: int in cell_count:
		var col: int = i % hcell_count
		if col == 0:
			row += 1
		_spawn_bg_sprite(col, row, cell_size)


func _on_mega_gun_shot() -> void:
	solid_color_rect.color = mega_gun_flash_color
	if _tween:
		_tween.stop()
	_tween = create_tween()
	_tween.tween_callback(
		solid_color_rect.set_color.bind(sea_color)
	).set_delay(mega_gun_flash_duration_sec)
