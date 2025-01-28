extends Area2D

@export var next_scene_path: String

func _on_body_entered(body: Node) -> void:
	# Check if the object that entered is indeed the Player.
	# If you prefer group-based detection, use `body.is_in_group("Player")` or similar.
	if body.name == "Player" and StateMech.shard:
		# Optionally, play a sound, show an animation, or do a fade-out before loading.
		
		# Example: Change the scene directly:
		get_tree().change_scene_to_file(next_scene_path)
		
		# Or, if you have a global "GameState" or "LevelManager", you can call:
		# LevelManager.go_to_scene(next_scene_path)
