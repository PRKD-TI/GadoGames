class_name Scenery
extends Node2D

var road_scroll: float = 0.0

func _process(delta: float) -> void:
	road_scroll += delta * 20.0
	queue_redraw()

func _draw() -> void:
	var w := 1280.0
	var h := 720.0
	var ground_y := 560.0
	
	# 1. Céu com degradê do entardecer patriota (Amarelo, Laranja e Azul)
	draw_colored_polygon([
		Vector2(0, 0), Vector2(w, 0),
		Vector2(w, 240), Vector2(0, 240)
	], Color(0.25, 0.55, 0.88)) # Azul céu
	
	draw_colored_polygon([
		Vector2(0, 240), Vector2(w, 240),
		Vector2(w, 360), Vector2(0, 360)
	], Color(0.95, 0.75, 0.35)) # Dourado do pôr do sol
	
	# Sol divino ou feixe de luz dos ETs no horizonte
	draw_circle(Vector2(640, 320), 75.0, Color(1.0, 0.95, 0.7, 0.4))
	draw_circle(Vector2(640, 320), 45.0, Color(1.0, 1.0, 0.85, 0.6))
	
	# 2. Silhueta de morros e vegetação do Brasil
	draw_colored_polygon([
		Vector2(0, 360), Vector2(250, 320), Vector2(500, 350),
		Vector2(850, 310), Vector2(1100, 340), Vector2(w, 330),
		Vector2(w, 400), Vector2(0, 400)
	], Color(0.12, 0.35, 0.18))
	
	# 3. Acampamento da Resistência (Barracas de lona azul e faixas)
	draw_tents_and_camps(w)
	
	# 4. Asfalto da Rodovia BR (y = 440 a 720)
	draw_rect(Rect2(0, 440, w, 60), Color(0.16, 0.38, 0.2)) # Acostamento de terra e grama
	draw_rect(Rect2(0, 500, w, h - 500), Color(0.2, 0.21, 0.24)) # Pista de asfalto
	
	# Faixa branca contínua do acostamento
	draw_line(Vector2(0, 510), Vector2(w, 510), Color(0.95, 0.95, 0.95), 5.0)
	
	# Faixa amarela dupla no centro da rodovia (mais abaixo)
	draw_line(Vector2(0, 650), Vector2(w, 650), Color(0.95, 0.85, 0.1), 4.0)
	draw_line(Vector2(0, 662), Vector2(w, 662), Color(0.95, 0.85, 0.1), 4.0)
	
	# Faixas tracejadas da pista
	for i in range(14):
		var x_pos := float(i * 100)
		draw_line(Vector2(x_pos, 580), Vector2(x_pos + 55, 580), Color(0.9, 0.9, 0.9, 0.3), 3.0)
		
	# Placas na rodovia
	draw_road_signs()

func draw_tents_and_camps(_w: float) -> void:
	# Barraca de lona azul 1 (à esquerda)
	draw_colored_polygon([
		Vector2(60, 440), Vector2(140, 380), Vector2(220, 440)
	], Color(0.1, 0.35, 0.8)) # Azul lona
	draw_line(Vector2(140, 380), Vector2(140, 440), Color(0.08, 0.25, 0.6), 3.0)
	# Mastro com bandeira do Brasil na barraca
	draw_line(Vector2(140, 380), Vector2(140, 330), Color(0.6, 0.45, 0.2), 3.5)
	draw_rect(Rect2(140, 335, 34, 22), Color(0.0, 0.6, 0.22))
	draw_colored_polygon([
		Vector2(157, 338), Vector2(170, 346),
		Vector2(157, 354), Vector2(144, 346)
	], Color(1.0, 0.85, 0.0))
	
	# Barraca de lona azul 2 (à direita)
	draw_colored_polygon([
		Vector2(1060, 440), Vector2(1140, 385), Vector2(1220, 440)
	], Color(0.1, 0.35, 0.8))
	draw_line(Vector2(1140, 385), Vector2(1140, 440), Color(0.08, 0.25, 0.6), 3.0)
	
	# Fumaça da churrasqueira do acampamento
	var smoke_t := Time.get_ticks_msec() * 0.002
	for s in range(4):
		var sy := 420.0 - float(s * 16) - fmod(smoke_t * 20.0, 20.0)
		var sx := 260.0 + sin(smoke_t + float(s)) * 8.0
		draw_circle(Vector2(sx, sy), 8.0 + float(s * 4), Color(0.85, 0.85, 0.88, 0.25))

func draw_road_signs() -> void:
	# Placa verde rodoviária à esquerda: "BR-101 / BLOQUEIO 72H"
	draw_rect(Rect2(270, 380, 100, 50), Color(0.05, 0.45, 0.2)) # Fundo verde
	draw_rect(Rect2(272, 382, 96, 46), Color.WHITE, false, 2.0)
	draw_rect(Rect2(318, 430, 4, 30), Color(0.4, 0.4, 0.4)) # Poste da placa
	# Texto simbólico na placa
	draw_line(Vector2(280, 395), Vector2(360, 395), Color.WHITE, 4.0)
	draw_line(Vector2(290, 410), Vector2(350, 410), Color(1.0, 0.85, 0.1), 3.0)
