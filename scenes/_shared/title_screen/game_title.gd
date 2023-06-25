extends TextureRect


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


func _on_stars_count_changed() -> void:
	if not _is_ready:
		return
	
	var stars_text: String = ""
	for i in stars_count:
		stars_text += "*"
	_stars_label.text = stars_text

