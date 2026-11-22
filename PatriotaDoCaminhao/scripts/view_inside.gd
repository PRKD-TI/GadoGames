extends Node2D

var patriota: Node2D = null
var truck: Node2D = null

var wiper_angle: float = 0.0
var wiper_dir: float = 1.0

func _process(delta: float) -> void:
	if not visible:
		return
	# Anima limpador de parabrisa
	wiper_angle += delta * 4.5 * wiper_dir
	if wiper_angle > 1.2:
		wiper_dir = -1.0
	elif wiper_angle < -0.2:
		wiper_dir = 1.0
		
	queue_redraw()

func _draw() -> void:
	var v_size := get_viewport_rect().size
	var w := maxf(v_size.x, 1280.0)
	var h := maxf(v_size.y, 720.0)
	var margin := 400.0
	
	# 1. Estrada e Céu vistos pelo vidro preenchendo toda a tela
	draw_rect(Rect2(-margin, 0, w + (margin * 2.0), 400), Color(0.4, 0.65, 0.95)) # Céu
	# Montanhas/Vegetação ao longe
	draw_colored_polygon([
		Vector2(-margin, 360), Vector2(300, 280), Vector2(w * 0.5, 340),
		Vector2(w * 0.75, 290), Vector2(w + margin, 350), Vector2(w + margin, 400), Vector2(-margin, 400)
	], Color(0.2, 0.5, 0.25))
	
	# Asfalto da pista
	draw_rect(Rect2(-margin, 380, w + (margin * 2.0), 220), Color(0.2, 0.22, 0.25))
	
	# Faixas da pista em movimento
	var offset := fmod(truck.road_scroll_offset if (truck and "road_scroll_offset" in truck) else 0.0, 160.0)
	var num_lanes := int((w + (margin * 2.0)) / 160.0) + 2
	for i in range(-3, num_lanes):
		var x_pos := float(i) * 160.0 - offset - margin
		draw_rect(Rect2(x_pos, 440, 90, 16), Color(0.95, 0.95, 0.3)) # Faixa amarela
		draw_rect(Rect2(x_pos + 40, 510, 80, 12), Color(0.9, 0.9, 0.9, 0.8)) # Faixa branca
	
	# 2. O Patriota pendurado na frente do vidro do parabrisa!
	draw_patriota_on_windshield(w, h)
	
	# 3. Limpadores de para-brisa varrendo o vidro na frente do patriota
	draw_windshield_wipers(w, h)
	
	# 4. Moldura e Interior da Cabine do Caminhão
	draw_cabin_interior(w, h)

func draw_patriota_on_windshield(w: float, _h: float) -> void:
	if not patriota:
		return
	if "is_falling" in patriota and patriota.is_falling:
		return
		
	var balance_p: float = patriota.balance_pos if "balance_pos" in patriota else 0.0
	var center_x := w / 2.0
	var patriota_x := center_x + (balance_p * 340.0)
	var patriota_y := 340.0 + sin(Time.get_ticks_msec() * 0.012) * 5.0 # Tremor da velocidade
	
	var is_panic: bool = ("current_expression" in patriota) and (patriota.current_expression == 2) # PANIC
	var is_tense: bool = ("current_expression" in patriota) and (patriota.current_expression == 1) # TENSE
	
	# Corpo / Camiseta da Seleção (Amarela com detalhes verdes)
	var body_color := Color(1.0, 0.85, 0.0)
	draw_circle(Vector2(patriota_x, patriota_y + 90), 85.0, body_color)
	# Faixa verde no peito
	draw_rect(Rect2(patriota_x - 40, patriota_y + 60, 80, 20), Color(0.0, 0.6, 0.2))
	
	# Cabeça
	var head_y := patriota_y
	var skin_color := Color(1.0, 0.8, 0.68)
	if is_panic:
		skin_color = Color(1.0, 0.65, 0.65) # Rosto vermelho de desespero
	draw_circle(Vector2(patriota_x, head_y), 62.0, skin_color)
	
	# Cabelo / Boné Verde-Amarelo
	draw_circle(Vector2(patriota_x, head_y - 28), 58.0, Color(0.0, 0.55, 0.2))
	draw_rect(Rect2(patriota_x - 68, head_y - 42, 136, 26), Color(0.0, 0.55, 0.2))
	draw_rect(Rect2(patriota_x - 85, head_y - 25, 170, 16), Color(1.0, 0.85, 0.0)) # Aba do boné
	
	# Olhos arregalados colados no vidro
	var eye_r := 16.0 if is_panic else 12.0
	draw_circle(Vector2(patriota_x - 22, head_y - 2), eye_r, Color.WHITE)
	draw_circle(Vector2(patriota_x + 22, head_y - 2), eye_r, Color.WHITE)
	
	# Pupilas vidradas olhando diretamente para o motorista!
	draw_circle(Vector2(patriota_x - 22, head_y - 2), 6.0, Color.BLACK)
	draw_circle(Vector2(patriota_x + 22, head_y - 2), 6.0, Color.BLACK)
	
	# Sobrancelhas
	if is_panic:
		draw_line(Vector2(patriota_x - 36, head_y - 22), Vector2(patriota_x - 10, head_y - 14), Color.DARK_GRAY, 5.0)
		draw_line(Vector2(patriota_x + 36, head_y - 22), Vector2(patriota_x + 10, head_y - 14), Color.DARK_GRAY, 5.0)
	else:
		draw_line(Vector2(patriota_x - 34, head_y - 16), Vector2(patriota_x - 10, head_y - 18), Color.DARK_GRAY, 4.0)
		draw_line(Vector2(patriota_x + 34, head_y - 16), Vector2(patriota_x + 10, head_y - 18), Color.DARK_GRAY, 4.0)
		
	# Boca
	if is_panic:
		draw_circle(Vector2(patriota_x, head_y + 32), 16.0, Color(0.4, 0.1, 0.1))
	elif is_tense:
		draw_rect(Rect2(patriota_x - 18, head_y + 24, 36, 12), Color.WHITE)
		draw_rect(Rect2(patriota_x - 18, head_y + 28, 36, 2), Color.BLACK)
	else:
		draw_line(Vector2(patriota_x - 16, head_y + 26), Vector2(patriota_x + 16, head_y + 26), Color(0.4, 0.1, 0.1), 4.0)
		
	# Gotas de suor quando tenso
	if is_panic or is_tense:
		var sweat_y := head_y - 8 + fmod(Time.get_ticks_msec() * 0.15, 40.0)
		draw_circle(Vector2(patriota_x + 48, sweat_y), 6.0, Color(0.4, 0.8, 1.0, 0.85))
		draw_circle(Vector2(patriota_x - 48, sweat_y + 10), 5.0, Color(0.4, 0.8, 1.0, 0.85))
		
	# Mãos espalmadas no vidro
	var hand_color := Color(1.0, 0.82, 0.7, 0.95)
	draw_circle(Vector2(patriota_x - 85, head_y + 10), 22.0, hand_color)
	draw_circle(Vector2(patriota_x + 85, head_y + 10), 22.0, hand_color)
	for d in range(4):
		draw_circle(Vector2(patriota_x - 100 + (d * 8), head_y - 10), 7.0, hand_color)
		draw_circle(Vector2(patriota_x + 75 + (d * 8), head_y - 10), 7.0, hand_color)

