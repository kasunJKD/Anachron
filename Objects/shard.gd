extends Area2D

@onready var pickup_sfx: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_body_entered(body: Node) -> void:
	# Only pick up if this is the Player (or whichever node you consider the collector).
	if body.name == "Player":
		# 1) Optionally: Increase a shard counter in your game manager
		# GameManager.increase_shard_count(1)
		
		# 2) Play the pickup sound
		pickup_sfx.play()

		# 3) Hide the shard visually and stop collisions
		#    so the player won't trigger it again while sound is playing.
		visible = false

		# We'll actually remove the Shard (queue_free) once the sound finishes.

func _on_audio_stream_player_2d_finished() -> void:
	StateMech.shard = true
	queue_free() # Replace with function body.
