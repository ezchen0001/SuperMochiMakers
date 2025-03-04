extends Node

var secondsPassed: int
var minutesPassed: int
var second_timer
var time_started = false
var time_label

func _ready() -> void:
	secondsPassed = 0;
	minutesPassed = 0;
	second_timer = $"1 Sec Timer"
	time_label = $"Time Label"

func begin_time():
	second_timer.start()


func _on__sec_timer_timeout() -> void:
	secondsPassed += 1
	if secondsPassed == 60:
		secondsPassed = 0
		minutesPassed += 1
	var opt_zero: String = "0" if secondsPassed < 10 else ""
	time_label.set_text(str(minutesPassed, ":", opt_zero, secondsPassed))


func stop_time():
	second_timer.stop()
