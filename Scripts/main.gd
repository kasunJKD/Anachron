extends Node

@onready var player = $Player
@onready var tilemap_past = $Past_Map
@onready var tilemap_present = $Map
@onready var timeswitch_sfx: AudioStreamPlayer2D = $timeswitch_sfx
func _ready() -> void:
	# 1) Make sure tilemaps match the initial 'is_in_past' value
	update_time_travel_visibility(StateMech.is_in_past)

	# 2) Whenever 'is_in_past' changes, call our handler
	StateMech.is_in_past_changed.connect(_on_is_in_past_changed)

	# 3) Clear and store initial game state (optional)
	StateMech.game_state_history.clear()
	StateMech.store_game_state()

	# 4) Connect signals for all triggers in the group
	var triggers = get_tree().get_nodes_in_group("time_travel_triggers")
	for trigger in triggers:
		trigger.player_stepped_on_battery.connect(_on_time_travel_trigger_player_stepped_on_battery)
		trigger.player_stepped_off_battery.connect(_on_time_travel_trigger_player_stepped_off_battery)

func _on_time_travel_trigger_player_stepped_on_battery() -> void:
	# Typically you want to set this to 'true', not toggle.
	# If you prefer toggling, that's fine but might be confusing.
	StateMech.on_time_travel_battery = true
	print("Player stepped on a time travel battery!")

func _on_time_travel_trigger_player_stepped_off_battery() -> void:
	StateMech.on_time_travel_battery = false
	print("Player stepped off a time travel battery!")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# Only allow time travel if on_time_travel_battery is true
		if StateMech.on_time_travel_battery:
			if event.keycode == KEY_T:
				timeswitch_sfx.play()
				# Toggle is_in_past (this will emit the signal automatically)
				StateMech.is_in_past = not StateMech.is_in_past
				# The _on_is_in_past_changed callback will do tilemap updates

func _on_is_in_past_changed(new_value: bool) -> void:
	# Update tilemaps, store state, etc., whenever is_in_past changes
	update_time_travel_visibility(new_value)
	StateMech.store_game_state()

func set_characters_active(active: bool, map: Node2D) -> void:
	for child in map.get_children():
		if child is CharacterBody2D:
			if active:

				# Or whichever bits you used originally

				# Resume script processing
				child.set_process(true)
				child.set_physics_process(true)
			else:


				# Stop script processing
				child.set_process(false)
				child.set_physics_process(false)

func update_time_travel_visibility(is_past: bool) -> void:
	# If we're in the past:
	if is_past:
		# Show + enable collisions for past map
		tilemap_past.visible = true
		set_characters_active(true, tilemap_past)
		tilemap_past.get_node("TileMapLayer").enabled = true

		# Hide + disable collisions for present map
		tilemap_present.visible = false
		set_characters_active(false, tilemap_present)
		tilemap_present.get_node("BaseLayer").enabled = false

	else:
		# Show + enable collisions for present map
		tilemap_past.visible = false
		set_characters_active(false, tilemap_past)
		tilemap_past.get_node("TileMapLayer").enabled = false

		tilemap_present.visible = true
		set_characters_active(true, tilemap_present)
		tilemap_present.get_node("BaseLayer").enabled = true
