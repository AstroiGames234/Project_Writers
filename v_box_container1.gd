extends VBoxContainer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
