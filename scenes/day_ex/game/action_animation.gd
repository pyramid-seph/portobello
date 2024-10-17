extends Control


signal finished

@export var _sprites: Array[Texture2D]
@export var _duration_sec: float = 1.0
@export_color_no_alpha var _target_flash_color: Color = Color.WHITE
@export var _screen_flash_color: Color = Color.TRANSPARENT
@export var _shake_screen: bool
@export var _autoplay: bool = true

var _tween: Tween

@onready var _texture_rect: TextureRect = $TextureRect


func _ready() -> void:
	if _autoplay:
		play()


func configure(battle_action: BattleAction) -> void:
	_sprites = battle_action.get_sprites()
	_duration_sec = battle_action.get_duration_sec()
	_screen_flash_color = battle_action.get_screen_flash_color()
	_shake_screen = battle_action.shake_screen()


func play() -> void:
	stop()
	var time: float = _duration_sec / _sprites.size()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_LINEAR)
	for texture: Texture2D in _sprites:
		_tween.tween_property(_texture_rect, "texture", texture, 0.0)
		_tween.tween_interval(time)
	_tween.tween_callback(func():
			_texture_rect.texture = null
			finished.emit())


func stop() -> void:
	if _tween:
		_tween.kill()
		_tween = null


func get_target_flash_color() -> Color:
	return _target_flash_color


func get_screen_flash_color() -> Color:
	return _screen_flash_color


func shake_screen() -> bool:
	return _shake_screen
