class_name PatriotPlayer
extends Node2D

# O Patriota: mantém a identidade visual de 'Patriota do Caminhão'
enum State { IDLE, RUNNING, PRAYING, HIT, CEREMONY }

var current_state: State = State.IDLE
var facing_dir: float = 1.0 # 1 = direita, -1 = esquerda
var speed: float = 380.0
var ground_y: float = 560.0

# Expressão facial: 0 = normal, 1 = fé/reza profunda, 2 = pânico/dano, 3 = êxtase da vitória
var facial_expr: int = 0
var ceremony_timer: float = 0.0
var hit_timer: float = 0.0
var pray_cycle: float = 0.0
var step_cycle: float = 0.0

var is_praying_input: bool = false
var touch_dir: float = 0.0

func _ready() -> void:
	position = Vector2(500.0, ground_y)

func _process(delta: float) -> void:
	if current_state == State.CEREMONY:
		ceremony_timer -= delta
		facial_expr = 3
		pray_cycle += delta * 6.0
		if ceremony_timer <= 0.0:
			current_state = State.IDLE
			facial_expr = 0
		queue_redraw()
		return

	if current_state == State.HIT:
		hit_timer -= delta
		facial_expr = 2
		if hit_timer <= 0.0:
			current_state = State.IDLE
			facial_expr = 0
		queue_redraw()
		return

	# Input do jogador (Teclado + Touch Virtual)
	var move_x := Input.get_axis("move_left", "move_right") + touch_dir
	move_x = clamp(move_x, -1.0, 1.0)
	
	var pray_action := Input.is_action_pressed("pray") or is_praying_input

	if pray_action:
		current_state = State.PRAYING
		facial_expr = 1
		pray_cycle += delta * 8.0
		# Se estiver à esquerda do pneu central (x=640), olha para a direita, e vice-versa
		facing_dir = 1.0 if position.x < 640.0 else -1.0
	elif abs(move_x) > 0.05:
		current_state = State.RUNNING
		facial_expr = 0
		facing_dir = sign(move_x)
		position.x += move_x * speed * delta
		position.x = clamp(position.x, 120.0, 1160.0)
		step_cycle += delta * 12.0
	else:
		current_state = State.IDLE
		facial_expr = 0
		step_cycle = 0.0
		pray_cycle = 0.0

	queue_redraw()

func set_praying(active: bool) -> void:
	is_praying_input = active

func set_touch_dir(dir: float) -> void:
	touch_dir = dir

func trigger_hit() -> void:
	current_state = State.HIT
	hit_timer = 0.55
	facial_expr = 2

func trigger_ceremony(duration: float = 2.5) -> void:
	current_state = State.CEREMONY
	ceremony_timer = duration
	facial_expr = 3

func get_catch_position() -> Vector2:
	# Posição da cabeça/mãos esticadas para capturar itens
	return position + Vector2(0, -90.0)

func is_in_prayer() -> bool:
	return current_state == State.PRAYING or current_state == State.CEREMONY

func _draw() -> void:
	# Escala horizontal baseada na direção que o personagem está olhando
	draw_patriota()

