extends Area3D
@export var weapon_set: WeaponVariantSet
@export var variant_index: int = 0  # which variant this pickup unlocks/grants, if only unlocking one
@export var unlock_all_variants: bool = true  # true = grants whole weapon family at once (simpler)
@export var bob_height: float = 0.2
@export var bob_speed: float = 2.0
@export var rotate_speed: float = 1.0
var time: float = 0.0
var start_y: float

func _ready() -> void:
	start_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	time += delta
	position.y = start_y + sin(time * bob_speed) * bob_height
	rotate_y(delta * rotate_speed)

func _on_body_entered(body: Node3D) -> void:
	print("Body entered: ", body.name)
	if body.has_method("get_weapon_manager"):
		print("Has weapon manager method")
		var wm = body.get_weapon_manager()
		if unlock_all_variants:
			wm.unlock_weapon(weapon_set)
		else:
			wm.unlock_weapon(weapon_set)  # ensures the slot exists first
			wm.unlock_variant(weapon_set.weapon_name, variant_index)
		queue_free()
	else:
		print("NO weapon manager method found on ", body.name)
