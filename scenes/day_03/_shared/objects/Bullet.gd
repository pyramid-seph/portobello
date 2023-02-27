extends Area2D

@export var speed: float = 0.0
@export var direction: Vector2 = Vector2.ZERO

var shooter:
	set(value):
		_shooter = weakref(value)
	get:
		return _shooter.get_ref()

var _shooter: WeakRef


func _init() -> void:
	set_as_top_level(true)


func _ready() -> void:
	if not get_viewport_rect().has_point(global_position):
		process_mode = Node.PROCESS_MODE_DISABLED
		queue_free()


func _process(delta: float) -> void:
	position += direction * speed * delta


func _on_area_entered(_area: Area2D) -> void:
	# FIXME: Bullets don't disppear after colliding with player
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
