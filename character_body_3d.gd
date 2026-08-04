extends CharacterBody3D

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add gravity if not on the floor
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	move_and_slide()
