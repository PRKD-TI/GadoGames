class_name GameManager
extends Node

signal faith_changed(current: float, max_faith: float, percent: float)
signal score_changed(score: int, multiplier: float)
signal tire_upgraded(new_tier: int, tier_name: String, tier_desc: String)
signal ceremony_started(duration: float)
signal rodar_boost_activated(duration: float)
signal game_over_triggered(final_score: int, max_tier_name: String, rank_title: String)

enum State { PLAYING, CEREMONY, GAME_OVER }

var current_state: State = State.PLAYING

var score: int = 0
var multiplier: float = 1.0
var high_score: int = 0
var faith: float = 20.0
var max_faith_for_tier: float = 100.0
var current_tier: int = 0
var max_tier_reached: int = 0

var rodar_energy: float = 0.0 # 0 a 100%
const MAX_RODAR_ENERGY: float = 100.0

const SAVE_PATH: String = "user://rezar_e_rodar_highscore.save"

func _ready() -> void:
	load_highscore()
	start_game()

func start_game() -> void:
	score = 0
	multiplier = 1.0
	current_tier = 0
	max_tier_reached = 0
	faith = 25.0
	rodar_energy = 20.0
	current_state = State.PLAYING
	update_tier_requirements()
	emit_signal("faith_changed", faith, max_faith_for_tier, faith / max_faith_for_tier)
	emit_signal("score_changed", score, multiplier)

func update_tier_requirements() -> void:
	var tier_reqs := [100.0, 250.0, 500.0, 900.0, 1500.0, 2500.0, 4000.0]
	if current_tier < tier_reqs.size():
		max_faith_for_tier = tier_reqs[current_tier]
	else:
		max_faith_for_tier = 5000.0

func add_faith(amount: float) -> void:
	if current_state != State.PLAYING:
		return
		
	faith += amount
	if amount > 0:
		rodar_energy = min(rodar_energy + (amount * 0.4), MAX_RODAR_ENERGY)
	
	if faith >= max_faith_for_tier:
		# Atingiu a fé necessária para subir de pneu!
		trigger_tire_upgrade()
	elif faith <= 0:
		faith = 0.0
		trigger_game_over()
		
	emit_signal("faith_changed", faith, max_faith_for_tier, clamp(faith / max_faith_for_tier, 0.0, 1.0))

func add_score(base_pts: int) -> void:
	if current_state != State.PLAYING:
		return
	var gained := int(float(base_pts) * multiplier)
	score += gained
	if score < 0:
		score = 0
	emit_signal("score_changed", score, multiplier)

func trigger_tire_upgrade() -> void:
	if current_tier >= 6:
		# Já está no pneu cósmico, dá pontuação colossal
		score += int(1000.0 * multiplier)
		faith = max_faith_for_tier * 0.7
		emit_signal("score_changed", score, multiplier)
		return
		
	current_tier += 1
	if current_tier > max_tier_reached:
		max_tier_reached = current_tier
		
	current_state = State.CEREMONY
	faith = 30.0 # Reinicia a fé base para o próximo pneu
	update_tier_requirements()
	
	var data: Dictionary = TireAltar.TIERS_DATA[current_tier]
	emit_signal("tire_upgraded", current_tier, data["name"], data["desc"])
	emit_signal("ceremony_started", 3.0)
	
	# Retoma o jogo após a animação de reza
	var timer := get_tree().create_timer(3.0)
	timer.timeout.connect(func():
		if current_state == State.CEREMONY:
			current_state = State.PLAYING
	)

func can_activate_rodar() -> bool:
	return current_state == State.PLAYING and rodar_energy >= 80.0

func activate_rodar_boost() -> void:
	if not can_activate_rodar():
		return
	rodar_energy = 0.0
	multiplier *= 1.5
	emit_signal("rodar_boost_activated", 6.0)
	
	# Timer para restaurar o multiplicador normal
	var timer := get_tree().create_timer(6.0)
	timer.timeout.connect(func():
		multiplier = max(1.0, multiplier / 1.5)
		emit_signal("score_changed", score, multiplier)
	)

func apply_wheel_prize(prize: Dictionary) -> void:
	score += int(prize["score"] * multiplier)
	multiplier *= float(prize["mult"])
	emit_signal("score_changed", score, multiplier)

func trigger_game_over() -> void:
	if current_state == State.GAME_OVER:
		return
	current_state = State.GAME_OVER
	
	if score > high_score:
		high_score = score
		save_highscore()
		
	var data: Dictionary = TireAltar.TIERS_DATA[current_tier]
	var rank := get_rank(max_tier_reached, score)
	emit_signal("game_over_triggered", score, data["name"], rank)

func get_rank(tier: int, final_score: int) -> String:
	match tier:
		0:
			return "Pneu Murcho (A fé fraquejou antes da primeira oração!)"
		1:
			return "Devoto do Uno (Mais 72 horas no acostamento!)"
		2:
			return "Patriota Agro-Hilux (Bandeira fincada e churrasco garantido!)"
		3:
			return "Guardião da BR-101 (Ouvindo áudio do General dia e noite!)"
		4:
			return "Comandante do Trator Sagrado (Aro de ouro e fumaça abençoada!)"
		5:
			return "Titã da Mineração (Palanque erguido para a multidão!)"
		6:
			return "O ELEITO DOS EXTRATERRESTRES E DA ORDEM SUPREMA! 🛸🇧🇷"
		_:
			return "Lorde da Resistência das 72 Horas"

func save_highscore() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_32(high_score)

func load_highscore() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()
