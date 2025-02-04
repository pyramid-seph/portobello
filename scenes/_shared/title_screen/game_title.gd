extends TextureRect


@export var normal_title: Texture2D
@export var bloody_title: Texture2D
@export var stars_count: int:
	set(value):
		var old_value = stars_count
		stars_count = maxi(value, 0)
		if old_value != stars_count:
			_on_stars_count_changed()

@onready var _stars_label := $StarsLabel as Label
@onready var _blood_drops: Node2D = $BloodDrops


func _ready() -> void:
	_on_stars_count_changed()


func set_story_mode_progress(max_day_completed: int) -> void:
	if max_day_completed < 2:
		texture = normal_title
		_emit_blood_drop_particles(false)
	else:
		texture = bloody_title
		_emit_blood_drop_particles(true)


func _emit_blood_drop_particles(emit: bool) -> void:
	for blood_drop_spawner: GPUParticles2D in _blood_drops.get_children():
		blood_drop_spawner.emitting = emit


func _on_stars_count_changed() -> void:
	if not is_node_ready():
		return
	
	var stars_text: String = ""
	for i: int in stars_count:
		stars_text += "*"
	_stars_label.text = stars_text
