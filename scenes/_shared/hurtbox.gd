class_name Hurtbox
extends Area2D


signal hurt(hitbox: Hitbox)

@export var killer_groups: Array[String]
@export var invincible: bool


func _init() -> void:
	collision_layer = Constants.LAYER_NONE
	collision_mask = Constants.LAYER_HITBOX
	area_entered.connect(_on_area_entered)


func _on_area_entered(hitbox: Hitbox) -> void:
	if invincible or hitbox == null or hitbox.owner == owner:
		return
	
	var killer = hitbox.owner
	var is_victim_dead = owner.has_method("is_dead") and owner.is_dead()
	var hitbox_can_hurt = killer_groups.is_empty() or killer_groups.any(killer.is_in_group)
	if !is_victim_dead and hitbox_can_hurt:
		hurt.emit(hitbox)
		hitbox.on_successful_hit(self)
