extends Parallax2D


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

@onready var _bg_layer: Node2D = $BgLayer
@onready var _color_rect: ColorRect = %ColorRect
@onready var _base_window_size: Vector2 = get_viewport().get_visible_rect().size


func _ready() -> void:
	_generate_bg_layer()
	_on_game_color_changed()
	_on_bg_sprites_changed()


func _on_game_color_changed() -> void:
	if is_node_ready():
		_color_rect.color = game_color


func _on_bg_sprites_changed() -> void:
	if is_node_ready():
		for sprite: Sprite2D in _bg_layer.get_children():
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


func _generate_bg_layer() -> void:
	var hcell_count: int = ceili(_base_window_size.x / _cell_size.x)
	var vcell_count: int = ceili(_base_window_size.y / _cell_size.y)
	var cell_count: int = hcell_count * vcell_count
	var row: int = -1
	for i: int in cell_count:
		var col: int = i % hcell_count
		if col == 0:
			row += 1
		_spawn_bg_sprite(col, row)
