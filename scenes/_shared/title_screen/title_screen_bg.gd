extends ParallaxBackground


@export var scroll_speed: float = 0.0
@export var game_texture: Texture2D:
	set(value):
		var old_game_texture = game_texture
		game_texture = value
		if old_game_texture != game_texture:
			_on_bg_sprites_changed()
@export_color_no_alpha var game_color := Color.MAGENTA:
	set(value):
		var old_game_color = game_color
		game_color = value
		if old_game_color != game_color:
			_on_game_color_changed()
@export var _cell_size: Vector2

var _offset_local: float = 0.0

@onready var _is_ready := true
@onready var _bg_layer := $BgLayer as ParallaxLayer
@onready var _color_rect := $ColorRect as ColorRect
@onready var _base_window_size: Vector2 = get_viewport().get_visible_rect().size


func _ready() -> void:
	_bg_layer.motion_mirroring = Vector2(_base_window_size.x, 0.0)
	_generate__bg_layer()
	_on_game_color_changed()
	_on_bg_sprites_changed()


func _process(delta) -> void:
	_offset_local += delta * scroll_speed
	scroll_offset = Vector2(_offset_local, 0.0)


func _on_game_color_changed() -> void:
	if _is_ready:
		_color_rect.color = game_color


func _on_bg_sprites_changed() -> void:
	if not _is_ready:
		return
	
	for i in _bg_layer.get_children():
		var sprite := i as Sprite2D
		if sprite != null:
			sprite.texture = game_texture


func _spawn_bg_sprite(col, row) -> void:
	if row % 2 == 0:
		if col % 2 != 0:
			return
	else:
		if col % 2 == 0:
			return
	
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.position.x = col * _cell_size.x
	sprite.position.y = row * _cell_size.y
	_bg_layer.add_child(sprite)


func _generate__bg_layer() -> void:
	var hcell_count = ceili(_base_window_size.x / _cell_size.x)
	var vcell_count = ceili(_base_window_size.y / _cell_size.y)
	var cell_count = hcell_count * vcell_count
	var row = -1
	for i in range(cell_count):
		var col = i % hcell_count
		if col == 0:
			row += 1
		_spawn_bg_sprite(col, row)
