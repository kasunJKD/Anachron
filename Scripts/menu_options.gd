extends Control

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/MainMenu.tscn")


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
