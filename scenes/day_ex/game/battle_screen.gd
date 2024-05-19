@tool
extends CanvasLayer

signal battle_finished(success: bool)

@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

@onready var _panel_container: PanelContainer = $PanelContainer
@onready var _player_action_container: PanelContainer = %PlayerActionContainer
@onready var _background_texture_rect: TextureRect = %BackgroundTextureRect
@onready var _timer: Timer = $Timer


func _ready() -> void:
	if not Engine.is_editor_hint():
		_panel_container.visible = get_parent() == $/root
	_on_preview_set()


func start() -> void: # args: enemy_party
	await TransitionPlayer.play_battle()
	_timer.start(1.0)
	await _timer.timeout
	_panel_container.show()
	await TransitionPlayer.play_battle_backwards()
	_timer.start(3.0)
	await _timer.timeout
	await TransitionPlayer.play_battle()
	_panel_container.hide()
	_timer.start(1.0)
	await _timer.timeout
	await TransitionPlayer.play_battle_backwards()
	battle_finished.emit(true)


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_panel_container.visible = _preview
