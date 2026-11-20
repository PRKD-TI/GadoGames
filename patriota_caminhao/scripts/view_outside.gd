extends Node2D

var patriota: Node2D = null
var truck: Node2D = null

func _process(_delta: float) -> void:
	if not visible:
		return
	queue_redraw()

func _draw() -> void:
	var w := 1280.0
	var h := 720.0
	
	# 1. Pista de Asfalto e Céu
	draw_rect(Rect2(0, 0, w, 280), Color(0.45, 0.7, 0.95)) # Céu
	draw_rect(Rect2(0, 260, w, 60), Color(0.18, 0.45, 0.2)) # Acostamento
	draw_colored_polygon([
		Vector2(180, 280), Vector2(w - 180, 280),
		Vector2(w + 100, h), Vector2(-100, h)
	], Color(0.22, 0.23, 0.26)) # Asfalto
	
	# Faixas da rodovia passando em perspectiva
	var offset := fmod(truck.road_scroll_offset if (truck and "road_scroll_offset" in truck) else 0.0, 140.0)
	for i in range(-2, 10):
		var y_pos := 280.0 + (float(i) * 60.0) + (offset * 0.4)
		if y_pos > 280.0 and y_pos < h:
			var scale_p := (y_pos - 280.0) / (h - 280.0)
			var lane_w := 14.0 + (scale_p * 24.0)
			var lane_h := 18.0 + (scale_p * 32.0)
			draw_rect(Rect2(w / 2.0 - (lane_w / 2.0), y_pos, lane_w, lane_h), Color(0.95, 0.88, 0.2))
			draw_rect(Rect2((w / 2.0 - 240.0 - (scale_p * 200.0)), y_pos, lane_w * 0.7, lane_h), Color.WHITE)
			draw_rect(Rect2((w / 2.0 + 240.0 + (scale_p * 200.0)), y_pos, lane_w * 0.7, lane_h), Color.WHITE)
			
	# 2. O Caminhão vindo de frente
	draw_truck_front(w, h)
	
	# 3. O Patriota pendurado na altura do para-brisa!
	draw_patriota_clinging(w, h)

func draw_truck_front(w: float, _h: float) -> void:
	var l_force: float = truck.lateral_force if (truck and "lateral_force" in truck) else 0.0
	var truck_x := w / 2.0 + (l_force * -50.0)
	var truck_y := 410.0 + sin(Time.get_ticks_msec() * 0.01) * 3.0
	
	# Cabine Superior (Vermelha)
	var cab_w := 640.0
	var cab_h := 360.0
	var cab_color := Color(0.85, 0.18, 0.18)
	draw_rect(Rect2(truck_x - (cab_w / 2.0), truck_y - cab_h, cab_w, cab_h), cab_color)
	draw_colored_polygon([
		Vector2(truck_x - 320, truck_y - cab_h), Vector2(truck_x + 320, truck_y - cab_h),
		Vector2(truck_x + 240, truck_y - cab_h - 60), Vector2(truck_x - 240, truck_y - cab_h - 60)
	], cab_color.darkened(0.1))
	
	# Parabrisa do caminhão
	var wind_w := 540.0
	var wind_h := 160.0
	var wind_y := truck_y - cab_h + 35.0 # y = 85.0
	draw_rect(Rect2(truck_x - (wind_w / 2.0), wind_y, wind_w, wind_h), Color(0.15, 0.35, 0.5, 0.88))
	# Reflexos no vidro
	draw_line(Vector2(truck_x - 220, wind_y + 15), Vector2(truck_x - 100, wind_y + 140), Color(1, 1, 1, 0.35), 18.0)
	draw_line(Vector2(truck_x - 70, wind_y + 15), Vector2(truck_x + 50, wind_y + 140), Color(1, 1, 1, 0.25), 10.0)
	
	# Limpadores de para-brisa vistos de fora
	draw_line(Vector2(truck_x - 130, wind_y + 155), Vector2(truck_x - 60, wind_y + 55), Color(0.1, 0.1, 0.1), 7.0)
	draw_line(Vector2(truck_x + 100, wind_y + 155), Vector2(truck_x + 170, wind_y + 55), Color(0.1, 0.1, 0.1), 7.0)
	
	# Retrovisores e Bandeiras do Brasil
	draw_mirrors_and_flags(truck_x, truck_y - cab_h + 100)
	
	# Grade Dianteira Cromada
	var grill_w := 480.0
	var grill_h := 180.0
	var grill_rect := Rect2(truck_x - (grill_w / 2.0), truck_y - 170, grill_w, grill_h)
	draw_rect(grill_rect, Color(0.15, 0.15, 0.18))
	draw_rect(grill_rect, Color(0.75, 0.78, 0.82), false, 8.0)
	for i in range(7):
		var y_bar := truck_y - 150 + (i * 22)
		draw_line(Vector2(truck_x - 230, y_bar), Vector2(truck_x + 230, y_bar), Color(0.75, 0.78, 0.82), 6.0)
		
	# Emblema central
	draw_circle(Vector2(truck_x, truck_y - 90), 28.0, Color(0.9, 0.9, 0.95))
	draw_circle(Vector2(truck_x, truck_y - 90), 22.0, Color(0.85, 0.18, 0.18))
	
	# Faróis dianteiros acesos
	var left_light := Vector2(truck_x - 280, truck_y - 45)
	var right_light := Vector2(truck_x + 280, truck_y - 45)
	draw_circle(left_light, 34.0, Color(1.0, 0.98, 0.8))
	draw_circle(right_light, 34.0, Color(1.0, 0.98, 0.8))
	draw_circle(left_light, 40.0, Color(1.0, 1.0, 0.7, 0.3))
	draw_circle(right_light, 40.0, Color(1.0, 1.0, 0.7, 0.3))
	
	# Para-choque maciço de aço
	var bump_w := 690.0
	var bump_h := 70.0
	var bump_rect := Rect2(truck_x - (bump_w / 2.0), truck_y - 10, bump_w, bump_h)
	draw_rect(bump_rect, Color(0.25, 0.27, 0.3))
	draw_rect(bump_rect, Color(0.5, 0.55, 0.6), false, 5.0)
	
	# Placa Mercosul
	draw_rect(Rect2(truck_x - 75, truck_y + 12, 150, 42), Color.WHITE)
	draw_rect(Rect2(truck_x - 75, truck_y + 12, 150, 12), Color(0.1, 0.25, 0.7))

