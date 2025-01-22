extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D
func _ready():
	# Play the animation when the scene is ready
	animation_player.play("Menu")
	audio_player .play()
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/startcutscene.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/MenuOptions.tscn")
