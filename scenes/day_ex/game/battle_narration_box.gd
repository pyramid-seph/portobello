extends PanelContainer

signal read

const UI_NEXT_SOUND = preload("res://audio/ui/ui_next.wav")

var _what: String = ""
var _format_values: Dictionary = {}

@onready var _narration_label: RichTextLabel = %NarrationLabel
@onready var _next_page_texture_rect: TextureRect = %NextPageTextureRect
@onready var _next_page_anim_player: AnimationPlayer = $NextPageAnimationPlayer


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		accept_event()
		release_focus()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_update_narration_label_text()


func say(what: String, format_values: Dictionary = {}) -> void:
	_what = what
	_format_values = format_values
	
	if not is_node_ready():
		await ready
	_update_narration_label_text()


func say_and_wait_until_read(what: String, format_values: Dictionary = {}) -> void:
	say(what, format_values)
	await wait_until_read()


func wait_until_read() -> void:
	grab_focus.call_deferred()
	await read
	SoundManager.play_sound(UI_NEXT_SOUND)


func silence() -> void:
	say("")


func _update_narration_label_text() -> void:
	if not is_node_ready():
		return
	
	var tr_format_values: Dictionary = {}
	for key: String in _format_values:
		var value : String = str(_format_values[key])
		tr_format_values[key] = tr(value)
	_narration_label.text = tr(_what).format(tr_format_values)


func _on_focus_entered() -> void:
	_next_page_texture_rect.modulate.a = 1
	_next_page_anim_player.play("next_page")


func _on_focus_exited() -> void:
	_next_page_texture_rect.modulate.a = 0
	_next_page_anim_player.stop()
	read.emit()
