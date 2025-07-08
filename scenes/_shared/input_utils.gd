class_name InputUtils
extends RefCounted


enum InputDevice {
	GAMEPAD,
	KEYBOARD,
	TOUCHSCREEN,
}


static func is_player_1_joypad_connected() -> bool:
	# Input events are mapped only to the device 0.
	return 0 in Input.get_connected_joypads()


static func get_main_input_device() -> InputDevice:
	if is_player_1_joypad_connected():
		return InputDevice.GAMEPAD
	elif DisplayServer.is_touchscreen_available():
		return InputDevice.TOUCHSCREEN
	else:
		return InputDevice.KEYBOARD
