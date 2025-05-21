extends Control

@onready var quote_label = $Panel/QuoteLabel
@onready var button = $Panel/Button
@onready var http_request = $Panel/HTTPRequest
const API_URL = "https://meowfacts.herokuapp.com/"

func _ready():
	http_request.request(API_URL)  # Загружаем цитату при запуске
	button.pressed.connect(_on_button_pressed)
	http_request.request_completed.connect(_on_http_request_request_completed)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var data = JSON.parse_string(body.get_string_from_utf8())
	var random_quote = data.data[0]
	quote_label.text = random_quote

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://level_2.tscn")  # Замени путь на нужный
