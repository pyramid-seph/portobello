extends HBoxContainer

const NORMAL_COLOR = Color8(250, 172, 88)

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var progress_bar := $ProgressBar


func _on_Day3Ui_power_up_changed(new_val: float, max_val: float):
	progress_bar.value = new_val * progress_bar.max_value / max_val

	if new_val == 0:
		anim_player.stop()
		progress_bar.set_tint_progress(NORMAL_COLOR)
	elif new_val == max_val:
		anim_player.play("max_power_up_reached")
