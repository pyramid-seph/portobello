class_name HurtBox
extends Area2D

signal hurt(who)
signal invincibility_started
signal invincibility_ended


export(bool) var disabled := false setget set_disabled

onready var invincibility_timer := $InvincibilityTimer
onready var collision_shape := $CollisionShape2D

func _ready():
	collision_shape.set_deferred("disabled", disabled)


func set_disabled(value) -> void:
	disabled = value
	collision_shape.set_deferred("disabled", disabled)
	if disabled and not invincibility_timer.is_stopped():
		invincibility_timer.stop()


func start_timed_invincibility(invincibility_duration) -> void:
	assert(not disabled, "Cannot start timed invisibility when disabled.")
	if not is_invincible():
		invincibility_timer.start(invincibility_duration)
		emit_signal("invincibility_started")


func is_invincible() -> bool:
	return not invincibility_timer.is_stopped()


func _on_HurtBox_area_entered(area: Area2D) -> void:
	if is_invincible():
		 return

	emit_signal("hurt", area)


func _on_InvincibilityTimer_timeout():
	emit_signal("invincibility_ended")
