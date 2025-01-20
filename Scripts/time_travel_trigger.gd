extends Area2D

signal player_stepped_on_battery
signal player_stepped_off_battery
@onready var chargeup_sfx: AudioStreamPlayer2D = $chargeup
@onready var chargedown_sfx: AudioStreamPlayer2D = $chargedown
func _ready() -> void:
	# If you have many such triggers, put them in a group for easy finding:
	add_to_group("time_travel_triggers")
	# Connect Godot’s built-in body_entered signal to our local method
	#body_entered.connect(_on_body_entered)

func _on_body_entered(body: CharacterBody2D) -> void:
	# Only emit our custom signal if the entering body is the Player
	if body.name == "Player":
		chargeup_sfx.play()
		emit_signal("player_stepped_on_battery") # Replace with function body.


func _on_body_exited(body: CharacterBody2D) -> void:
	if body.name == "Player":
		#chargedown_sfx.play()
		emit_signal("player_stepped_off_battery")
