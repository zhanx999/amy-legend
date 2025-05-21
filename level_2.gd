extends Node2D

@onready var healthbar = $Player/MobileControl/TextureProgressBar2
@onready var player = $Player
func _ready() -> void:
	healthbar.max_value=player.health
	healthbar.value = healthbar.value
func _on_player_health_changed(new_health: Variant) -> void:
		healthbar.value= new_health
