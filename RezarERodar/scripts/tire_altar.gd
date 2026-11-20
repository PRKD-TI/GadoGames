class_name TireAltar
extends Node2D

# O Pneu Sagrado: objeto central de culto e evolução
signal pray_bonus_triggered(amount: float)

const TIERS_DATA: Array[Dictionary] = [
	{
		"name": "Pneu Careca Aro 13",
		"desc": "Resgatado de um ferro-velho patriótico",
		"radius": 46.0,
		"rim_radius": 22.0,
		"points_req": 100.0,
		"rim_color": Color(0.65, 0.65, 0.68),
		"tire_color": Color(0.18, 0.18, 0.2),
		"has_ribbon": false,
		"has_candles": false,
		"has_neon": false,
		"has_cosmic": false
	},
	{
		"name": "Pneu de Uno com Escada",
		"desc": "Aro 14 sagrado com a fita verde e amarela",
		"radius": 58.0,
		"rim_radius": 28.0,
		"points_req": 250.0,
		"rim_color": Color(0.8, 0.8, 0.82),
		"tire_color": Color(0.15, 0.15, 0.16),
		"has_ribbon": true,
		"has_candles": false,
		"has_neon": false,
		"has_cosmic": false
	},
	{
		"name": "Pneu de Hilux Agro-Top",
		"desc": "Aro 18 cromado com cheiro de soja e vitória",
		"radius": 74.0,
		"rim_radius": 38.0,
		"points_req": 500.0,
		"rim_color": Color(0.95, 0.95, 1.0),
		"tire_color": Color(0.12, 0.12, 0.13),
		"has_ribbon": true,
		"has_candles": true,
		"has_neon": false,
		"has_cosmic": false
	},
	{
		"name": "Pneu Duplo de Bitrem BR-101",
		"desc": "Pneu pesado de carga com incenso e bênçãos",
		"radius": 95.0,
		"rim_radius": 48.0,
		"points_req": 900.0,
		"rim_color": Color(0.7, 0.72, 0.75),
		"tire_color": Color(0.1, 0.1, 0.11),
		"has_ribbon": true,
		"has_candles": true,
		"has_neon": true,
		"has_cosmic": false
	},
	{
		"name": "Pneu Colossal de Trator Agrícola",
		"desc": "Garras gigantescas de borracha e iluminação LED",
		"radius": 120.0,
		"rim_radius": 60.0,
		"points_req": 1500.0,
		"rim_color": Color(1.0, 0.85, 0.1),
		"tire_color": Color(0.08, 0.08, 0.09),
		"has_ribbon": true,
		"has_candles": true,
		"has_neon": true,
		"has_cosmic": false
	},
	{
		"name": "Pneu Titânico de Mineração (4 Metros)",
		"desc": "Tamanho monumental com andaimes e palanque",
		"radius": 150.0,
		"rim_radius": 78.0,
		"points_req": 2500.0,
		"rim_color": Color(0.9, 0.92, 0.98),
		"tire_color": Color(0.06, 0.06, 0.07),
		"has_ribbon": true,
		"has_candles": true,
		"has_neon": true,
		"has_cosmic": false
	},
	{
		"name": "O PNEU CÓSMICO DOS EXTRATERRESTRES",
		"desc": "Levitação quântica e comunicação direta via sinal de lanterna",
		"radius": 175.0,
		"rim_radius": 90.0,
		"points_req": 4000.0,
		"rim_color": Color(0.3, 0.95, 1.0),
		"tire_color": Color(0.04, 0.08, 0.12),
		"has_ribbon": true,
		"has_candles": true,
		"has_neon": true,
		"has_cosmic": true
	}
]

var current_tier: int = 0
var rotation_angle: float = 0.0
var spin_speed: float = 1.0 # rad/s
var is_spinning_rodar: bool = false
var rodar_timer: float = 0.0
var ground_y: float = 560.0
var center_x: float = 640.0

var glow_intensity: float = 0.0
var divine_rays_alpha: float = 0.35

func _ready() -> void:
	update_position_for_tier()

func update_position_for_tier() -> void:
	var data := TIERS_DATA[current_tier]
	var r: float = data["radius"]
	position = Vector2(center_x, ground_y - r)

func _process(delta: float) -> void:
	if is_spinning_rodar:
		rodar_timer -= delta
		rotation_angle += 18.0 * delta
		glow_intensity = move_toward(glow_intensity, 1.0, delta * 3.0)
		if rodar_timer <= 0.0:
			is_spinning_rodar = false
	else:
		rotation_angle += spin_speed * delta
		glow_intensity = move_toward(glow_intensity, 0.2, delta * 1.5)
		
	# Pulso suave das luzes divinas
	divine_rays_alpha = 0.35 + sin(Time.get_ticks_msec() * 0.003) * 0.15
	queue_redraw()

