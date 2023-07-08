class_name Day01LevelSettings
extends Resource

enum ObstacleCourseType {
	NONE,
	DEFAULT,
	RANDOM,
}

@export var pace_sec: float
@export var stamina_sec: float
@export var obstacle_course_type: ObstacleCourseType
@export var inverted_controls: bool
@export var max_lives: int = 9
@export var treats: int
@export var dialogue: Array[DialogueLine]


func is_time_limited() -> bool:
	return stamina_sec > 0


func is_score_attack() -> bool:
	return treats < 1
