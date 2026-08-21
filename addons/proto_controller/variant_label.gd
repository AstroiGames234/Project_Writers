extends TextureRect

@export var weapon_manager: NodePath
@onready var icon: TextureRect = $"."

func _ready() -> void:
	var wm = get_node(weapon_manager)
	if wm == null:
		push_warning("weapon_manager NodePath not set")
		return
	wm.weapon_changed.connect(_on_weapon_changed)
	var w = wm.current_weapon()
	if w:
		icon.texture = w.icon

func _on_weapon_changed(weapon_name: String, variant_index: int, variant_count: int, weapon_icon: Texture2D) -> void:
	icon.texture = weapon_icon
