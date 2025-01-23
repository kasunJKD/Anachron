extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var next_scene_path: String
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D2

func _ready() -> void:
	# Play the animation when the scene is ready
	animation_player.play("d4")
	audio_player.play()
