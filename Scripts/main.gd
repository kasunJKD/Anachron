extends Node

# References to important objects:
@onready var player = $Player
@onready var tilemap_past = $Past_Map
@onready var tilemap_present = $Map
#@onready var other_object = $SomeOtherObject

func _ready():
	tilemap_past.visible = false
	tilemap_present.visible = true
	StateMech.game_state_history.clear()
	StateMech.store_game_state()
	
	# 1) Get all triggers in the scene. They are in the group "time_travel_triggers."
	var triggers = get_tree().get_nodes_in_group("time_travel_triggers")

	# 2) Connect each trigger’s signal to our local callback.
	for trigger in triggers:
		trigger.connect("player_stepped_on_battery", _on_time_travel_trigger_player_stepped_on_battery)

	# Here you could toggle the tilemaps, call time travel logic, etc.


func _on_time_travel_trigger_player_stepped_on_battery() -> void:
	print("Player stepped on a time travel battery!") # Replace with function body.
