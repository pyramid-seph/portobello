extends Node

signal finished

@export var _original_credits: RollingCredits
@export var _port_credits: RollingCredits

@onready var _job_label := %JobLabel as Label
@onready var _names_label := %NamesLabel as Label
@onready var _timer := $Timer as Timer
@onready var _moon_sprite := $MoonSprite
@onready var _flying_credits_bucho := $FlyingCreditsBucho
@onready var _parallax_bg := $SeaSparklesParallaxBackground
@onready var _ui := $UiComponents



func play() -> void:
	_moon_sprite.visible = true
	_flying_credits_bucho.visible = true
	_parallax_bg.visible = true
	_ui.visible = true
	_parallax_bg.process_mode = Node.PROCESS_MODE_INHERIT
	await _roll(_port_credits)
	_timer.start(2.0)
	await _timer.timeout
	await _roll(_original_credits)
	_timer.start(3.0)
	await _timer.timeout
	_names_label.text = "¡Gracias por jugar!"
	_timer.start(4.0)
	await _timer.timeout
	_job_label.text = ""
	_names_label.text = ""
	_moon_sprite.visible = false
	_flying_credits_bucho.visible = false
	_ui.visible = false
	_parallax_bg.visible = false
	_parallax_bg.process_mode = Node.PROCESS_MODE_DISABLED
	_timer.start(2.0)
	await _timer.timeout
	finished.emit()


func stop() -> void:
	_timer.stop()
	_moon_sprite.visible = false
	_flying_credits_bucho.visible = false
	_ui.visible = false
	_parallax_bg.visible = false
	_parallax_bg.process_mode = Node.PROCESS_MODE_DISABLED


func _roll(creditsRes: RollingCredits) -> void:
	for credit in creditsRes.list:
		_job_label.text = credit.job
		_names_label.text = "\n".join(credit.names)
		_timer.start(credit.duration_sec)
		await _timer.timeout
	_job_label.text = ""
	_names_label.text = ""
