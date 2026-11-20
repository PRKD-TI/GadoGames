class_name WheelMinigame
extends Control

signal wheel_completed(prize_data: Dictionary)

const PRIZES: Array[Dictionary] = [
	{ "title": "⏳ MAIS 72 HORAS! (MULTIPLICADOR x2)", "score": 250, "mult": 2.0, "frenzy": true, "color": Color(0.95, 0.85, 0.1) },
	{ "title": "📱 CHUVA DE ZAP! (FRENESI DE BÔNUS)", "score": 350, "mult": 1.5, "frenzy": true, "color": Color(0.12, 0.75, 0.35) },
	{ "title": "💊 CLOROQUINA DOURADA (+500 PTS)", "score": 500, "mult": 1.2, "frenzy": false, "color": Color(1.0, 0.75, 0.0) },
	{ "title": "🛸 INTERVENÇÃO EXTRATERRESTRE! (+750 PTS)", "score": 750, "mult": 2.5, "frenzy": true, "color": Color(0.15, 0.85, 1.0) },
	{ "title": "☕ CAFÉ DA RESISTÊNCIA (+400 PTS)", "score": 400, "mult": 1.3, "frenzy": false, "color": Color(0.85, 0.25, 0.2) },
	{ "title": "🏆 BÊNÇÃO DO PNEU SAGRADO (+1000 PTS)", "score": 1000, "mult": 3.0, "frenzy": true, "color": Color(0.8, 0.3, 0.95) }
]

var wheel_rotation: float = 0.0
var spin_velocity: float = 0.0
var is_spinning: bool = false
var has_stopped: bool = false
var close_timer: float = 0.0
var last_tick_slice: int = -1

var sfx: SoundEffects = null

@onready var spin_button: Button = $SpinBtn
@onready var result_label: Label = $ResultLabel
@onready var title_label: Label = $TitleLabel

