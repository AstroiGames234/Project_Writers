extends Control

signal back_pressed
@onready var master_slider: HSlider = $TabContainer/Audio/MasterVolumeSlider
@onready var music_slider: HSlider = $TabContainer/Audio/MusicVolumeSlider
@onready var sfx_slider: HSlider = $TabContainer/Audio/SFXVolumeSlider
@onready var fullscreen_check: CheckBox = $TabContainer/Video/FullscreenCheckBox
@onready var vsync_check: CheckBox = $TabContainer/Video/VSyncCheckBody
@onready var sensitivity_slider: HSlider = $TabContainer/Control/SensitivitySlider

func _ready() -> void:
	master_slider.value = SettingsManager.master_volume
	music_slider.value = SettingsManager.music_volume
	sfx_slider.value = SettingsManager.sfx_volume
	fullscreen_check.button_pressed = SettingsManager.fullscreen
	vsync_check.button_pressed = SettingsManager.vsync
	sensitivity_slider.value = SettingsManager.mouse_sensitivity

	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)

func _on_master_changed(v: float) -> void:
	SettingsManager.master_volume = v
	SettingsManager._apply_audio()

func _on_music_changed(v: float) -> void:
	SettingsManager.music_volume = v
	SettingsManager._apply_audio()

func _on_sfx_changed(v: float) -> void:
	SettingsManager.sfx_volume = v
	SettingsManager._apply_audio()

func _on_fullscreen_toggled(pressed: bool) -> void:
	SettingsManager.fullscreen = pressed
	SettingsManager._apply_video()

func _on_vsync_toggled(pressed: bool) -> void:
	SettingsManager.vsync = pressed
	SettingsManager._apply_video()

func _on_sensitivity_changed(v: float) -> void:
	SettingsManager.mouse_sensitivity = v

func _on_back_pressed() -> void:
	SettingsManager.save_settings()
	visible = false
	back_pressed.emit()
