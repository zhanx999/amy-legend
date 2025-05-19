extends Control


@onready var username_field = $VBoxContainer/Username
@onready var password_field = $VBoxContainer/Password
@onready var message_label = $VBoxContainer/Message

const USERS_FILE = "user://users.cfg"


func _on_login_pressed() -> void:
	var username = username_field.text
	var password = password_field.text

	var config = ConfigFile.new()
	if config.load(USERS_FILE) == OK:
		if config.has_section_key("users", username):
			var saved_password = config.get_value("users", username)
			if saved_password == password:
				message_label.text = "Вход выполнен!"
				
				get_tree().change_scene_to_file("res://menu.tscn")
			else:
				message_label.text = "Неверный пароль"
		else:
			message_label.text = "Пользователь не найден"
	else:
		message_label.text = "Ошибка чтения данных"


func _on_register_pressed() -> void:
	var username = username_field.text
	var password = password_field.text

	if username.is_empty() or password.is_empty():
		message_label.text = "Введите имя и пароль"
		return

	var config = ConfigFile.new()
	config.load(USERS_FILE)

	if config.has_section_key("users", username):
		message_label.text = "Пользователь уже существует"
		return

	config.set_value("users", username, password)
	config.save(USERS_FILE)
	message_label.text = "Регистрация успешна"
