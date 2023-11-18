extends Control

signal rolled

@onready var _timer := $Timer as Timer
@onready var game_cl_logo: ColorRect = $GameCLLogo
@onready var controller_support_info: ColorRect = $ControllerSupportInfo


func start() -> void:
	visible = true
	game_cl_logo.visible = true
	_timer.start(2.0)
	await _timer.timeout
	game_cl_logo.visible = false
	controller_support_info.visible = true
	_timer.start(4.0)
	await  _timer.timeout
	controller_support_info.visible = false
	visible = false
	rolled.emit()
