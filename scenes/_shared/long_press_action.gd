## Detects a long pressed action.
##
## Determines whether a long press action is completed or canceled.
## You can use signals or functions to respond to input events.
## [br]
## [br]
## Example usage:
## [codeblock]
## extends CharacterController2D
##
## var long_press_attack = LongPressAction.new("attack", 1.0,
##         LongPressAction.CheckMode.ON_RELEASE)
##
##
## func _ready():
##     long_press_attack.started.connect(_play_charging_attack_animation)
##     long_press_attack.canceled.connect(_do_normal_attack)
##     long_press_attack.completed.connect(_do_charged_attack)
##
## 
## func _process(delta):
##     long_press_attack.update(delta)
## [/codeblock]
class_name LongPressAction
extends RefCounted


## The player just pressed the action.
signal started
## The player long pressed the action.
signal completed
## The player released the action before a long press is completed.
signal canceled

enum LongPressState {
	NONE,
	STARTED,
	IN_PROGRESS,
	COMPLETED,
	CANCELED,
}

## Determines when to check for long press completion.
enum CheckMode {
	ON_PRESS,
	ON_RELEASE,
}

## Minimum time in seconds required for long press. Setting this value
## does [b]NOT[/b] reset the long press state.
var press_threshold: float
## If [code]true[/code], stops tracking long presses for this action and resets
## the long press state. This reset does [b]NOT[/b] emit a canceled signal.
## Defaults to [code]false[/code].
var disabled: bool:
	set(value):
		disabled = value
		if disabled:
			reset()
## If present, it will be used to stop propagating the input when appropriate.
var viewport: Viewport

var _action: StringName
var _check_mode: CheckMode
var _press_duration: float
var _state: LongPressState

## Creates a fully configured [LongPressAction].
func _init(action: StringName, press_threshold_sec: float,
		check_mode: CheckMode) -> void:
	_action = action
	_check_mode = check_mode
	press_threshold = press_threshold_sec


## Call this function once on [method Node._process] or on 
## [method Node._physics_process] to update the long press state.
func update(delta: float) -> void:
	if disabled:
		return
	
	match _state:
		LongPressState.STARTED:
			_state = LongPressState.IN_PROGRESS
		LongPressState.COMPLETED, LongPressState.CANCELED:
			reset()
	
	if Input.is_action_just_pressed(_action):
		_stop_input_propagation()
		_state = LongPressState.STARTED
		_press_duration = 0.0
		started.emit()
		return
	
	if _state != LongPressState.IN_PROGRESS:
		return
	
	if Input.is_action_pressed(_action):
		_stop_input_propagation()
		_press_duration += delta
		if _check_mode == CheckMode.ON_PRESS and is_pressed_long_enough():
			_state = LongPressState.COMPLETED
			completed.emit()
	elif _check_mode == CheckMode.ON_RELEASE and is_pressed_long_enough():
		_state = LongPressState.COMPLETED
		completed.emit()
	else:
		_state = LongPressState.CANCELED
		canceled.emit()


func get_tracked_action() -> StringName:
	return _action


func get_check_mode() -> CheckMode:
	return _check_mode


## Resets the state of a long press to [enum LongPressAction.LongPressState.NONE]
## and sets the press duration to zero. Does [b]NOT[/b] emit a [signal canceled]
## signal.
func reset() -> void:
	_press_duration = 0.0
	_state = LongPressState.NONE


## Returns [code]true[/code] if the player started pressing the action
## in the current update; [code]false[/code] otherwise.
func is_started() -> bool:
	return _state == LongPressState.STARTED


## Returns [code]true[/code] if the player long pressed the action in the
## current update; [code]false[/code] otherwise.
func is_completed() -> bool:
	return  _state == LongPressState.COMPLETED


## Returns [code]true[/code] if the player released the action in the current
## update before a long press is completed; [code]false[/code] otherwise.
func is_canceled() -> bool:
	return _state == LongPressState.CANCELED


## Returns the time in seconds an action has been held down. Resets to zero at 
## the start of a long press attempt and in the next update after a long press
## is canceled or completed.
func get_press_duration() -> float:
	return _press_duration


## Returns [code]true[/code] if a long press is attempted in the current update,
## i.e. its state is not [enum LongPressAction.LongPressState.NONE];
## [code]false[/code] otherwise.
func is_attempted() -> bool:
	return _state != LongPressState.NONE


## Returns the progress of the current long press attempt as a value between
## 0 and 1. Returns 0 if [member press_threshold] is zero or negative.
func get_progress() -> float:
	var progress: float = 0.0
	if press_threshold > 0.0:
		progress = minf(1.0, _press_duration / press_threshold)
	return progress


## Returns [code]true[/code] if the player held down the action for at least
## the time indicated on [member press_threshold].
func is_pressed_long_enough() -> bool:
	return _press_duration >= press_threshold


func _stop_input_propagation() -> void:
	if viewport:
		viewport.set_input_as_handled()
