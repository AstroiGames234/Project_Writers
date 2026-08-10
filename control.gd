extends Control


@export var player: Node3D           
@export var start_trigger: Area3D    
@export var end_trigger: Area3D      
@export var end_screen_scene: PackedScene  

@onready var time_label: Label = $TimeLabel  


var level_start_time: float = 0.0
var level_started: bool = false
var level_ended: bool = false

func _ready() -> void:
	set_process(true)
	
	if start_trigger:
		start_trigger.body_entered.connect(_on_start_trigger_body_entered)
	if end_trigger:
		end_trigger.body_entered.connect(_on_end_trigger_body_entered)

func _process(_delta: float) -> void:
	if not level_started or level_ended or not time_label:
		return
	
	var now = Time.get_ticks_msec() / 1000.0
	var elapsed = now - level_start_time
	time_label.text = _format_time(elapsed)

func _on_start_trigger_body_entered(body: Node3D) -> void:
	if player and body != player:
		return
	if level_started:
		return
	
	level_start_time = Time.get_ticks_msec() / 1000.0
	level_started = true

func _on_end_trigger_body_entered(body: Node3D) -> void:
	if player and body != player:
		return
	if not level_started or level_ended:
		return
	
	level_ended = true
	


func _format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	var ms = int((seconds - floor(seconds)) * 1000)
	return "%02d:%02d.%03d" % [mins, secs, ms]
