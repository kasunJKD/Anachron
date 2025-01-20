extends Area2D

signal player_stepped_on_water
signal player_stepped_on_electricity
@onready var water_death_sfx: AudioStreamPlayer2D = $water_death_sfx
@onready var electric_death_sfx: AudioStreamPlayer2D = $electric_death_sfx

@export var area_type: String 

func _ready() -> void:
	pass

# Replace with function body.
func _on_body_entered(body: CharacterBody2D) -> void:
	# Ensure the body is the Player by checking group membership
	print(body)
	if body.name == "Player" or body.is_in_group("boxes"):
		match area_type:
			"Water":
				water_death_sfx.play()
				emit_signal("player_stepped_on_water")
				# Additional logic for water death
				# e.g., StateMech.handle_player_death("Water")
			"Electric":
				electric_death_sfx.play()
				emit_signal("player_stepped_on_electricity")
