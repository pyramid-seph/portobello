@tool
extends Area2D

const Player = preload("res://scenes/day_ex/player/day_ex_player.gd")
const Entrance = preload("res://scenes/day_ex/game/entrance.gd")

@export var _entrance_node_path: Node2D:
	set(value):
		_entrance_node_path = value
		_on_entrance_node_path_set()
		update_configuration_warnings()

@export_group("Editor Tools", "_editor")
@export var _editor_show_connected_entrance: bool:
	get:
		return Engine.is_editor_hint() and _editor_show_connected_entrance

var _entrance: Entrance

@onready var _sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	_on_entrance_node_path_set()
	_sprite_2d.visible = Engine.is_editor_hint()
	set_process(Engine.is_editor_hint())


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not _entrance or not _editor_show_connected_entrance:
		return
	
	var _entrance_local_pos: Vector2 = to_local(_entrance.global_position)
	draw_line(Vector2.ZERO, _entrance_local_pos, _entrance.color_tag)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _entrance_node_path or _entrance_node_path is not Entrance:
		warnings.append("An exit must be connected to an entrance.")
	return warnings


func _on_entrance_node_path_set() -> void:
	if not is_node_ready():
		return
	
	var old_entrance: Entrance = _entrance
	_entrance = _entrance_node_path as Entrance
	
	if not Engine.is_editor_hint():
		return
	
	if old_entrance and is_instance_valid(old_entrance):
		Utils.safe_disconnect(old_entrance.color_tag_changed, _on_color_tag_changed)
	
	_set_color_from_entrace_color_tag()
	
	if _entrance:
		Utils.safe_connect(_entrance.color_tag_changed, _on_color_tag_changed)


func _set_color_from_entrace_color_tag() -> void:
	var color: Color = _entrance.color_tag if _entrance else Color.WHITE
	_sprite_2d.self_modulate = color


func _on_color_tag_changed() -> void:
	_set_color_from_entrace_color_tag()


func _on_body_entered(player: Player) -> void:
	if Engine.is_editor_hint():
		return
	
	if not _entrance:
		Log.d("Entrance not set or invalid.")
		return
	
	if player:
		var offset: Vector2 = player.global_position - global_position
		_entrance.teleport_here(player, offset)
