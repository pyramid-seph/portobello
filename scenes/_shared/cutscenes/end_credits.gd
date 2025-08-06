extends Node

signal finished

@export var _original_credits: RollingCredits
@export var _port_credits: RollingCredits

var _moon_tween: Tween

@onready var _job_label := %JobLabel as Label
@onready var _names_label := %NamesLabel as Label
@onready var _timer := $Timer as Timer
@onready var _moon_sprite := $MoonSprite
@onready var _flying_credits_bucho := $FlyingCreditsBucho
@onready var _parallax_bg := $SeaSparklesParallaxBackground
@onready var _ui := $UiComponents



func play() -> void:
	_moon_sprite.visible = true
	if _moon_tween:
		_moon_tween.kill()
	_moon_tween = create_tween()
	var _moon_move_duration: float = 22.0
	for credit: Credit in _port_credits.list:
		_moon_move_duration += credit.duration_sec
	for credit: Credit in _original_credits.list:
		_moon_move_duration += credit.duration_sec
	_moon_tween.tween_property(_moon_sprite, "position:x", -208.0,
			_moon_move_duration).as_relative()
	_flying_credits_bucho.visible = true
	_parallax_bg.visible = true
	_ui.visible = true
	_job_label.text = ""
	_names_label.text = ""
	await create_tween().tween_interval(2.0).finished
	_parallax_bg.process_mode = Node.PROCESS_MODE_INHERIT
	_job_label.text = "CREDITS_IN_MEMORIAM"
	_names_label.text = "CREDITS_IN_MEMORIAM_BUCHO"
	await create_tween().tween_interval(8.0).finished
	_job_label.text = ""
	_names_label.text = ""
	await create_tween().tween_interval(2.0).finished
	await _roll(_port_credits)
	_timer.start(2.0)
	await _timer.timeout
	await _roll(_original_credits)
	_timer.start(3.0)
	await _timer.timeout
	_names_label.text = "CREDITS_THANKS_FOR_PLAYING"
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
	if _moon_tween:
		_moon_tween.kill()
		_moon_tween = null
	_timer.stop()
	_moon_sprite.visible = false
	_flying_credits_bucho.visible = false
	_ui.visible = false
	_parallax_bg.visible = false
	_parallax_bg.process_mode = Node.PROCESS_MODE_DISABLED


func _roll(creditsRes: RollingCredits) -> void:
	for credit: Credit in creditsRes.list:
		_job_label.text = credit.job
		_names_label.text = "\n".join(credit.names)
		_timer.start(credit.duration_sec)
		await _timer.timeout
	_job_label.text = ""
	_names_label.text = ""
