extends Node

@export var is_cold_boot: bool = true

@onready var _title_screen = $TitleScreen
@onready var _logos_roll := $LogosRoll


func _ready() -> void:
	if is_cold_boot:
		_enable_title_screen(false)
		_logos_roll.start()
	else:
		_enable_title_screen(true)


func _enable_title_screen(value: bool) -> void:
	_title_screen.visible = value
	_title_screen.process_mode = Node.PROCESS_MODE_DISABLED if not value else Node.PROCESS_MODE_ALWAYS


func _on_logos_roll_rolled() -> void:
	_logos_roll.visible = false
	_enable_title_screen(true)
