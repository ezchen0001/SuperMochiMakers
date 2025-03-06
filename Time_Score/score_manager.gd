extends Node

var secondsPassed: int
var minutesPassed: int
var second_timer
var time_started = false
var time_label: Label
var p2_time_label
var end_score_label
var end_score_label_2

func _ready() -> void:
	secondsPassed = 0;
	minutesPassed = 0;
	second_timer = $"1 Sec Timer"
	time_label = $"Game Time Label"
	p2_time_label = $"Game Time Label2"
	end_score_label = $"End Score"
	end_score_label_2 = $"End Score2"
	end_score_label.visible = false
	end_score_label_2.visible = false
	$"Grade Label".visible = false
	$"Grade Label2".visible = false

func begin_time():
	second_timer.start()


func _on__sec_timer_timeout() -> void:
	secondsPassed += 1
	if secondsPassed == 60:
		secondsPassed = 0
		minutesPassed += 1
	var opt_zero: String = "0" if secondsPassed < 10 else ""
	time_label.set_text(str(minutesPassed, ":", opt_zero, secondsPassed))
	p2_time_label.set_text(str(minutesPassed, ":", opt_zero, secondsPassed))


func stop_time():
	second_timer.stop()
	var time_score = secondsPassed + (minutesPassed* 60)
	
	await get_tree().create_timer(2).timeout
	var opt_zero: String = "0" if secondsPassed < 10 else ""
	end_score_label.set_text(str("Total Time: ", minutesPassed, ":", opt_zero, secondsPassed))
	end_score_label_2.set_text(str("Total Time: ", minutesPassed, ":", opt_zero, secondsPassed))
	end_score_label.visible = true
	end_score_label_2.visible = true
	
	var grade_text: String = make_grade(time_score)
	$"Grade Label".set_text(grade_text)
	$"Grade Label".visible = true
	$"Grade Label2".set_text(grade_text)
	$"Grade Label2".visible = true
	
	await get_tree().create_timer(5).timeout
	secondsPassed = 0
	minutesPassed = 0
	time_label.set_text("0:00")
	p2_time_label.set_text("0:00")
	time_started = false
	
	end_score_label.visible = false
	end_score_label_2.visible = false
	$"Grade Label".visible = false
	$"Grade Label2".visible = false

func make_grade(time_score: int) -> String:
	if time_score < 0:
		return "... Something has gone horribly wrong"
	elif time_score >= 0 and time_score < 10:
		return "...cheater"
	elif time_score >= 10 and time_score < 15:
		return "MOCHI MASTER!"
	elif time_score >= 15 and time_score < 35: 
		return "Super Sonic Speed! Amazing!"
	elif time_score >= 35 and time_score < 55: 
		return "Incredible! Great Teamwork!"
	elif time_score >= 55 and time_score < 65: 
		return "Nice!"
	elif time_score >= 65 and time_score < 80: 
		return "Good"
	elif time_score >= 80 and time_score < 100: 
		return "Not great"
	elif time_score >= 100 and time_score < 120: 
		return "Snails Pace!"
	elif time_score >= 120 and time_score < 180: 
		return "Wha- oh sorry, I fell asleep"
	else:
		return "Your Customers Starved to Death"
	

var color_tween = null

func hand_hit_penalty():
	secondsPassed += 2
	if secondsPassed == 60:
		secondsPassed = 0
		minutesPassed += 1
	var opt_zero: String = "0" if secondsPassed < 10 else ""
	time_label.set_text(str(minutesPassed, ":", opt_zero, secondsPassed))
	p2_time_label.set_text(str(minutesPassed, ":", opt_zero, secondsPassed))
	
	$"Penalty Label".modulate = Color.WHITE
	$"Penalty Label2".modulate = Color.WHITE
	if color_tween:
		color_tween.kill()
	color_tween = create_tween()
	color_tween.set_parallel()
	color_tween.tween_property($"Penalty Label", "modulate", Color.TRANSPARENT, 0.5)
	color_tween.tween_property($"Penalty Label2", "modulate", Color.TRANSPARENT, 0.5)
	
