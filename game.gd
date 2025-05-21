extends Node2D

@onready var healthbar = $Player/MobileControl/TextureProgressBar
@onready var player = $Player

func _ready() -> void:
	healthbar.max_value=player.health
	healthbar.value = healthbar.value
func _on_portal_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		get_tree().change_scene_to_file("res://quote_display.tscn")


func _on_player_health_changed(new_health: Variant) -> void:
		healthbar.value= new_health
