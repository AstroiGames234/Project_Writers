extends Control

@onready var menu_buttons: Control = $VBoxContainer
@onready var settings_menu: Control = $SettingsMenu

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings_menu.back_pressed.connect(_on_settings_back)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	visible = not visible
	get_tree().paused = visible

	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_pressed() -> void:
	toggle_pause()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_settings_pressed() -> void:
	menu_buttons.visible = false
	settings_menu.visible = true
	$Label.visible = false

func _on_settings_back() -> void:
	settings_menu.visible = false
	menu_buttons.visible = true
	$Label.visible = true
