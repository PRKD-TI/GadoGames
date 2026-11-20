class_name BonusItem
extends Node2D

enum ItemType {
	ZAP_72H,
	LANTERNA,
	CLOROQUINA,
	BANDEIRA,
	CAFE_TERMO,
	CHURRASCO,
	URNA,
	CHUVA,
	FATO_OU_BOATO
}

var type: ItemType = ItemType.ZAP_72H
var fall_speed: float = 180.0
var sway_speed: float = 3.0
var sway_width: float = 40.0
var base_x: float = 0.0
var lifetime: float = 0.0

var faith_value: float = 15.0
var score_value: int = 100
var is_hazard: bool = false
var is_collected: bool = false

func init_item(p_type: ItemType, start_x: float, speed_mult: float = 1.0) -> void:
	type = p_type
	base_x = start_x
	position = Vector2(start_x, -40.0)
	
	match type:
		ItemType.ZAP_72H:
			faith_value = 15.0
			score_value = 100
			fall_speed = 170.0 * speed_mult
			is_hazard = false
		ItemType.LANTERNA:
			faith_value = 20.0
			score_value = 150
			fall_speed = 190.0 * speed_mult
			is_hazard = false
		ItemType.CLOROQUINA:
			faith_value = 25.0
			score_value = 200
			fall_speed = 210.0 * speed_mult
			is_hazard = false
		ItemType.BANDEIRA:
			faith_value = 30.0
			score_value = 250
			fall_speed = 150.0 * speed_mult # Flutua mais devagar
			is_hazard = false
		ItemType.CAFE_TERMO:
			faith_value = 18.0
			score_value = 120
			fall_speed = 180.0 * speed_mult
			is_hazard = false
		ItemType.CHURRASCO:
			faith_value = 22.0
			score_value = 180
			fall_speed = 200.0 * speed_mult
			is_hazard = false
		ItemType.URNA:
			faith_value = -25.0
			score_value = -100
			fall_speed = 230.0 * speed_mult # Cai mais pesado
			is_hazard = true
		ItemType.CHUVA:
			faith_value = -18.0
			score_value = -80
			fall_speed = 160.0 * speed_mult
			is_hazard = true
		ItemType.FATO_OU_BOATO:
			faith_value = -22.0
			score_value = -90
			fall_speed = 190.0 * speed_mult
			is_hazard = true

func _process(delta: float) -> void:
	lifetime += delta
	position.y += fall_speed * delta
	position.x = base_x + sin(lifetime * sway_speed) * sway_width
	
	if position.y > 640.0:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	match type:
		ItemType.ZAP_72H:
			draw_zap_icon()
		ItemType.LANTERNA:
			draw_flashlight_icon()
		ItemType.CLOROQUINA:
			draw_cloroquina_icon()
		ItemType.BANDEIRA:
			draw_flag_icon()
		ItemType.CAFE_TERMO:
			draw_coffee_icon()
		ItemType.CHURRASCO:
			draw_bbq_icon()
		ItemType.URNA:
			draw_urna_icon()
		ItemType.CHUVA:
			draw_rain_icon()
		ItemType.FATO_OU_BOATO:
			draw_newspaper_icon()

func draw_zap_icon() -> void:
	# Balão verde de WhatsApp com texto "72h"
	draw_circle(Vector2.ZERO, 20.0, Color(0.12, 0.78, 0.35))
	draw_colored_polygon([
		Vector2(-6, 14), Vector2(-16, 24), Vector2(4, 18)
	], Color(0.12, 0.78, 0.35))
	# Letra "72h"
	draw_line(Vector2(-10, -8), Vector2(0, -8), Color.WHITE, 3.0)
	draw_line(Vector2(0, -8), Vector2(-6, 8), Color.WHITE, 3.0)
	draw_line(Vector2(4, -8), Vector2(10, -8), Color.WHITE, 2.5)
	draw_line(Vector2(10, -8), Vector2(10, 0), Color.WHITE, 2.5)
	draw_line(Vector2(4, 0), Vector2(10, 0), Color.WHITE, 2.5)
	draw_line(Vector2(4, 0), Vector2(4, 8), Color.WHITE, 2.5)
	draw_line(Vector2(4, 8), Vector2(10, 8), Color.WHITE, 2.5)

func draw_flashlight_icon() -> void:
	# Feixe de luz para cima (sinal para os ETs)
	draw_colored_polygon([
		Vector2(-4, -12), Vector2(4, -12),
		Vector2(24, -45), Vector2(-24, -45)
	], Color(1.0, 1.0, 0.6, 0.45))
	# Celular preto
	draw_rect(Rect2(-10, -12, 20, 32), Color(0.12, 0.12, 0.15))
	draw_rect(Rect2(-8, -10, 16, 22), Color(0.3, 0.6, 0.9)) # Tela
	# Lanterna brilhante
	draw_circle(Vector2(0, -12), 5.0, Color.WHITE)