func _ready() -> void:
	visible = false
	if spin_button:
		spin_button.pressed.connect(_on_spin_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("spin") or event.is_action_pressed("pray") or event.is_action_pressed("restart"):
		if not is_spinning and not has_stopped:
			_on_spin_pressed()

func open_wheel() -> void:
	visible = true
	has_stopped = false
	is_spinning = false
	spin_velocity = 0.0
	close_timer = 0.0
	if result_label:
		result_label.text = "Clique no botão ou aperte ESPAÇO / S para Rodar!"
		result_label.modulate = Color.WHITE
	if spin_button:
		spin_button.visible = true
		spin_button.disabled = false
	queue_redraw()

func _on_spin_pressed() -> void:
	if is_spinning or has_stopped:
		return
	is_spinning = true
	if spin_button:
		spin_button.disabled = true
		spin_button.visible = false
	if result_label:
		result_label.text = "Rodando a Roda da Fé... 🌀"
		result_label.modulate = Color(1.0, 0.9, 0.2)
	# Velocidade inicial garantida com variação
	spin_velocity = randf_range(26.0, 34.0)

func _process(delta: float) -> void:
	if not visible:
		return
		
	if is_spinning:
		wheel_rotation += spin_velocity * delta
		# Desaceleração física suave
		spin_velocity = move_toward(spin_velocity, 0.0, delta * 5.2)
		
		# Som de clique de cada pino da roleta
		var num_slices := PRIZES.size()
		var slice_angle := TAU / float(num_slices)
		var cur_slice := int(fposmod(wheel_rotation, TAU) / slice_angle)
		if cur_slice != last_tick_slice:
			last_tick_slice = cur_slice
			if sfx:
				sfx.play_spin_tick()
				
		if spin_velocity <= 0.01:
			is_spinning = false
			has_stopped = true
			spin_velocity = 0.0
			on_wheel_stopped()
			
		queue_redraw()
	elif has_stopped:
		close_timer += delta
		if close_timer > 2.0:
			visible = false
			var winning_slice := get_current_winning_index()
			emit_signal("wheel_completed", PRIZES[winning_slice])

func get_current_winning_index() -> int:
	var num_slices := PRIZES.size()
	var slice_angle := TAU / float(num_slices)
	# O ponteiro fica no topo (ângulo -PI/2)
	var pointer_angle := -PI / 2.0
	var relative_angle := fposmod(pointer_angle - wheel_rotation, TAU)
	var index := int(relative_angle / slice_angle) % num_slices
	return index

func on_wheel_stopped() -> void:
	var win_idx := get_current_winning_index()
	var prize := PRIZES[win_idx]
	if result_label:
		result_label.text = "🎉 " + prize["title"] + "! 🎉"
		result_label.modulate = prize["color"]
	if sfx:
		sfx.play_cheer()

func _draw() -> void:
	if not visible:
		return
		
	var s := size
	if s.x > 1400.0 or s == Vector2.ZERO:
		s = get_viewport_rect().size
	if s == Vector2.ZERO:
		s = Vector2(1280.0, 720.0)
		
	# Escurecer o fundo para dar destaque estilo auditório
	draw_rect(Rect2(Vector2.ZERO, s), Color(0.0, 0.0, 0.0, 0.7))
		
	var center := Vector2(s.x / 2.0, s.y / 2.0 - 20.0)
	var radius := 175.0
	var num_slices := PRIZES.size()
	var slice_angle := TAU / float(num_slices)
	
	# Sombra da roleta
	draw_circle(center + Vector2(0, 10), radius + 8.0, Color(0, 0, 0, 0.6))
	
	# Borda externa dourada da roleta com lâmpadas
	draw_circle(center, radius + 14.0, Color(0.9, 0.75, 0.15))
	draw_circle(center, radius + 4.0, Color(0.2, 0.18, 0.12))
	
	# Lâmpadas piscantes ao redor da roleta
	var num_lights := 24
	for i in range(num_lights):
		var l_ang := (float(i) / float(num_lights)) * TAU
		var l_pos := center + Vector2(cos(l_ang), sin(l_ang)) * (radius + 9.0)
		var is_lit := (int(Time.get_ticks_msec() * 0.008 + i) % 2 == 0)
		var l_col := Color(1.0, 0.95, 0.3) if is_lit else Color(0.35, 0.3, 0.1)
		draw_circle(l_pos, 4.5, l_col)
		
	# Fatias da Roleta
	for i in range(num_slices):
		var start_ang := wheel_rotation + (float(i) * slice_angle)
		var end_ang := start_ang + slice_angle
		var prize_col: Color = PRIZES[i]["color"]
		
		# Desenhar triângulo de cada fatia
		var pts := PackedVector2Array([
			center,
			center + Vector2(cos(start_ang), sin(start_ang)) * radius,
			center + Vector2(cos(end_ang), sin(end_ang)) * radius
		])
		draw_colored_polygon(pts, prize_col)
		draw_line(center, center + Vector2(cos(start_ang), sin(start_ang)) * radius, Color(0.1, 0.1, 0.12), 2.5)
		
		# Ponto decorativo na borda da fatia
		var mid_ang := (start_ang + end_ang) / 2.0
		var pin_pos := center + Vector2(cos(mid_ang), sin(mid_ang)) * (radius * 0.76)
		draw_circle(pin_pos, 10.0, Color.WHITE)
		draw_circle(pin_pos, 6.0, prize_col.darkened(0.3))

	# Pino central da roleta
	draw_circle(center, 32.0, Color(0.2, 0.22, 0.26))
	draw_circle(center, 24.0, Color(1.0, 0.85, 0.1))
	draw_circle(center, 9.0, Color.BLACK)
	
	# Ponteiro indicador no topo apontando para baixo
	var pointer_top := center + Vector2(0, -radius - 18.0)
	var pointer_tip := center + Vector2(0, -radius + 14.0)
	var ptr_poly := PackedVector2Array([
		pointer_tip,
		pointer_top + Vector2(-16, 0),
		pointer_top + Vector2(16, 0)
	])
	draw_colored_polygon(ptr_poly, Color(0.95, 0.15, 0.15))
	draw_polyline(ptr_poly, Color.WHITE, 2.5)
