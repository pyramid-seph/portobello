extends Control


@onready var _compiling_parent: Node2D = %CompilingParent


func _ready() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.DPAD_ONLY
	get_tree().create_timer(1.0).timeout.connect(_precompile_shaders)


func _precompile_shaders() -> void:
	await _compile_particle("res://scenes/_shared/blood_drop_particles.tscn")
	await _compile_particle("res://scenes/day_ex/player/dust_cloud.tscn")
	await _compile_texture_rect("res://scenes/day_ex/game/fighter.tscn")
	await get_tree().create_timer(1.0).timeout
	Game.start(Game.Minigame.TITLE_SCREEN, true)


func _compile_particle(path: String) -> void:
	var scene: PackedScene = ResourceLoader.load(path, "PackedScene")
	var scene_instance: GPUParticles2D = scene.instantiate()
	var faker: GPUParticles2D = GPUParticles2D.new()
	faker.texture = load("res://art/_shared/ui_bar_foreground.png")
	faker.process_material = scene_instance.process_material
	_compiling_parent.add_child(faker)
	await get_tree().create_timer(0.5).timeout
	faker.queue_free()
	while is_instance_valid(faker):
		await get_tree().process_frame


func _compile_texture_rect(path: String) -> void:
	var scene: PackedScene = ResourceLoader.load(path, "PackedScene")
	var scene_instance: TextureRect = scene.instantiate()
	var faker: TextureRect = TextureRect.new()
	faker.texture = load("res://art/_shared/ui_bar_foreground.png")
	faker.material = scene_instance.material
	_compiling_parent.add_child(faker)
	await get_tree().create_timer(0.5).timeout
	faker.queue_free()
	while is_instance_valid(faker):
		await get_tree().process_frame
