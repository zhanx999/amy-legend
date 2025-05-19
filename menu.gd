extends Control


@onready var buttons = $buttons
func _on_start_pressed() -> void:
	buttons.play()
	await buttons.finished
	get_tree().change_scene_to_file("res://game.tscn")


func _on_exit_pressed() -> void:
	buttons.play()
	await buttons.finished
	get_tree().quit()

func _on_help_pressed() -> void:
	buttons.play()
	await buttons.finished
	$HelpPopup.popup_centered()


func _on_close_help_pressed() -> void:
	buttons.play()
	await buttons.finished
	$HelpPopup.hide()
