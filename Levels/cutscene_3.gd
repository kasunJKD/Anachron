extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var next_scene_path: String = "res://Levels/level3.tscn"

func _ready() -> void:
	# Play the animation when the scene is ready
	animation_player.play("d3")

# Called automatically when the 'animation_finished' signal is emitted
func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "d3":
		# Once the animation is done, wait 1 second, then go to the next scene
		# 'await' is Godot 4+ syntax. For Godot 3, see the 'yield' example below.
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file(next_scene_path)
