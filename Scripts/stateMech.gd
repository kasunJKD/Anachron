extends Node

var game_state_history: Array = []
var player_ref = null  # We'll store a reference to the Player node here (optional)
var on_time_travel_battery = false

signal is_in_past_changed(new_value)

# Instead of a simple var, use a setter
var _is_in_past: bool = false

# This property is what other scripts will read/write:
var is_in_past:
	get:
		return _is_in_past
	set(value):
		if _is_in_past != value:
			_is_in_past = value
			emit_signal("is_in_past_changed", _is_in_past)

func _ready() -> void:
	# Runs once when the game starts or when this script is loaded as an Autoload.
	pass

# You can call this after the player is ready, or in the player's _ready() itself:
func register_player(player) -> void:
	player_ref = player

func reset_state() -> void:
	game_state_history.clear()

func store_game_state() -> void:
	# Make sure we have a valid player reference
	if player_ref == null:
		return

	# Build a "snapshot" Dictionary of all relevant data.
	# You can add as many key-value pairs as needed (e.g. "player_score", "inventory", etc.).
	var snapshot = {
		"player_position": player_ref.position,
		"player_target_position": player_ref.target_position,
		"is_in_past": is_in_past
	}

	print(snapshot)
	# Add this snapshot to the stack
	game_state_history.append(snapshot)

func rewind_state() -> void:
	# We need at least 2 snapshots to rewind:
	#   1) The current state (top of the stack)
	#   2) The previous state to restore
	if game_state_history.size() > 1:
		# Remove the current state
		game_state_history.pop_back()

		# Get the new top (previous snapshot)
		var previous_snapshot = game_state_history[game_state_history.size() - 1]
		load_game_state(previous_snapshot)
	else:
		print("No previous state to rewind to!")

func load_game_state(snapshot: Dictionary) -> void:
	if player_ref == null:
		return
	# Restore the player's position (expand to restore more data as needed)
	player_ref.position = snapshot["player_position"]
	player_ref.target_position = snapshot["player_target_position"]
	is_in_past = snapshot["is_in_past"]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_undo"):
		# Rewind to previous state
		rewind_state()
		
