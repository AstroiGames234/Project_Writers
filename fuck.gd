extends VBoxContainer



func _on_next_level_pressed() -> void:
	get_tree().change_scene_to_file("res://Level1.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
