extends Control

signal finished

const TEXT_SPEED_CHARS_PER_SECOND: float = 25.0
const LOL = [
	{ "name": "Maki", "text": "This was a triumph!" },
	{ "name": "Mofles", "text": "I'm making a note here" },
	{ "name": "Mofles", "text": "Huge success" },
]

var _text_tween: Tween

@onready var _name_label: Label = %NameLabel
@onready var _dialogue_label: Label = %DialogueLabel
@onready var _next_page_anim_player: AnimationPlayer = $NextPageAnimationPlayer
@onready var _next_page_texture_rect: TextureRect = %NextPageTextureRect
@onready var _name_container: PanelContainer = %NameContainer

func _ready() -> void:
	if get_parent() == get_tree().root:
		play(LOL)
	else:
		visible = false
	set_process_unhandled_input(visible)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("fire"):
		return
	
	if _text_tween and _text_tween.is_running():
		_text_tween.kill()
		_text_tween = null
		_dialogue_label.visible_characters = -1
		_next_page_anim_player.play("next_page")
		get_viewport().set_input_as_handled()
	else:
		visible = false
		finished.emit()


func play(thing) -> void:
	visible = true
	_next(thing[0])


func _next(page) -> void:
	visible = true
	
	_name_container.visible = not page.name.is_empty()
	_name_label.text = "%s:" % page.name
	_dialogue_label.text = page.text
	
	_next_page_anim_player.stop()
	_next_page_texture_rect.modulate.a = 0
	
	if _text_tween:
		_text_tween.kill()
	
	_text_tween = create_tween()
	var message_length: float = _dialogue_label.text.length()
	var duration: float = message_length / TEXT_SPEED_CHARS_PER_SECOND
	_text_tween.tween_property(
			_dialogue_label, 
			"visible_characters", 
			message_length, 
			duration)
	await _text_tween.finished
	_next_page_anim_player.play("next_page")


func _on_visibility_changed() -> void:
	set_process_unhandled_input(visible)
	if is_node_ready():
		_next_page_anim_player.stop()