func draw_windshield_wipers(w: float, _h: float) -> void:
	var base_y := 490.0
	for pivot_x in [w * 0.35, w * 0.65]:
		var length := 210.0
		var blade_tip := Vector2(pivot_x + cos(wiper_angle - 1.57) * length, base_y + sin(wiper_angle - 1.57) * length)
		draw_line(Vector2(pivot_x, base_y), blade_tip, Color(0.1, 0.1, 0.1), 8.0)
		var blade_side := Vector2(-sin(wiper_angle - 1.57), cos(wiper_angle - 1.57)) * 40.0
		draw_line(blade_tip - blade_side, blade_tip + blade_side, Color(0.2, 0.2, 0.2), 6.0)

func draw_cabin_interior(w: float, h: float) -> void:
	var cabin_color := Color(0.14, 0.15, 0.17)
	var trim_color := Color(0.2, 0.22, 0.25)
	var margin := 400.0
	
	# Colunas laterais do parabrisa
	draw_colored_polygon([Vector2(-margin, 0), Vector2(90, 0), Vector2(160, 520), Vector2(-margin, 520)], cabin_color)
	draw_colored_polygon([Vector2(w + margin, 0), Vector2(w - 90, 0), Vector2(w - 160, 520), Vector2(w + margin, 520)], cabin_color)
	
	# Teto da cabine
	draw_rect(Rect2(-margin, 0, w + (margin * 2.0), 70), cabin_color)
	draw_rect(Rect2(w / 2.0 - 110, 55, 220, 50), Color(0.08, 0.08, 0.08))
	draw_rect(Rect2(w / 2.0 - 105, 60, 210, 40), Color(0.65, 0.7, 0.75))
	
	# Painel do caminhão
	draw_rect(Rect2(-margin, 510, w + (margin * 2.0), h - 510 + 100), cabin_color)
	draw_rect(Rect2(-margin, 510, w + (margin * 2.0), 14), trim_color)
	
	# Mostrador de Velocidade
	var spd_x := w * 0.28
	var spd_y := 610.0
	draw_circle(Vector2(spd_x, spd_y), 65.0, Color(0.05, 0.05, 0.05))
	draw_arc(Vector2(spd_x, spd_y), 60.0, 0, PI * 2, 32, Color(0.3, 0.9, 0.3), 4.0)
	
	var cur_speed: float = truck.current_speed if (truck and "current_speed" in truck) else 60.0
	var speed_ratio := cur_speed / 140.0
	var pointer_angle := -2.4 + (speed_ratio * 3.8)
	var ptr_end := Vector2(spd_x + cos(pointer_angle) * 48.0, spd_y + sin(pointer_angle) * 48.0)
	draw_line(Vector2(spd_x, spd_y), ptr_end, Color.RED, 4.0)
	
	# Volante do Caminhão
	var wheel_x := w * 0.72
	var wheel_y := 630.0
	var steer: float = truck.steering_angle if (truck and "steering_angle" in truck) else 0.0
	
	draw_arc(Vector2(wheel_x, wheel_y), 130.0, steer, steer + PI * 2, 48, Color(0.08, 0.08, 0.09), 22.0)
	draw_circle(Vector2(wheel_x, wheel_y), 45.0, Color(0.12, 0.12, 0.14))
	for r in [0.0, 2.1, 4.2]:
		var spoke_angle: float = steer + float(r)
		var spoke_end := Vector2(wheel_x + cos(spoke_angle) * 120.0, wheel_y + sin(spoke_angle) * 120.0)
		draw_line(Vector2(wheel_x, wheel_y), spoke_end, Color(0.18, 0.18, 0.2), 12.0)
