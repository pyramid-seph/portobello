extends Control


const NEXT_PAGE = preload("res://audio/kenney_interface_sounds/Audio/back_001.ogg")

const MUTE_CHARS: Array[String] = [
	"*",
	",",
	".",
	"'",
	"\"",
	":",
	"¡",
	"!",
	"¿",
	"?",
	"",
	" ",
]

var _dialogue_event: DialogueEvent
var _curr_page: int = -1
var _text_tween: Tween

@onready var _name_label: Label = %NameLabel
@onready var _dialogue_label: RichTextLabel = %DialogueLabel
@onready var _next_page_anim_player: AnimationPlayer = $NextPageAnimationPlayer
@onready var _next_page_texture_rect: TextureRect = %NextPageTextureRect
@onready var _name_container: PanelContainer = %NameContainer


func _ready() -> void:
	DialogueManager.play_requested.connect(play)
	
	if get_parent() == get_tree().root:
		var example: DialogueEvent = _build_example_dialogue()
		example.finished.connect(func():
				Log.d("Dialogue event finished"))
		play(example)
	else:
		visible = false
	
	set_process_unhandled_input(visible)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"fire"):
		return
	
	get_viewport().set_input_as_handled()
	
	if _text_tween and _text_tween.is_running():
		_text_tween.kill()
		_text_tween = null
		_dialogue_label.visible_characters = -1
		_next_page_anim_player.play(&"next_page")
	else:
		_next()


func play(dialogue_event: DialogueEvent) -> void:
	_curr_page = -1
	_dialogue_event = dialogue_event
	visible = _dialogue_event and not _dialogue_event.is_empty()
	if visible:
		_next()
	else:
		await get_tree().process_frame
		_finish_event()


func _next() -> void:
	_curr_page += 1
	
	if _curr_page > 0:
		SoundManager.play_sound(NEXT_PAGE)
	
	if _dialogue_event and _dialogue_event.get_page_count() - 1 >= _curr_page:
		var page: DialoguePage = _dialogue_event.get_page(_curr_page)
		_say(page)
	else:
		visible = false
		_finish_event()


func _say(page: DialoguePage) -> void:
	if not page:
		Log.d("DialoguePage is null. Won't say it.")
		return
	
	if is_zero_approx(anchor_bottom):
		_name_container.visible = not page.character.is_empty()
	else:
		_name_container.modulate.a = 0.0 if page.character.is_empty() else 1.0
	_name_label.text = page.character
	_dialogue_label.text = page.line
	
	_next_page_anim_player.stop()
	_next_page_texture_rect.self_modulate.a = 0
	_dialogue_label.visible_characters = 0
	
	if _text_tween:
		_text_tween.kill()
	_text_tween = create_tween()
	var message_length: float = _dialogue_label.get_total_character_count()
	var duration: float = message_length / page.text_speed_chars_per_second
	_text_tween.tween_method(_reveal_dialogue.bind(_dialogue_label, page.voice),
			0, message_length, duration)
	await _text_tween.finished
	_next_page_anim_player.play(&"next_page")


func _reveal_dialogue(value: int, label: RichTextLabel,
		voice: Array[AudioStream]) -> void:
	if value == label.visible_characters:
		return
	
	label.visible_characters = value
	
	if not voice or voice.is_empty():
		return
	
	var curr_char_idx: int = label.visible_characters - 1
	if curr_char_idx > -1:
		var curr_char: String = label.get_parsed_text()[curr_char_idx]
		if curr_char not in MUTE_CHARS:
			SoundManager.play_sound(voice.pick_random())


func _build_example_dialogue() -> DialogueEvent:
	var page_1: DialoguePage = DialoguePage.new()
	page_1.character = "Lorem"
	page_1.line = "Lorem ipsum dolor sit amet."
	var page_2: DialoguePage = DialoguePage.new()
	page_2.line = "Consectetur adipiscing elit."
	var page_3: DialoguePage = DialoguePage.new()
	page_3.character = "Ipsum"
	page_3.line = "Aliquam elementum id elit in consequat."
	page_3.text_speed_chars_per_second = 75.0
	var dialogue_event_example := DialogueEvent.new()
	dialogue_event_example._dialogue = [page_1, page_2, page_3]
	return dialogue_event_example


func _finish_event() -> void:
	_curr_page = -1
	if _dialogue_event:
		_dialogue_event.finished.emit()
		_dialogue_event = null


func _on_visibility_changed() -> void:
	set_process_unhandled_input(visible)
	if is_node_ready():
		_next_page_anim_player.stop()
