extends Node2D

signal turn_event_started(direction_text: String)

@export var base_speed: float = 45.0
@export var current_speed: float = 45.0
@export var max_speed: float = 145.0

var lateral_force: float = 0.0
var maneuver_timer: float = 5.0 # Primeiros 5 segundos retos para se acostumar
var target_lateral_force: float = 0.0
var road_scroll_offset: float = 0.0
var steering_angle: float = 0.0

var time_elapsed: float = 0.0

func _process(delta: float) -> void:
	time_elapsed += delta
	
	# Progressão de velocidade: suave nos primeiros 20s, depois acelera forte
	if time_elapsed < 20.0:
		current_speed = base_speed + (time_elapsed * 0.5) # De 45 até 55 km/h
	else:
		current_speed = min(55.0 + ((time_elapsed - 20.0) * 1.4), max_speed)
		
	road_scroll_offset += current_speed * delta * 12.0
	
	maneuver_timer -= delta
	if maneuver_timer <= 0.0:
		start_new_maneuver()
		
	# Suavidade de transição da curva: mais suave no início
	var lerp_speed: float = 1.8 if time_elapsed < 20.0 else 3.5
	lateral_force = lerp(lateral_force, target_lateral_force, delta * lerp_speed)
	
	# Micro-vibração da pista (mais calma no início)
	var bump_intensity: float = (0.015 if time_elapsed < 20.0 else 0.04) * (current_speed / 80.0)
	var road_bump: float = sin(time_elapsed * 16.0) * bump_intensity
	lateral_force += road_bump * delta * 4.0
	
	steering_angle = lerp(steering_angle, -lateral_force * 0.85, delta * 5.0)

func start_new_maneuver() -> void:
	# Nos primeiros 20 segundos: manobras bem brandas e espaçadas
	if time_elapsed < 20.0:
		if abs(target_lateral_force) > 0.1 or randf() < 0.4:
			target_lateral_force = 0.0
			maneuver_timer = randf_range(2.0, 3.5)
		else:
			var dir: float = 1.0 if randf() > 0.5 else -1.0
			# Curvas bem leves entre 0.15 e 0.32
			target_lateral_force = dir * randf_range(0.18, 0.32)
			maneuver_timer = randf_range(2.5, 4.0)
			var msg: String = "Curva leve à direita..." if dir > 0.0 else "Curva leve à esquerda..."
			emit_signal("turn_event_started", msg)
		return
		
	# A partir de 20s: progressão contínua de dificuldade
	var progress_factor: float = (time_elapsed - 20.0) / 35.0
	var difficulty_mult: float = clamp(1.0 + progress_factor, 1.0, 2.6)
	
	if abs(target_lateral_force) > 0.3 or randf() < 0.25:
		target_lateral_force = 0.0
		maneuver_timer = randf_range(0.8, 1.6)
	else:
		var dir: float = 1.0 if randf() > 0.5 else -1.0
		var intensity: float = randf_range(0.42, 0.9) * difficulty_mult
		intensity = clamp(intensity, 0.4, 1.35)
		target_lateral_force = dir * intensity
		maneuver_timer = randf_range(1.2, 2.6) / difficulty_mult
		
		var msg: String = "CURVA FECHADA À DIREITA!" if dir > 0.0 else "CURVA FECHADA À ESQUERDA!"
		if intensity > 0.95:
			msg = "DESVIO BRUSCO NA PISTA! ⚠️"
			AudioManager.trigger_haptic(60)
		else:
			AudioManager.trigger_haptic(40)
		emit_signal("turn_event_started", msg)
