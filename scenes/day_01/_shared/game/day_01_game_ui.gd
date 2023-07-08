extends Control


signal start_level_finished
signal game_over_finished

@onready var _is_ready := true
@onready var _lives_counter := $LivesCounter/Label as Label
@onready var _treats_counter := $TreatsCounter/Label as Label
@onready var _stamina_bar := %ProgressBar as TextureProgressBar
@onready var _stamina_bar_container = $StaminaBar


func update_treats_counter(value: int) -> void:
	_treats_counter.text = str(value)


func update_lives_counter(value: int) -> void:
	_lives_counter.text = str(value)


func update_stamina_bar(value: float) -> void:
	_stamina_bar.value = value * _stamina_bar.max_value


func set_is_stamina_bar_visible(value: bool) -> void:
	_stamina_bar_container.visible = value
