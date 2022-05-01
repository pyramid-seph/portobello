extends HBoxContainer

const NORMAL_COLOR = Color8(250, 172, 88)

export var max_power_up_count := 5

onready var anim_player = $AnimationPlayer
onready var progress_bar = $ProgressBar


func _on_Day3Ui_power_up_changed(new_val):
	progress_bar.value = new_val * progress_bar.max_value / max_power_up_count

	if new_val == 0:
		anim_player.stop()
		progress_bar.set_tint_progress(NORMAL_COLOR)
	elif new_val == max_power_up_count:
		anim_player.play("max_power_up_reached")
