extends PanelContainer

signal acknowledged

@onready var _narration_label: RichTextLabel = %NarrationLabel
@onready var _next_page_texture_rect: TextureRect = %NextPageTextureRect
@onready var _next_page_anim_player: AnimationPlayer = $NextPageAnimationPlayer


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		accept_event()
		release_focus()
		acknowledged.emit()


func say(what: String) -> void:
	_narration_label.text = what


func silence() -> void:
	_narration_label.text = ""


func _on_focus_entered() -> void:
	_next_page_texture_rect.modulate.a = 1
	_next_page_anim_player.play("next_page")


func _on_focus_exited() -> void:
	_next_page_texture_rect.modulate.a = 0
	_next_page_anim_player.stop()
