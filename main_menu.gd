extends VBoxContainer

const WORLD = preload("res://level_select_screen.tscn")



func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(WORLD)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_patch_pressed() -> void:
	get_tree().change_scene_to_file("res://patch_notes.tscn")


func _on_info_pressed() -> void:
	get_tree().change_scene_to_file("res://info.tscn")
