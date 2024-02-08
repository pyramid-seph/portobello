extends CharacterBody2D


@export var speed: float = 25 # Original game is 33.33333333
@export var on_slippery_floor: bool

@onready var _animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	var direction: Vector2 = _get_input()
	var motion: Vector2 = speed * direction * delta
	if move_and_collide(motion):
		direction = Vector2.ZERO
	_update_animation(direction)
 

func _get_input() -> Vector2:
	var input: Vector2
	if Input.is_action_pressed("move_up"):
		input = Vector2.UP
	elif Input.is_action_pressed("move_down"):
		input = Vector2.DOWN
	elif Input.is_action_pressed("move_left"):
		input = Vector2.LEFT
	elif Input.is_action_pressed("move_right"):
		input = Vector2.RIGHT
	else:
		input = Vector2.ZERO
	return input


func _update_animation(direction: Vector2) -> void:
	var animation: String = _animated_sprite_2d.animation
	var flip_h: bool = _animated_sprite_2d.flip_h
	var flip_v: bool = _animated_sprite_2d.flip_v
	if direction == Vector2.ZERO:
		if not animation.begins_with("iddle_"):
			if animation == "move_horizontal":
				animation = "iddle_horizontal"
			else:
				animation = "iddle_vertical"
	else:
		flip_h = direction.x < 0
		flip_v = direction.y > 0
		if direction == Vector2.LEFT or direction == Vector2.RIGHT:
			animation = "move_horizontal"
		else:
			animation = "move_vertical"
	_animated_sprite_2d.play(animation)
	_animated_sprite_2d.flip_h = flip_h
	_animated_sprite_2d.flip_v = flip_v
