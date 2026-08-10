extends Area3D



@export var player: Node3D           
@export var end_trigger: Area3D      
@export var end_screen_scene: PackedScene  



var level_started: bool = false
var level_ended: bool = false

func _ready() -> void:
	if end_trigger:
		end_trigger.body_entered.connect(_on_end_trigger_body_entered)

func _on_end_trigger_body_entered(body: Node3D) -> void:
	
	if player and body != player:
		return
	
	
	if level_ended:
		return
	

	if not level_started:
	
		TimerGlobal.level_start_time = Time.get_ticks_msec() / 1000.0
		level_started = true
	
	# Store final time and mark level as finished
	var now = Time.get_ticks_msec() / 1000.0
	TimerGlobal.level_end_time = now
	TimerGlobal.level_finished = true
	level_ended = true
	
	# Optional: load end screen
	if end_screen_scene:
		get_tree().change_scene_to_packed(end_screen_scene)
