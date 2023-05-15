extends Node

@export var is_cold_boot: bool = true

@onready var _title_screen = $TitleScreen
@onready var _logos_roll := $LogosRoll
@onready var _story_mode_game_selector = %StoryModeGameSelector


func _ready() -> void:
	if is_cold_boot:
		_enable_title_screen(false)
		_logos_roll.start()
	else:
		_enable_title_screen(true)


func _enable_title_screen(value: bool) -> void:
	_title_screen.visible = value
	if not value:
		_title_screen.process_mode = Node.PROCESS_MODE_DISABLED 
	else:
		_title_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	_story_mode_game_selector.call_deferred("grab_focus")


func _on_logos_roll_rolled() -> void:
	_logos_roll.visible = false
	_enable_title_screen(true)


func _on_story_mode_game_selector_selected(idx: int) -> void:
	pass # Replace with function body.


func _on_score_attack_game_selector_selected(idx: int) -> void:
	pass # Replace with function body.


func _on_show_scores_btn_pressed() -> void:
	pass # Replace with function body.


func _on_show_options_btn_pressed() -> void:
	pass # Replace with function body.
