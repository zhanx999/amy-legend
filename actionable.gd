extends Area2D

const Balloon = preload("res://dialog/balloon.tscn")

# Called when the node enters the scene tree for the first time.
@export var dialogue_resourse: DialogueResource
@export var dialogue_start:String = "start"


func action() -> void:
	var balloon: Node = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	DialogueManager.show_dialogue_balloon(dialogue_resourse, dialogue_start)
	
	# Подключаем сигнал завершения диалога
	DialogueManager.connect("dialogue_ended", Callable(self, "_on_dialogue_ended"))
func _on_dialogue_ended(_data = null):
	var player = $"../../Player"
	player.global_position = Vector2(3000, 500)