func trigger_rodar_boost(duration: float = 5.0) -> void:
	is_spinning_rodar = true
	rodar_timer = duration

func set_tier(tier: int) -> void:
	current_tier = clamp(tier, 0, TIERS_DATA.size() - 1)
	update_position_for_tier()
	glow_intensity = 1.0

func get_current_tier_data() -> Dictionary:
	return TIERS_DATA[current_tier]

func is_near(pos: Vector2) -> bool:
	var data := TIERS_DATA[current_tier]
	var r: float = data["radius"]
	return abs(pos.x - center_x) < (r + 110.0)

func _draw() -> void:
	var data := TIERS_DATA[current_tier]
	var r: float = data["radius"]
	var rim_r: float = data["rim_radius"]
	var t_col: Color = data["tire_color"]
	var r_col: Color = data["rim_color"]
	var has_cosmic: bool = data["has_cosmic"]
	
	# 1. Raios divinos descendo do céu até o pneu
	draw_divine_light_rays(r)
	
	# 2. Pedestal / Altar no asfalto com cones patriotas e velas
	draw_altar_pedestal(r, data)
	
	# 3. Se for cósmico, levita suavemente
	var draw_offset_y := 0.0
	if has_cosmic:
		draw_offset_y = sin(Time.get_ticks_msec() * 0.004) * 16.0 - 20.0
		# Anéis quânticos giratórios
		draw_cosmic_rings(r, draw_offset_y)

	var pneu_center := Vector2(0, draw_offset_y)

	# 4. Aura de brilho / Glow ao redor do pneu
	var aura_color := Color(1.0, 0.85, 0.2, 0.25 * (1.0 + glow_intensity))
	if has_cosmic:
		aura_color = Color(0.2, 0.9, 1.0, 0.4 * (1.0 + glow_intensity))
	draw_circle(pneu_center, r + 18.0 + (glow_intensity * 12.0), aura_color)
	draw_circle(pneu_center, r + 8.0, Color(aura_color.r, aura_color.g, aura_color.b, 0.4))
	
	# 5. Corpo principal do Pneu (Borracha preta com sombreamento)
	draw_circle(pneu_center, r, t_col)
	draw_circle(pneu_center, r - 5.0, t_col.lightened(0.12))
	draw_circle(pneu_center, r - 12.0, t_col)
	
	# Ranhuras da banda de rodagem (treads) girando
	var num_treads := 16
	for i in range(num_treads):
		var angle := rotation_angle + (float(i) / float(num_treads)) * TAU
		var p1 := pneu_center + Vector2(cos(angle), sin(angle)) * (r - 14.0)
		var p2 := pneu_center + Vector2(cos(angle), sin(angle)) * r
		draw_line(p1, p2, Color(0.08, 0.08, 0.09), 6.0)
		
	# Se tiver LED neon
	if data["has_neon"]:
		var neon_col := Color(0.0, 1.0, 0.4, 0.8) if sin(Time.get_ticks_msec() * 0.008) > 0.0 else Color(1.0, 0.85, 0.0, 0.8)
		draw_arc(pneu_center, r - 8.0, 0, TAU, 32, neon_col, 4.0)

	# 6. Roda de Aço / Aro central
	draw_circle(pneu_center, rim_r, r_col)
	draw_circle(pneu_center, rim_r * 0.45, r_col.darkened(0.35))
	
	# Raios da roda
	var num_spokes := 6
	for i in range(num_spokes):
		var sp_ang := rotation_angle + (float(i) / float(num_spokes)) * TAU
		var s_end := pneu_center + Vector2(cos(sp_ang), sin(sp_ang)) * (rim_r - 3.0)
		draw_line(pneu_center, s_end, Color(0.25, 0.25, 0.28), 5.0)
		
	# Parafusos do aro
	for i in range(num_spokes):
		var b_ang := rotation_angle + (float(i) / float(num_spokes)) * TAU + (PI / float(num_spokes))
		var b_pos := pneu_center + Vector2(cos(b_ang), sin(b_ang)) * (rim_r * 0.72)
		draw_circle(b_pos, 3.5, Color(0.1, 0.1, 0.12))
		draw_circle(b_pos, 2.0, Color.WHITE)
		
	# Tampa do cubo da roda com logo verde-amarelo
	draw_circle(pneu_center, rim_r * 0.28, Color(0.0, 0.55, 0.2))
	draw_circle(pneu_center, rim_r * 0.16, Color(1.0, 0.85, 0.0))
	draw_circle(pneu_center, rim_r * 0.08, Color(0.0, 0.15, 0.6))
	
	# 7. Faixa Verde e Amarela amarrada no pneu
	if data["has_ribbon"]:
		var rib_y := pneu_center.y - (r * 0.25)
		draw_arc(Vector2(pneu_center.x, rib_y), r * 0.95, -0.6, 0.6, 16, Color(0.0, 0.6, 0.2), 10.0)
		draw_arc(Vector2(pneu_center.x, rib_y), r * 0.95, -0.4, 0.4, 16, Color(1.0, 0.85, 0.0), 6.0)

