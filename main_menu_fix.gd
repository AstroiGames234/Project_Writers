extends Node3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$SettingsMenu.back_pressed.connect(_on_settings_back)
	
func _on_settings_back():
	$SettingsMenu.visible = false
	$VBoxContainer.visible = true
	$Label.visible = true
	$Label2.visible = true
	$Label3.visible = true
	$VBoxContainer2.visible = true
