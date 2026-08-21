extends VBoxContainer





func _on_resume_pressed() -> void:
	pass 


func _on_settings_pressed() -> void:
	pass 


func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
