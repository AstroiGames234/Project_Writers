extends Control  

@onready var time_label: Label = $TimeLabel  

func _ready() -> void:
	if not time_label or not TimerGlobal.level_finished:
		return
	
	var elapsed = TimerGlobal.level_end_time - TimerGlobal.level_start_time
	time_label.text = _format_time(elapsed)

func _format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	var ms = int((seconds - floor(seconds)) * 1000)
	return "%02d:%02d.%03d" % [mins, secs, ms]
