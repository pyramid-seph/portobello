extends Node2D

@export var score_points_gun: int = 0
@export var score_points_mega_gun: int = 0
@export var speed: float = 0.0
@export var direction: Vector2 = Vector2.ZERO

var shooter:
	set(value):
		_shooter = weakref(value)
	get:
		return _shooter.get_ref() if _shooter else null

var _shooter: WeakRef


func _ready() -> void:
	if not get_viewport_rect().has_point(global_position):
		process_mode = Node.PROCESS_MODE_DISABLED
		queue_free()


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func kill(killer: Node, killed_by_mega_gun: bool = false) -> void:
	if killer and killer.has_method("add_points_to_score"):
		killer.add_points_to_score(
			score_points_mega_gun if killed_by_mega_gun else score_points_gun
		)
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_hitbox_hit(_hitbox: Hitbox, _hurtbox: Hurtbox) -> void:
	queue_free()
