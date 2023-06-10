extends Node

signal finished

@export var _original_credits: RollingCredits
@export var _port_credits: RollingCredits

@export_group("Debug", "_debug")
@export var _debug_autostart: bool:
	get:
		return _debug_autostart and OS.is_debug_build()

@onready var _job_label := %JobLabel as Label
@onready var _names_label := %NamesLabel as Label
@onready var _timer := $Timer as Timer


func _ready() -> void:
	if _debug_autostart:
		roll_all()


func roll_all() -> void:
	await roll(_original_credits)
	await roll(_port_credits)
	_job_label.text = "GameCL"
	_names_label.text = "\n¡Gracias por jugar!"
	_timer.start(4.0)
	await _timer.timeout
	_job_label.text = ""
	_names_label.text = ""
	_timer.start(2.0)
	await _timer.timeout
	finished.emit()


func roll(creditsRes: RollingCredits) -> void:
	for credit in creditsRes.list:
		_job_label.text = credit.job
		_names_label.text = "\n".join(credit.names)
		_timer.start(credit.duration_sec)
		await _timer.timeout
	_job_label.text = ""
	_names_label.text = ""
