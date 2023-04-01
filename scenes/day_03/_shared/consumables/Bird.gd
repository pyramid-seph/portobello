extends Area2D

const SCORE_POINTS: int = 50
const SPEED: float = 50.0
const DIRECTION: Vector2 = Vector2(1, 1)
const MIN_STAMINA: int = 5
const BASE_STAMINA: int = 20

var velocity: Vector2 = SPEED * DIRECTION

@onready var viewport_size: Vector2 = get_viewport_rect().size
@onready var viewport_width: float = viewport_size.x
@onready var viewport_height: float = viewport_size.y
@onready var sprite_width: float = $AnimatedSprite2D.sprite_frames.get_frame_texture("default", 0).get_width()
@onready var min_pos_x: float = 0.0
@onready var max_pos_x: float = viewport_width - sprite_width


func _ready() -> void:
	position.x = clamp(position.x, min_pos_x, max_pos_x)
	
	if randi() % 2 == 0:
		velocity.x *= -1


func _process(delta: float) -> void:
	_move(delta)
	_autoremove()


func _move(delta: float) -> void:
	if position.x > max_pos_x or position.x < min_pos_x:
		velocity.x *= -1
	position += velocity * delta


func _autoremove() -> void:
	if position.y >= viewport_height:
		queue_free()


func pick_up(picker: Node) -> void:
	if picker.has_method("add_points_to_score"):
		picker.add_points_to_score(SCORE_POINTS)
	if picker.has_method("add_stamina"):
		picker.add_stamina(randi() % BASE_STAMINA + MIN_STAMINA)
	queue_free()
