extends MarginContainer

@onready var label: Label = $MarginContainer/Label
@onready var timer: Timer = $LetterDisplayTimer

@export var scene_next: String      # Next scene to load when done
@export var message: String         # Comma-separated messages
@export var letter_rate := 0.2      # Seconds between each typed letter
@export var delay_between_messages := 1.0  # Delay before starting each new message

var messages = []
var current_message_index = 0
var letter_index = 0
var is_typing = false
var letter_accumulator = 0.0

func _ready() -> void:
	# Enable _process() callback
	set_process(true)

	if message.strip_edges() != "":
		messages = message.split(",")
		if messages.size() > 0:
			# Start the first message *after* a short delay
			call_deferred("_delay_then_start_message")
		else:
			print("No messages to display.")
	else:
		print("Message string is empty.")

# Called (deferred) after _ready() to start the very first message
func _delay_then_start_message() -> void:
	# Wait for the initial delay before starting the first message
	await get_tree().create_timer(delay_between_messages).timeout
	_start_typing_message(messages[current_message_index])

func _start_typing_message(msg: String) -> void:
	is_typing = true
	letter_accumulator = 0.0
	letter_index = 0
	label.text = ""

func _process(delta: float) -> void:
	if not is_typing:
		return

	letter_accumulator += delta
	if letter_accumulator >= letter_rate:
		letter_accumulator -= letter_rate
		
		var current_msg = messages[current_message_index]
		if letter_index < current_msg.length():
			label.text += current_msg[letter_index]
			letter_index += 1
		else:
			# Current message finished
			is_typing = false
			current_message_index += 1
			if current_message_index < messages.size():
				# Start the next message after a delay
				call_deferred("_delay_then_start_next_message")
			else:
				# No more messages; go to next scene
				_go_to_next_scene()

func _delay_then_start_next_message() -> void:
	# Wait before starting the next message
	await get_tree().create_timer(delay_between_messages).timeout
	_start_typing_message(messages[current_message_index])

func _on_next_pressed() -> void:
	# If we press Next *during* typing, skip to the end of the current message
	if is_typing:
		label.text = messages[current_message_index]
		is_typing = false
	else:
		# If we're not typing, move immediately to the next message
		current_message_index += 1
		if current_message_index < messages.size():
			call_deferred("_delay_then_start_next_message")
		else:
			_go_to_next_scene()

func _on_skip_pressed() -> void:
	# Immediately jump to the next scene (no delay)
	_go_to_next_scene()

func _go_to_next_scene() -> void:
	if scene_next != "":
		get_tree().change_scene_to_file(scene_next)
	else:
		print("No next scene set. Dialog ends here.")
