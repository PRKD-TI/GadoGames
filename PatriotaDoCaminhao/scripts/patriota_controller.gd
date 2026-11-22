extends Node2D

signal fell_off
signal balance_changed(current_balance: float, panic_level: float)

@export var player_strength: float = 2.5
@export var centering_friction: float = 1.8

# Configuração do sensor de inclinação (Giroscópio / Acelerômetro)
@export var tilt_enabled: bool = true
@export var tilt_sensitivity: float = 1.1
@export var tilt_deadzone: float = 0.08
var current_tilt_value: float = 0.0

# Posição de equilíbrio normalizada: -1.0 a +1.0
var balance_pos: float = 0.0
var balance_velocity: float = 0.0

var is_falling: bool = false
var fall_progress: float = 0.0
var fall_velocity: Vector2 = Vector2.ZERO

var touch_input_axis: float = 0.0
var time_elapsed: float = 0.0

enum ExpressionState { CONFIDENT, TENSE, PANIC, FALLING }
var current_expression: ExpressionState = ExpressionState.CONFIDENT

func _process(delta: float) -> void:
	if is_falling:
		process_falling(delta)
		return
		
	time_elapsed += delta
		
	# Captura entrada do jogador (teclado + botões touch + sensor de inclinação)
	var input_dir: float = Input.get_axis("move_left", "move_right")
	if touch_input_axis != 0.0:
		input_dir = touch_input_axis
		
	# Leitura do sensor de inclinação do smartphone
	var tilt_val: float = get_tilt_input()
	if tilt_val != 0.0:
		input_dir = clamp(input_dir + tilt_val, -1.0, 1.0)
		
	# Força do jogador para se segurar e puxar para o lado desejado
	var player_force: float = input_dir * player_strength
	
	# Força inercial vinda do caminhão
	var truck = get_tree().root.find_child("TruckController", true, false)
	var inertia_force: float = 0.0
	if truck and "lateral_force" in truck:
		inertia_force = truck.lateral_force * 3.2
		
	# Nos primeiros 20 segundos, a instabilidade lateral é menor para facilitar o aprendizado
	var instability_factor: float = clamp(0.35 + ((time_elapsed / 20.0) * 0.65), 0.35, 1.0)
	var unstable_gravity: float = balance_pos * (1.3 * instability_factor)
	
	# Soma das acelerações
	var total_acceleration: float = player_force + inertia_force + unstable_gravity
	balance_velocity += total_acceleration * delta
	
	# Atrito de agarre das mãos (maior nos primeiros 20s para evitar escorregão rápido)
	var active_friction: float = 2.4 if time_elapsed < 20.0 else centering_friction
	balance_velocity = lerp(balance_velocity, 0.0, active_friction * delta)
	
	# Atualiza posição
	balance_pos += balance_velocity * delta
	
	# Avalia estado emocional
	var abs_pos: float = abs(balance_pos)
	if abs_pos < 0.35:
		current_expression = ExpressionState.CONFIDENT
	elif abs_pos < 0.7:
		current_expression = ExpressionState.TENSE
	else:
		current_expression = ExpressionState.PANIC
		
	emit_signal("balance_changed", balance_pos, clamp(abs_pos, 0.0, 1.0))
	
	# Checa se caiu do parachoque!
	if abs_pos >= 1.0:
		trigger_fall()

func get_tilt_input() -> float:
	if not tilt_enabled:
		current_tilt_value = 0.0
		return 0.0
		
	var grav: Vector3 = Input.get_gravity()
	if grav.length_squared() < 0.01:
		grav = Input.get_accelerometer()
		
	if grav.length_squared() < 0.01:
		current_tilt_value = 0.0
		return 0.0
		
	var orient: int = DisplayServer.screen_get_orientation()
	var raw_tilt: float = -grav.y
	
	if orient == DisplayServer.SCREEN_REVERSE_LANDSCAPE:
		raw_tilt = grav.y
	elif orient == DisplayServer.SCREEN_PORTRAIT:
		raw_tilt = grav.x
	elif orient == DisplayServer.SCREEN_REVERSE_PORTRAIT:
		raw_tilt = -grav.x
		
	if abs(raw_tilt) < (tilt_deadzone * 9.8):
		current_tilt_value = 0.0
		return 0.0
		
	var normalized_tilt: float = clamp((raw_tilt / 3.8) * tilt_sensitivity, -1.0, 1.0)
	current_tilt_value = normalized_tilt
	return normalized_tilt

func trigger_fall() -> void:
	is_falling = true
	current_expression = ExpressionState.FALLING
	fall_velocity = Vector2(balance_velocity * 400.0 + (sign(balance_pos) * 350.0), 300.0)
	emit_signal("fell_off")
	AudioManager.trigger_haptic(110)
	
	var gm = get_tree().root.find_child("GameManager", true, false)
	if gm and gm.has_method("end_game"):
		gm.end_game()

func process_falling(delta: float) -> void:
	fall_progress += delta
	rotation += delta * 8.0 * (1.0 if fall_velocity.x >= 0 else -1.0)
	position += fall_velocity * delta
	scale = scale.lerp(Vector2(0.2, 0.2), delta * 2.0)
