extends Node

signal game_started
signal game_over_triggered(score: float, rank_title: String)
signal camera_switched(is_inside_view: bool)
signal flag_earned(count: int)
signal tire_earned(count: int)

enum GameState { READY, PLAYING, GAME_OVER }
enum CameraMode { INSIDE, OUTSIDE }

var current_state: GameState = GameState.READY
var current_camera: CameraMode = CameraMode.OUTSIDE

var elapsed_time: float = 0.0
var high_score: float = 0.0
const SAVE_PATH: String = "user://patriota_highscore.save"

var flags_count: int = 0
var tires_count: int = 0

func _ready() -> void:
	load_highscore()
	start_game()

func _process(delta: float) -> void:
	if current_state == GameState.PLAYING:
		elapsed_time += delta
		
		# Conquista de bandeirinhas do Brasil a cada 10s
		var earned_flags: int = int(elapsed_time / 10.0)
		if earned_flags > flags_count:
			flags_count = earned_flags
			emit_signal("flag_earned", flags_count)
			
		# Conquista do Pneu de Caminhão ao completar 1 minuto (60s)
		var earned_tires: int = int(elapsed_time / 60.0)
		if earned_tires > tires_count:
			tires_count = earned_tires
			emit_signal("tire_earned", tires_count)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch_camera"):
		toggle_camera()
	elif event.is_action_pressed("restart"):
		restart_game()

func start_game() -> void:
	elapsed_time = 0.0
	flags_count = 0
	tires_count = 0
	current_state = GameState.PLAYING
	emit_signal("game_started")

func end_game() -> void:
	if current_state == GameState.GAME_OVER:
		return
	current_state = GameState.GAME_OVER
	
	if elapsed_time > high_score:
		high_score = elapsed_time
		save_highscore()
		
	var rank := get_rank(elapsed_time)
	emit_signal("game_over_triggered", elapsed_time, rank)

func restart_game() -> void:
	get_tree().reload_current_scene()

func toggle_camera() -> void:
	if current_camera == CameraMode.INSIDE:
		current_camera = CameraMode.OUTSIDE
	else:
		current_camera = CameraMode.INSIDE
	emit_signal("camera_switched", current_camera == CameraMode.INSIDE)

func is_inside_view() -> bool:
	return current_camera == CameraMode.INSIDE

func get_rank(time_survived: float) -> String:
	if time_survived < 10.0:
		return "Pneu Murcho (Nem pegou a 1ª bandeira!)"
	elif time_survived < 20.0:
		return "Novato do Para-choque (1 Bandeirinha 🇧🇷)"
	elif time_survived < 40.0:
		return "Resistência Verde-Oliva (Mais 72 Horas!)"
	elif time_survived < 60.0:
		return "Capitão do Capô (Quase chegou no Pneu!)"
	elif time_survived < 90.0:
		return "🛞 SACERDOTE DO PNEU SAGRADO 🛞 (Resistiu a 1 Minuto!)"
	elif time_survived < 120.0:
		return "Mestre dos Bloqueios da BR-101 🇧🇷🛞"
	else:
		return "O MITO SUPREMO DA RODOVIA NACIONAL 🇧🇷🛞👑"

func save_highscore() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_float(high_score)

func load_highscore() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_float()
