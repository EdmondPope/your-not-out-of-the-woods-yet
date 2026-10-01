extends CanvasModulate

@export var day_length := 20.0 
@export var start_time := 0.25

var time := start_time


func _process(delta: float) -> void:
	time += delta / day_length
	
	if time >= 1.0:
		time -= 1.0
	
	color = get_day_color(time)

func get_day_color(t: float) -> Color:
	
	var night := Color(0.08, 0.09, 0.14)
	var dawn := Color(0.35, 0.32, 0.32)
	var day := Color(0.55, 0.53, .48)
	var dusk := Color(0.30, 0.25, 0.28)
	
	if t < 0.25:
		var amount := smoothstep(0.15, 0.25, t)
		return night.lerp(dawn, amount)
	elif t < 0.40:
		var amount := smoothstep(0.25, 0.40, t)
		return dawn.lerp(day, amount)
	elif t < 0.65:
		return day
	elif t < 0.80:
		var amount := smoothstep(0.65, 0.80, t)
		$ZombieSpawner.start_night()
		return day.lerp(dusk, amount)
	else:
		var amount := smoothstep(0.80, 1.0, t)
		$ZombieSpawner.start_day()
		return dusk.lerp(night, amount)
