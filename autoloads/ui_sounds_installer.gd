extends Node


const SKIP_FOCUS_SOUND: String = "__ui_sound_skip_focus"


@export var _max_depth: int = 16:
	set(value):
		_max_depth = maxi(value, 1)
@export var move_sound: AudioStream
@export var pressed_sound: AudioStream

var _curr_menu: Node:
	set(value):
		_disconnect_old_curr_menu(_curr_menu)
		_curr_menu = value


func _ready() -> void:
	var root = get_parent()
	# For this project, the scene that is running the current game 
	# is always the last one.
	_install_control_ui_sounds(Utils.last_child(root))
	root.child_entered_tree.connect(_on_root_child_entered_tree)
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)


func _disconnect_old_curr_menu(old_curr_menu: Node) -> void:
	if old_curr_menu:
		Utils.safe_disconnect(old_curr_menu.tree_exited, _on_menu_hidden)
		if old_curr_menu is Control:
			Utils.safe_disconnect(old_curr_menu.hidden, _on_menu_hidden)


func _play_sound(sound: AudioStream) -> void:
	if sound:
		SoundManager.play_ui_sound(sound)


func _connect_signals(node: Control) -> void:
	if not node:
		return
	
	if node is Button:
		Utils.safe_connect(node.pressed, _play_sound.bind(pressed_sound))
	elif node is HSelector:
		Utils.safe_connect(node.selected, _on_h_selector_selected)
		Utils.safe_connect(node.current_option_index_changed,
				_on_h_selector_current_option_index_changed.bind(node))


func _install_control_ui_sounds(parent_node: Node, depth: int = 0) -> void:
	if not parent_node or parent_node == self:
		return
	
	if depth >= _max_depth:
		Log.w("%s has reached max depth (%s)" % [name, _max_depth])
		return
	
	for child_node: Node in parent_node.get_children():
		_connect_signals(child_node as Control)
		_install_control_ui_sounds(child_node, depth + 1)


func _on_menu_hidden(menu: Node) -> void:
	# XXX Checking equality in case _on_gui_focus_changed 
	#  is called before _on_menu_hidden on the same frame.
	if _curr_menu and menu == _curr_menu:
		_curr_menu = null


func _on_gui_focus_changed(node: Control) -> void:
	if node is not Button and node is not HSelector:
		return
	
	if node.owner == _curr_menu:
		if not node.is_in_group(SKIP_FOCUS_SOUND):
			_play_sound(move_sound)
		return
	
	_curr_menu = node.owner
	if _curr_menu:
		Utils.safe_connect(_curr_menu.tree_exited,
				_on_menu_hidden.bind(_curr_menu), CONNECT_ONE_SHOT)
		if _curr_menu is Control:
			Utils.safe_connect(_curr_menu.hidden, 
					_on_menu_hidden.bind(_curr_menu), CONNECT_ONE_SHOT)


func _on_h_selector_current_option_index_changed(_index, node: Control) -> void:
	if node.is_visible_in_tree():
		_play_sound(move_sound)


func _on_h_selector_selected(_value) -> void:
	_play_sound(pressed_sound)


func _on_root_child_entered_tree(new_child: Node) -> void:
	_curr_menu = null
	_install_control_ui_sounds(new_child)
