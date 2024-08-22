extends Control

signal started
signal event_requested(event: String)
signal finished

var _dialogue: Array[DialoguePage]
var _curr_page: int = -1
var _text_tween: Tween

@onready var _name_label: Label = %NameLabel
@onready var _dialogue_label: Label = %DialogueLabel
@onready var _next_page_anim_player: AnimationPlayer = $NextPageAnimationPlayer
@onready var _next_page_texture_rect: TextureRect = %NextPageTextureRect
@onready var _name_container: PanelContainer = %NameContainer


func _ready() -> void:
	if get_parent() == get_tree().root:
		event_requested.connect(func(example_event): 
				print("Requested event: ", example_event))
		play(_build_example_dialogue())
	else:
		visible = false
	DialogueManager.scene_play_requested.connect(play)
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


func play(dialogue: Array[DialoguePage]) -> void:
	_curr_page = -1
	_dialogue = dialogue
	started.emit()
	visible = not dialogue.is_empty()
	if visible:
		_next()
	else:
		await get_tree().process_frame
		finished.emit()


func _next() -> void:
	if _curr_page > -1:
		var page: DialoguePage = _dialogue[_curr_page]
		_request_run_event(page.end_event)
	
	_curr_page += 1
	if _dialogue.size() - 1 >= _curr_page:
		var page: DialoguePage = _dialogue[_curr_page]
		_request_run_event(page.start_event)
		_say(page)
	else:
		visible = false
		finished.emit()


func _request_run_event(event_name: String) -> void:
	if event_name and not event_name.is_empty():
			event_requested.emit(event_name)


func _say(page: DialoguePage) -> void:
	if is_zero_approx(anchor_bottom):
		_name_container.visible = not page.character.is_empty()
	else:
		_name_container.modulate.a = 0.0 if page.character.is_empty() else 1.0
	_name_label.text = page.character
	_dialogue_label.text = page.line
	
	_next_page_anim_player.stop()
	_next_page_texture_rect.modulate.a = 0
	_dialogue_label.visible_characters = 0
	
	if _text_tween:
		_text_tween.kill()
	_text_tween = create_tween()
	var message_length: float = _dialogue_label.text.length()
	var duration: float = message_length / page.text_speed_chars_per_second
	_text_tween.tween_property(
			_dialogue_label, 
			"visible_characters", 
			message_length, 
			duration)
	await _text_tween.finished
	_next_page_anim_player.play(&"next_page")


func _build_example_dialogue() -> Array[DialoguePage]:
	var page_1: DialoguePage = DialoguePage.new()
	page_1.character = "Lorem"
	page_1.line = "Lorem ipsum dolor sit amet."
	var page_2: DialoguePage = DialoguePage.new()
	page_2.line = "Consectetur adipiscing elit."
	page_2.start_event = "example - start"
	page_2.end_event = "example - end"
	var page_3: DialoguePage = DialoguePage.new()
	page_3.character = "Ipsum"
	page_3.line = "Aliquam elementum id elit in consequat."
	page_3.text_speed_chars_per_second = 75.0
	return [page_1, page_2, page_3]


func _on_visibility_changed() -> void:
	set_process_unhandled_input(visible)
	if is_node_ready():
		_next_page_anim_player.stop()
