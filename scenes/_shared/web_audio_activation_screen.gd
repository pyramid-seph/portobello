class_name WebAudioActivationScreen
extends Control


signal completed

enum ActivationRequired {
	ALWAYS, ## Show and await for activation always
	WEB_ONLY, ## Show and await for activation only if the running platform is a web browser
}

const SFX_WEB_AUDIO_ACTIVATED = preload("res://audio/sfx/sfx_web_audio_activated.wav")

@export var activation_required: ActivationRequired

var _img_tween: Tween

@onready var _notice_img: TextureRect = %NoticeImg
@onready var _main_info_label: RichTextLabel = %MainInfoLabel
@onready var _secondary_info_label: Label = %SecondaryInfoLabel
@onready var _delayed_start_timer: Timer = $DelayedStartTimer
@onready var _screen_container: PanelContainer = %ScreenContainer


func _ready() -> void:
	_setup_main_info_label()
	
	if get_parent() == get_tree().root:
		enable()
	else:
		disable()


func _input(event: InputEvent) -> void:
	var mouse_click := event as InputEventMouseButton
	var touch_event := event as InputEventScreenTouch
	if (mouse_click and mouse_click.button_index == MOUSE_BUTTON_LEFT) or \
			(touch_event and touch_event.pressed):
		get_viewport().set_input_as_handled()
		set_process_input(false)
		SoundUtils.unmute()
		await _play_img_tween().finished
		if not SaveDataManager.save_data.is_audio_enabled:
			SoundUtils.mute()
		_kill_img_tween()
		await create_tween().tween_interval(1.0).finished
		_activation_completed()


func enable() -> void:
	if activation_required == ActivationRequired.WEB_ONLY and \
			not Utils.is_running_on_web():
		disable()
		_activation_completed.call_deferred()
		return
	
	show()
	_screen_container.hide()
	_delayed_start_timer.start()


func disable() -> void:
	hide()
	set_process_input(false)
	_delayed_start_timer.stop()


func _activation_completed() -> void:
	disable()
	completed.emit()


func _setup_main_info_label() -> void:
	if Utils.is_running_on_web() and \
			InputUtils.get_main_input_device() == InputUtils.InputDevice.TOUCHSCREEN:
		_main_info_label.text = "INFO_ACTIVATE_AUDIO_WEB_0_TOUCHSCREEN"
		_secondary_info_label.text = "INFO_ACTIVATE_AUDIO_WEB_1_TOUCHSCREEN"
	else:
		_main_info_label.text = "INFO_ACTIVATE_AUDIO_WEB_0_MOUSE"
		_secondary_info_label.text = "INFO_ACTIVATE_AUDIO_WEB_1_MOUSE"


func _play_img_tween() -> Tween:
	_kill_img_tween()
	_img_tween = create_tween()
	_img_tween.tween_callback(
			SoundManager.play_sound.bind(SFX_WEB_AUDIO_ACTIVATED))
	_img_tween.tween_property(_notice_img, "self_modulate:a", 1, 0).from(1.0)
	_img_tween.tween_interval(0.1)
	_img_tween.tween_property(_notice_img, "self_modulate:a", 0, 0)
	_img_tween.tween_interval(0.1)
	_img_tween.tween_property(_notice_img, "self_modulate:a", 1, 0)
	return _img_tween


func _kill_img_tween() -> void:
	if _img_tween:
		_img_tween.kill()
		_img_tween = null


func _on_delayed_start_timer_timeout() -> void:
	set_process_input(true)
	_screen_container.show()
