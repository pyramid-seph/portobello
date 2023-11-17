extends TextureRect


@export var normal_title: Texture2D
@export var bloody_title: Texture2D
@export var stars_count: int:
	set(value):
		var old_value = stars_count
		stars_count = maxi(value, 0)
		if old_value != stars_count:
			_on_stars_count_changed()

@onready var _is_ready: bool = true
@onready var _stars_label := $StarsLabel as Label


func _ready() -> void:
	_on_stars_count_changed()


func set_story_mode_progress(max_day_completed: int) -> void:
	texture = normal_title if max_day_completed < 2 else bloody_title


func _on_stars_count_changed() -> void:
	if not _is_ready:
		return
	
	var stars_text: String = ""
	for i in stars_count:
		stars_text += "*"
	_stars_label.text = stars_text