func draw_mirrors_and_flags(cx: float, cy: float) -> void:
	draw_line(Vector2(cx - 320, cy), Vector2(cx - 390, cy), Color.BLACK, 8.0)
	draw_line(Vector2(cx + 320, cy), Vector2(cx + 390, cy), Color.BLACK, 8.0)
	draw_rect(Rect2(cx - 415, cy - 45, 30, 90), Color(0.2, 0.2, 0.2))
	draw_rect(Rect2(cx + 385, cy - 45, 30, 90), Color(0.2, 0.2, 0.2))
	
	# Bandeiras do Brasil tremulando
	var flag_wave := sin(Time.get_ticks_msec() * 0.025) * 8.0
	draw_rect(Rect2(cx - 480 + flag_wave, cy - 35, 65, 42), Color(0.0, 0.6, 0.22))
	draw_colored_polygon([
		Vector2(cx - 480 + flag_wave + 32, cy - 31),
		Vector2(cx - 480 + flag_wave + 56, cy - 14),
		Vector2(cx - 480 + flag_wave + 32, cy + 3),
		Vector2(cx - 480 + flag_wave + 8, cy - 14)
	], Color(1.0, 0.85, 0.0))
	draw_circle(Vector2(cx - 480 + flag_wave + 32, cy - 14), 8.0, Color(0.0, 0.15, 0.5))

