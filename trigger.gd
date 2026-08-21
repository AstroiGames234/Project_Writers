extends Area3D


func _on_body_entered(body: Node) -> void:
	if body.has_node("player"):
		TimerGlobal.level_start_time
		queue_free()
	
	