func draw_divine_light_rays(r: float) -> void:
	# Feixes de luz descendo do topo
	var top_y := -position.y
	var alpha := divine_rays_alpha
	var ray_col := Color(1.0, 0.92, 0.5, alpha * 0.45)
	
	# Cone de luz central
	var poly := PackedVector2Array([
		Vector2(-120, top_y),
		Vector2(120, top_y),
		Vector2(r + 140, 10),
		Vector2(-r - 140, 10)
	])
	draw_colored_polygon(poly, ray_col)
	
	# Raios pontuais pulsantes
	for i in range(4):
		var t_anim := Time.get_ticks_msec() * 0.001 + float(i) * 1.5
		var rx1 := sin(t_anim) * 180.0
		var rx2 := rx1 * 1.6
		draw_line(Vector2(rx1 * 0.3, top_y), Vector2(rx2, 0), Color(1.0, 1.0, 0.8, alpha * 0.35), 8.0)

func draw_altar_pedestal(r: float, data: Dictionary) -> void:
	# Base de asfalto demarcada com tinta amarela
	var base_w := (r * 2.2) + 60.0
	draw_rect(Rect2(-base_w / 2.0, r - 6.0, base_w, 14.0), Color(0.15, 0.15, 0.18))
	draw_rect(Rect2(-base_w / 2.0 + 8.0, r - 4.0, base_w - 16.0, 4.0), Color(0.95, 0.85, 0.1))
	
	# Cones de trânsito dos bloqueios de rodovia nos dois lados
	var cone_l_x := -base_w / 2.0 - 24.0
	var cone_r_x := base_w / 2.0 + 24.0
	draw_traffic_cone(cone_l_x, r + 6.0)
	draw_traffic_cone(cone_r_x, r + 6.0)
	
	# Velas e incenso da fé ao lado do pneu
	if data["has_candles"]:
		draw_holy_candles(-r - 15.0, r)
		draw_holy_candles(r + 15.0, r)

func draw_traffic_cone(cx: float, cy: float) -> void:
	var base_poly := PackedVector2Array([
		Vector2(cx - 16, cy),
		Vector2(cx + 16, cy),
		Vector2(cx + 12, cy - 4),
		Vector2(cx - 12, cy - 4)
	])
	draw_colored_polygon(base_poly, Color(0.1, 0.1, 0.12))
	
	var cone_poly := PackedVector2Array([
		Vector2(cx - 12, cy - 4),
		Vector2(cx + 12, cy - 4),
		Vector2(cx + 3, cy - 36),
		Vector2(cx - 3, cy - 36)
	])
	draw_colored_polygon(cone_poly, Color(0.95, 0.35, 0.05)) # Laranja
	# Faixa branca reflexiva
	var stripe_poly := PackedVector2Array([
		Vector2(cx - 7, cy - 18),
		Vector2(cx + 7, cy - 18),
		Vector2(cx + 5, cy - 26),
		Vector2(cx - 5, cy - 26)
	])
	draw_colored_polygon(stripe_poly, Color.WHITE)

func draw_holy_candles(cx: float, cy: float) -> void:
	# Três velinhas acesas com chama dançante
	for i in range(3):
		var vx := cx + (float(i) - 1.0) * 12.0
		var h := 16.0 + float(i % 2) * 6.0
		draw_rect(Rect2(vx - 3, cy - h, 6, h), Color(0.95, 0.95, 0.88)) # Cera
		# Pavio
		draw_line(Vector2(vx, cy - h), Vector2(vx, cy - h - 4), Color.BLACK, 1.5)
		# Chama com oscilação
		var flame_flicker := sin(Time.get_ticks_msec() * 0.015 + vx) * 2.0
		var flame_pos := Vector2(vx + flame_flicker * 0.5, cy - h - 7)
		draw_circle(flame_pos, 4.0, Color(1.0, 0.6, 0.1, 0.9))
		draw_circle(flame_pos, 2.5, Color(1.0, 0.95, 0.3, 1.0))

func draw_cosmic_rings(r: float, off_y: float) -> void:
	# Anéis orbitais alienígenas
	var t := Time.get_ticks_msec() * 0.003
	var center := Vector2(0, off_y)
	
	# Elipse 1
	var ring_pts := PackedVector2Array()
	var num_pts := 24
	for i in range(num_pts + 1):
		var ang := float(i) / float(num_pts) * TAU
		var x := cos(ang + t) * (r * 1.35)
		var y := sin(ang + t) * (r * 0.35)
		ring_pts.append(center + Vector2(x, y))
	draw_polyline(ring_pts, Color(0.0, 0.9, 1.0, 0.7), 3.0)