func draw_patriota_clinging(w: float, _h: float) -> void:
	if not patriota or ("is_falling" in patriota and patriota.is_falling):
		return
		
	var l_force: float = truck.lateral_force if (truck and "lateral_force" in truck) else 0.0
	var truck_x := w / 2.0 + (l_force * -50.0)
	var balance_p: float = patriota.balance_pos if "balance_pos" in patriota else 0.0
	
	# Posição horizontal no capô/vidro
	var patriota_x := truck_x + (balance_p * 240.0)
	
	# A base do parabrisa fica em y = 245. Colocamos o peito/cintura apoiado no capô (y ≈ 240)
	# e a cabeça exatamente na altura do parabrisa (y ≈ 165)!
	var base_y := 240.0 + sin(Time.get_ticks_msec() * 0.015) * 3.0
	
	var is_panic: bool = ("current_expression" in patriota) and (patriota.current_expression == 2)
	var is_tense: bool = ("current_expression" in patriota) and (patriota.current_expression == 1)
	
	# 1. Pernas apoiadas na grade dianteira
	var leg_l_start := Vector2(patriota_x - 18, base_y + 25)
	var leg_r_start := Vector2(patriota_x + 18, base_y + 25)
	var leg_l_end := Vector2(patriota_x - 26 + (balance_p * 20.0), base_y + 115)
	var leg_r_end := Vector2(patriota_x + 26 + (balance_p * 20.0), base_y + 115)
	
	if is_panic and balance_p > 0.5:
		# Perna esquerda escorregou e está no ar balançando!
		leg_l_end = Vector2(patriota_x - 55, base_y + 90)
	elif is_panic and balance_p < -0.5:
		# Perna direita escorregou e está no ar!
		leg_r_end = Vector2(patriota_x + 55, base_y + 90)
		
	# Calça jeans azul
	draw_line(leg_l_start, leg_l_end, Color(0.15, 0.25, 0.55), 16.0)
	draw_line(leg_r_start, leg_r_end, Color(0.15, 0.25, 0.55), 16.0)
	# Tênis apoiados na grade cromada
	draw_circle(leg_l_end, 10.0, Color(0.1, 0.1, 0.12))
	draw_circle(leg_r_end, 10.0, Color(0.1, 0.1, 0.12))
	
	# 2. Tronco / Camiseta amarela da Seleção
	var body_color := Color(1.0, 0.85, 0.0)
	var chest_pos := Vector2(patriota_x, base_y - 15)
	draw_circle(chest_pos, 36.0, body_color)
	draw_rect(Rect2(patriota_x - 28, base_y - 38, 56, 55), body_color)
	# Faixa verde transversal ou número nas costas
	draw_line(Vector2(patriota_x - 24, base_y - 25), Vector2(patriota_x + 24, base_y + 5), Color(0.0, 0.6, 0.2), 8.0)
	
	# 3. Braços esticados segurando no parabrisa e limpadores
	# Mãos espalmadas no vidro do parabrisa (y ≈ 180)
	var hand_l := Vector2(patriota_x - 70, base_y - 55)
	var hand_r := Vector2(patriota_x + 70, base_y - 55)
	
	if is_panic and balance_p > 0.6:
		# Mão esquerda perdeu o agarre e tenta segurar no ar!
		hand_l = Vector2(patriota_x - 80, base_y - 10)
	elif is_panic and balance_p < -0.6:
		# Mão direita perdeu o agarre!
		hand_r = Vector2(patriota_x + 80, base_y - 10)
		
	# Braços
	draw_line(Vector2(patriota_x - 22, base_y - 30), hand_l, body_color, 16.0)
	draw_line(Vector2(patriota_x + 22, base_y - 30), hand_r, body_color, 16.0)
	# Mãos no vidro
	var hand_skin := Color(1.0, 0.8, 0.68)
	draw_circle(hand_l, 12.0, hand_skin)
	draw_circle(hand_r, 12.0, hand_skin)
	
	# 4. Cabeça NA ALTURA DO PARABRISA (y ≈ 165)
	var head_y := base_y - 75.0 # ~ 165.0, bem no centro vertical do parabrisa!
	var head_pos := Vector2(patriota_x, head_y)
	
	# Pele
	var skin_col := Color(1.0, 0.8, 0.68)
	if is_panic:
		skin_col = Color(1.0, 0.65, 0.65) # Vermelho de desespero
	draw_circle(head_pos, 30.0, skin_col)
	
	# Boné Verde e Amarelo
	draw_circle(head_pos - Vector2(0, 8), 28.0, Color(0.0, 0.55, 0.2))
	# Aba amarela do boné virada para a frente/lado
	draw_rect(Rect2(head_pos.x - 34, head_pos.y - 18, 68, 14), Color(1.0, 0.85, 0.0))
	
	# Olho em perfil arregalado quando tenso/pânico
	if is_panic or is_tense:
		var eye_offset: float = (sign(balance_p) * 16.0) if abs(balance_p) > 0.1 else 14.0
		var eye_x: float = head_pos.x + eye_offset
		draw_circle(Vector2(eye_x, head_pos.y - 4), 7.0, Color.WHITE)
		draw_circle(Vector2(eye_x, head_pos.y - 4), 3.0, Color.BLACK)