func draw_cloroquina_icon() -> void:
	# Vidro de remédio dourado / milagroso
	draw_rect(Rect2(-12, -14, 24, 28), Color(1.0, 0.85, 0.2))
	draw_rect(Rect2(-8, -20, 16, 6), Color.WHITE) # Tampa
	# Cruz verde da farmácia
	draw_line(Vector2(0, -6), Vector2(0, 8), Color(0.0, 0.6, 0.2), 4.0)
	draw_line(Vector2(-7, 1), Vector2(7, 1), Color(0.0, 0.6, 0.2), 4.0)

func draw_flag_icon() -> void:
	# Bandeirinha do Brasil tremulando
	draw_line(Vector2(-16, -22), Vector2(-16, 20), Color(0.5, 0.3, 0.1), 4.0)
	var wave := sin(lifetime * 6.0) * 4.0
	draw_rect(Rect2(-14, -20 + wave, 32, 20), Color(0.0, 0.6, 0.22))
	# Losango
	draw_colored_polygon([
		Vector2(2, -20 + wave), Vector2(14, -10 + wave),
		Vector2(2, wave), Vector2(-10, -10 + wave)
	], Color(1.0, 0.85, 0.0))
	draw_circle(Vector2(2, -10 + wave), 4.0, Color(0.0, 0.15, 0.5))

func draw_coffee_icon() -> void:
	# Garrafa térmica vermelha
	draw_rect(Rect2(-10, -14, 20, 30), Color(0.85, 0.15, 0.15))
	draw_rect(Rect2(-6, -22, 12, 8), Color(0.9, 0.9, 0.9)) # Tampa copo
	# Fumaça aromática
	var smoke_w := sin(lifetime * 8.0) * 3.0
	draw_line(Vector2(0, -24), Vector2(smoke_w, -34), Color(1.0, 1.0, 1.0, 0.6), 2.5)

func draw_bbq_icon() -> void:
	# Espeto de carne na brasa
	draw_line(Vector2(-18, 18), Vector2(18, -18), Color(0.7, 0.7, 0.75), 4.0)
	draw_circle(Vector2(-6, 6), 9.0, Color(0.5, 0.2, 0.1))
	draw_circle(Vector2(6, -6), 9.0, Color(0.4, 0.15, 0.08))
	# Foguinho
	draw_circle(Vector2(0, 0), 4.0, Color(1.0, 0.6, 0.1, 0.8))

func draw_urna_icon() -> void:
	# Urna eletrônica preta com tela e teclado
	draw_rect(Rect2(-18, -14, 36, 28), Color(0.18, 0.18, 0.2))
	draw_rect(Rect2(-15, -11, 14, 22), Color(0.85, 0.9, 0.88)) # Tela
	# Teclado numérico
	draw_rect(Rect2(3, -11, 12, 14), Color(0.08, 0.08, 0.1))
	# Botões Confirma (verde) e Corrige (laranja)
	draw_rect(Rect2(3, 5, 5, 4), Color(0.95, 0.45, 0.1))
	draw_rect(Rect2(9, 5, 6, 4), Color(0.1, 0.7, 0.2))
	# Aura vermelha de perigo
	draw_rect(Rect2(-20, -16, 40, 32), Color(1.0, 0.2, 0.2, 0.4), false, 2.0)

func draw_rain_icon() -> void:
	# Nuvem cinza com chuva
	draw_circle(Vector2(-8, -6), 12.0, Color(0.45, 0.48, 0.52))
	draw_circle(Vector2(8, -6), 12.0, Color(0.45, 0.48, 0.52))
	draw_circle(Vector2(0, -12), 14.0, Color(0.5, 0.53, 0.58))
	# Gotas de chuva
	for i in range(3):
		var rx := (float(i) - 1.0) * 10.0
		var ry := fmod(lifetime * 80.0 + float(i) * 10.0, 20.0)
		draw_line(Vector2(rx, ry), Vector2(rx - 2, ry + 6), Color(0.2, 0.6, 0.95), 2.5)

func draw_newspaper_icon() -> void:
	# Jornal de Checagem de Fatos
	draw_rect(Rect2(-16, -14, 32, 28), Color(0.95, 0.95, 0.92))
	draw_line(Vector2(-12, -9), Vector2(12, -9), Color(0.2, 0.2, 0.2), 3.0)
	draw_line(Vector2(-12, -3), Vector2(12, -3), Color(0.4, 0.4, 0.4), 2.0)
	draw_line(Vector2(-12, 2), Vector2(6, 2), Color(0.4, 0.4, 0.4), 2.0)
	# Carimbo vermelho FATO
	draw_rect(Rect2(-12, 6, 24, 7), Color(0.85, 0.15, 0.15, 0.85))