func draw_patriota() -> void:
	var flip: float = facing_dir
	var is_bowing: bool = (current_state == State.PRAYING)
	var is_ceremony: bool = (current_state == State.CEREMONY)
	
	# Deslocamento vertical de reza (curva para a frente rezando pro pneu)
	var bow_angle: float = sin(pray_cycle) if is_bowing else 0.0
	var bow_y: float = abs(sin(pray_cycle)) * 25.0 if is_bowing else 0.0
	var run_bob: float = sin(step_cycle) * 5.0 if current_state == State.RUNNING else 0.0
	
	var base_y: float = -run_bob
	
	# 1. Pés e Pernas (Calça Jeans Azul)
	var leg_l_start := Vector2(-12 * flip, base_y - 45)
	var leg_r_start := Vector2(12 * flip, base_y - 45)
	var leg_l_end := Vector2(-14 * flip, base_y)
	var leg_r_end := Vector2(14 * flip, base_y)
	
	if current_state == State.RUNNING:
		leg_l_end.x += sin(step_cycle) * 18.0 * flip
		leg_r_end.x -= sin(step_cycle) * 18.0 * flip
	elif is_bowing or is_ceremony:
		# De joelhos no asfalto em frente ao altar!
		leg_l_start = Vector2(-15 * flip, base_y - 25)
		leg_r_start = Vector2(15 * flip, base_y - 25)
		leg_l_end = Vector2(-25 * flip, base_y)
		leg_r_end = Vector2(10 * flip, base_y)
		
	# Pernas jeans
	draw_line(leg_l_start, leg_l_end, Color(0.15, 0.25, 0.55), 14.0)
	draw_line(leg_r_start, leg_r_end, Color(0.15, 0.25, 0.55), 14.0)
	# Tênis escuros
	draw_circle(leg_l_end, 9.0, Color(0.1, 0.1, 0.12))
	draw_circle(leg_r_end, 9.0, Color(0.1, 0.1, 0.12))
	
	# 2. Tronco / Camisa Amarela da Seleção
	var chest_y := base_y - 65.0 + (bow_y * 0.6)
	var chest_x := (bow_angle * 12.0 * flip) if is_bowing else 0.0
	var chest_pos := Vector2(chest_x, chest_y)
	
	var shirt_color := Color(1.0, 0.85, 0.0)
	draw_circle(chest_pos, 28.0, shirt_color)
	draw_rect(Rect2(chest_pos.x - 20, chest_pos.y - 10, 40, 36), shirt_color)
	# Faixa verde transversal patriota
	draw_line(chest_pos + Vector2(-16 * flip, -12), chest_pos + Vector2(16 * flip, 18), Color(0.0, 0.6, 0.2), 7.0)
	
	# 3. Braços e Mãos
	var skin_color := Color(1.0, 0.8, 0.68)
	if facial_expr == 2:
		skin_color = Color(1.0, 0.65, 0.65) # Vermelho de susto
		
	if is_ceremony:
		# Braços erguidos aos céus em glória!
		var hand_l := chest_pos + Vector2(-28, -50)
		var hand_r := chest_pos + Vector2(28, -50)
		draw_line(chest_pos + Vector2(-15, -10), hand_l, shirt_color, 12.0)
		draw_line(chest_pos + Vector2(15, -10), hand_r, shirt_color, 12.0)
		draw_circle(hand_l, 9.0, skin_color)
		draw_circle(hand_r, 9.0, skin_color)
		# Auréola de bênção
		draw_arc(chest_pos + Vector2(0, -90), 22.0, 0, TAU, 16, Color(1.0, 0.85, 0.1, 0.8), 4.0)
	elif is_bowing:
		# Mãos unidas em prece apontadas para o pneu sagrado
		var pray_hand := chest_pos + Vector2(34 * flip, 10 + bow_angle * 15.0)
		draw_line(chest_pos + Vector2(10 * flip, -5), pray_hand, shirt_color, 12.0)
		draw_line(chest_pos + Vector2(-10 * flip, -5), pray_hand, shirt_color, 12.0)
		draw_circle(pray_hand, 10.0, skin_color)
		# Lágrimas de emoção patriótica voando
		var tear_pos := chest_pos + Vector2(18 * flip, -20 + sin(pray_cycle * 2.0) * 8.0)
		draw_circle(tear_pos, 4.0, Color(0.2, 0.7, 1.0, 0.85))
	else:
		# Braços abertos equilibrando / prontos para pegar itens que caem
		var hand_l := chest_pos + Vector2(-32 * flip, -15 + sin(Time.get_ticks_msec() * 0.008) * 6.0)
		var hand_r := chest_pos + Vector2(32 * flip, -15 - sin(Time.get_ticks_msec() * 0.008) * 6.0)
		draw_line(chest_pos + Vector2(-14 * flip, -8), hand_l, shirt_color, 12.0)
		draw_line(chest_pos + Vector2(14 * flip, -8), hand_r, shirt_color, 12.0)
		draw_circle(hand_l, 9.0, skin_color)
		draw_circle(hand_r, 9.0, skin_color)
		
	# 4. Cabeça
	var head_y := chest_y - 36.0 + (bow_y * 0.4)
	var head_x := chest_x + (bow_angle * 8.0 * flip) if is_bowing else chest_x
	var head_pos := Vector2(head_x, head_y)
	
	draw_circle(head_pos, 22.0, skin_color)
	
	# Boné Verde com Aba Amarela
	draw_circle(head_pos - Vector2(0, 6), 20.0, Color(0.0, 0.55, 0.2)) # Topo verde
	# Aba virada para onde ele está olhando
	draw_rect(Rect2(head_pos.x + (-6 * flip if flip < 0 else 0), head_pos.y - 12, 24 * flip, 10), Color(1.0, 0.85, 0.0))
	
	# Rostinho cômico expressivo
	var eye_x := head_pos.x + (8.0 * flip)
	var eye_y := head_pos.y - 2.0
	
	if facial_expr == 1:
		# Reza profunda: olhos fechados com fé e boquinha em O cantando o hino
		draw_line(Vector2(eye_x - 4, eye_y), Vector2(eye_x + 4, eye_y - 2), Color.BLACK, 3.0)
		draw_circle(Vector2(eye_x, eye_y + 9), 4.5, Color(0.15, 0.05, 0.05)) # Boca rezando
	elif facial_expr == 2:
		# Pânico / Tomou dano: Olhos em X e boca tremendo
		draw_line(Vector2(eye_x - 4, eye_y - 4), Vector2(eye_x + 4, eye_y + 4), Color.BLACK, 3.0)
		draw_line(Vector2(eye_x - 4, eye_y + 4), Vector2(eye_x + 4, eye_y - 4), Color.BLACK, 3.0)
		draw_circle(Vector2(eye_x, eye_y + 10), 6.0, Color(0.6, 0.1, 0.1))
	elif facial_expr == 3:
		# Êxtase / Subiu de nível: Olhos de estrela e sorrisão
		draw_circle(Vector2(eye_x, eye_y), 5.0, Color(1.0, 0.85, 0.1))
		draw_circle(Vector2(eye_x, eye_y), 3.0, Color.BLACK)
		draw_arc(Vector2(eye_x, eye_y + 6), 7.0, 0.1, PI - 0.1, 8, Color.BLACK, 3.0)
	else:
		# Normal / Determinado: Olhos atentos para o céu
		draw_circle(Vector2(eye_x, eye_y), 5.0, Color.WHITE)
		draw_circle(Vector2(eye_x + (1.0 * flip), eye_y - 1.0), 2.5, Color.BLACK)
		draw_line(Vector2(eye_x - 3, eye_y + 8), Vector2(eye_x + 4, eye_y + 8), Color.BLACK, 2.5)
