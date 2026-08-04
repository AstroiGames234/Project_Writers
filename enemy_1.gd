extends CharacterBody3D

var player = null 

const SPEED = 5

@export var player_path : NodePath

@onready var nav_agent = $NavigationAgent3D

func _ready() -> void:
	player = get_node(player_path)
	
func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO
	
	nav_agent.set_target_position(player.global_position)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_position).normalized() * SPEED
	
	move_and_slide()


func _on_hit_player_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		get_tree().call_group("Player", "hurt", 10 )
