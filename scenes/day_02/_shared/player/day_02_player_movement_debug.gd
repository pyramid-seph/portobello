extends Node2D


@onready var _player := get_parent()
@onready var _dir_duration_label: Label = $DirDurationLabel
@onready var _origin_sprite: Sprite2D = $Node/OriginSprite
@onready var _target_sprite: Sprite2D = $Node/TargetSprite2


func _ready() -> void:
	if not OS.is_debug_build():
		set_process(false) # Just to be super sure
		queue_free()


func _process(_delta: float) -> void:
	queue_redraw()
	
	if _player._debug_show_dir_duration:
		_dir_duration_label.visible = true
		_dir_duration_label.text = "%0.2f"  % _player._dir_pressed_sec
	else:
		_dir_duration_label.visible = false
	if _player._debug_show_target_and_origin:
		_target_sprite.visible = true
		_origin_sprite.visible = true
		_target_sprite.global_position = _player._maze.to_global(_player._target_local_pos)
		_origin_sprite.global_position = _player._maze.to_global(_player._origin_local_pos)
		_origin_sprite.rotation_degrees = _player._animated_sprite.rotation_degrees
		_origin_sprite.flip_h = _player._animated_sprite.flip_h
		_origin_sprite.flip_v = _player._animated_sprite.flip_v
	else:
		_target_sprite.visible = false
		_origin_sprite.visible = false


func _draw() -> void:
	if not _player or not _player._debug_show_move_lines:
		return
	for dir: Vector2i in _player._next_valid_dirs:
		var z: Vector2i = _player._target_local_pos - _player.position
		draw_line(z, z + dir * 20, Color.CADET_BLUE, 4)
	var cornering_zone_length: float = sqrt(_player.CORNERING_ZONE_SQRD_LENGHT)
	draw_line(Vector2.ZERO, _player._candidate_dir * 16, Color.RED, 2)
	var color := Color.MEDIUM_SEA_GREEN
	if _player.position.distance_to(_player._target_local_pos) <= cornering_zone_length or \
			_player.position.distance_to(_player._origin_local_pos) <= cornering_zone_length:
		color = Color.WHITE
	draw_line(Vector2(cornering_zone_length * -1, 8), Vector2(cornering_zone_length, 8),  color, 2)
	draw_line(Vector2(cornering_zone_length * -1, -8), Vector2(cornering_zone_length, -8), color, 2)
	draw_line(Vector2(-8, cornering_zone_length * -1), Vector2(-8, cornering_zone_length), color, 2)
	draw_line(Vector2(8, cornering_zone_length * -1), Vector2(8, cornering_zone_length), color, 2)
