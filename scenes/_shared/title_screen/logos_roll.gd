extends Control

signal rolled

@onready var _timer := $Timer as Timer
@onready var _game_cl_logo: ColorRect = $GameCLLogo
@onready var _my_logo: ColorRect = $MyLogo
@onready var _controller_support_info: ColorRect = $ControllerSupportInfo


func start() -> void:
	_timer.start(1.0)
	await _timer.timeout
	visible = true
	_game_cl_logo.visible = true
	_timer.start(3.0)
	await _timer.timeout
	_game_cl_logo.visible = false
	_timer.start(1.0)
	await _timer.timeout
	_my_logo.visible = true
	_timer.start(3.0)
	await _timer.timeout
	_my_logo.visible = false
	_timer.start(1.0)
	await _timer.timeout
	_controller_support_info.visible = true
	_timer.start(4.0)
	await _timer.timeout
	_controller_support_info.visible = false
	_timer.start(1.0)
	await  _timer.timeout
	visible = false
	rolled.emit()
