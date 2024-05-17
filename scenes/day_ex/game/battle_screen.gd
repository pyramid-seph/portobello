@tool
extends CanvasLayer

@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

@onready var _panel_container: PanelContainer = $PanelContainer
@onready var _player_action_container: PanelContainer = %PlayerActionContainer
@onready var _background_texture_rect: TextureRect = %BackgroundTextureRect


func _ready() -> void:
	if not Engine.is_editor_hint():
		_panel_container.visible = get_parent() == $/root
	_on_preview_set()


func start() -> void: # args: enemy_party
	# 1. Determine order using speed
	# 2. 
	pass


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_panel_container.visible = _preview
