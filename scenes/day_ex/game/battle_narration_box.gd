extends PanelContainer

signal read

var _what: String = ""
var _format_values: Dictionary = {}

@onready var _narration_label: RichTextLabel = %NarrationLabel
@onready var _next_page_texture_rect: TextureRect = %NextPageTextureRect
@onready var _next_page_anim_player: AnimationPlayer = $NextPageAnimationPlayer


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"): # TODO Or ui_accept?
		accept_event()
		release_focus()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		say(_what, _format_values)


func say(what: String, format_values: Dictionary = {}) -> void:
	if not is_node_ready():
		await ready
	
	_what = what
	_format_values = format_values
	_narration_label.text = tr(what).format(format_values)


func say_and_wait_until_read(what: String, format_values: Dictionary = {}) -> void:
	say(what, format_values)
	await wait_until_read()


func wait_until_read() -> void:
	call_deferred("grab_focus")
	await read


func silence() -> void:
	say("")


func _on_focus_entered() -> void:
	_next_page_texture_rect.modulate.a = 1
	_next_page_anim_player.play("next_page")


func _on_focus_exited() -> void:
	_next_page_texture_rect.modulate.a = 0
	_next_page_anim_player.stop()
	read.emit()
