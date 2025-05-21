extends Node

@onready var pause_menu = $"../CanvasLayer/PauseMenu"
@onready var buttons = $"../CanvasLayer/PauseMenu/buttons"
var game_paused:bool = false
@onready var help_popup = $"../CanvasLayer/PauseMenu/HelpPopup"
var save_path = "user://savegame.save"
@onready var player = $"../Player"
@onready var skeleton = $"../Skeleton"
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("menu"):
		game_paused= !game_paused
	
	if game_paused == true:
		get_tree().paused=true
		pause_menu.show()
	else:
		get_tree().paused = false
		pause_menu.hide(	)


func _on_resume_pressed() -> void:
	game_paused= !game_paused



func _on_quit_pressed() -> void:
	get_tree().paused=false
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_menu_button_pressed() -> void:
	game_paused= !game_paused

func save_game():
	var file = FileAccess.open(save_path, FileAccess.WRITE)

	# Сохраняем текущую сцену
	var current_scene_path = get_tree().current_scene.scene_file_path
	file.store_var(current_scene_path)

	# Сохраняем данные игрока и врага
	file.store_var(player.position.x)
	file.store_var(player.position.y)
	file.store_var(player.health)
	file.store_var(skeleton.health)

func load_game():
	if not FileAccess.file_exists(save_path):
		print("Файл сохранения не найден")
		return

	var file = FileAccess.open(save_path, FileAccess.READ)

	# Загружаем сцену и данные
	var scene_path = file.get_var()
	var position_x = file.get_var(player.position.x)
	var position_y = file.get_var(player.position.y)
	var saved_player_health = file.get_var()
	var saved_skeleton_health = file.get_var()

	# Загружаем сцену
	var packed_scene = load(scene_path)
	var new_scene = packed_scene.instantiate()

	get_tree().root.add_child(new_scene)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = new_scene

	# Ждём один кадр, чтобы сцена загрузилась
	await get_tree().process_frame

	# Получаем игрока и скелета на новой сцене
	

	# Восстанавливаем параметры
	player.position.x = position_x
	player.position.y = position_y
	player.health = saved_player_health
	skeleton.health = saved_skeleton_health


func _on_save_pressed() -> void:
	save_game()
	game_paused = !game_paused


func _on_load_pressed() -> void:
	load_game()
	game_paused = !game_paused


func _on_help_pressed() -> void:
	buttons.play()
	await buttons.finished
	help_popup.popup_centered()
	


func _on_close_help_pressed() -> void:
	buttons.play()
	await buttons.finished
	help_popup.hide()
