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
	# 1) If a box enters, destroy it.
	if body.is_in_group("boxes"):
		body.queue_free()
		return
	if body.is_in_group("boxes2"):
		body.queue_free()
		return
	
	# 2) If the Player enters, trigger a "game over" or special event.
	if body.name == "Player":
		match area_type:
			"Water":
				water_death_sfx.play()
				emit_signal("player_stepped_on_water")
				get_tree().change_scene_to_file("res://Levels/GameOver.tscn")
				# TODO: Add your game-over logic here, e.g.
				# StateMech.handle_player_death("Water")
				
			"Electric":
				electric_death_sfx.play()
				emit_signal("player_stepped_on_electricity")
				# TODO: Add your game-over logic here, e.g.
				# StateMech.handle_player_death("Electric")
