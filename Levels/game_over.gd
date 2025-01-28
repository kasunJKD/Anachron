extends Control


func _on_button_pressed() -> void:
	# 1) Get the stored path from your global/autoload script
	var prev_scene = StateMech.previous_scene_path

	# 2) If it's not empty, change to that scene:
	if prev_scene != "":
		get_tree().change_scene_to_file(prev_scene)
	else:
		print("No previous scene stored!")
		
func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/MainMenu.tscn") # Replace with function body.
