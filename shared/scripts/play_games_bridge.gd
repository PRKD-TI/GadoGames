extends Node

## PlayGamesBridge — Interface Segura para Google Play Games Services (PGS v2)
## Funciona no Android via plugin oficial e faz fallback transparente na Web e Desktop (sem travar).

signal signed_in(player_name: String, player_id: String)
signal sign_in_failed(error: String)
signal score_submitted(leaderboard_id: String, score: int)
signal achievement_unlocked(achievement_id: String)

var is_authenticated: bool = false
var player_display_name: String = "Jogador Anônimo"
var _play_games_plugin: Object = null

func _ready() -> void:
	_init_plugin()

func _init_plugin() -> void:
	if OS.has_feature("android"):
		if Engine.has_singleton("GodotPlayGamesServices"):
			_play_games_plugin = Engine.get_singleton("GodotPlayGamesServices")
			_connect_plugin_signals()
		else:
			print("[PlayGamesBridge] Plugin GodotPlayGamesServices não encontrado no Android. Modo Offline ativo.")
	else:
		print("[PlayGamesBridge] Plataforma não-Android (Web/PC). Recursos de ranking online em modo fallback.")

func _connect_plugin_signals() -> void:
	if not _play_games_plugin:
		return
	# Sinais típicos do plugin GodotPlayGamesServices
	if _play_games_plugin.has_signal("user_authenticated"):
		_play_games_plugin.connect("user_authenticated", Callable(self, "_on_user_authenticated"))
	if _play_games_plugin.has_signal("user_authentication_failed"):
		_play_games_plugin.connect("user_authentication_failed", Callable(self, "_on_auth_failed"))

## Inicia login silencioso ou interativo
func sign_in() -> void:
	if _play_games_plugin:
		if _play_games_plugin.has_method("sign_in"):
			_play_games_plugin.sign_in()
	else:
		# Fallback local imediato
		is_authenticated = false
		sign_in_failed.emit("Google Play Games disponível apenas no app Android.")

## Envia pontuação / recorde para o Placar Global
func submit_score(leaderboard_id: String, score: int) -> void:
	if _play_games_plugin and is_authenticated:
		if _play_games_plugin.has_method("submit_score"):
			_play_games_plugin.submit_score(leaderboard_id, score)
	else:
		print("[PlayGamesBridge] Score registrado localmente: %d para %s" % [score, leaderboard_id])
	score_submitted.emit(leaderboard_id, score)

## Abre a tela nativa do Google Play com o Placar
func show_leaderboard(leaderboard_id: String = "") -> void:
	if _play_games_plugin and is_authenticated:
		if leaderboard_id != "" and _play_games_plugin.has_method("show_leaderboard"):
			_play_games_plugin.show_leaderboard(leaderboard_id)
		elif _play_games_plugin.has_method("show_all_leaderboards"):
			_play_games_plugin.show_all_leaderboards()
	else:
		print("[PlayGamesBridge] Leaderboards indisponíveis fora do Android logado.")

## Desbloqueia uma Conquista (Achievement)
func unlock_achievement(achievement_id: String) -> void:
	if _play_games_plugin and is_authenticated:
		if _play_games_plugin.has_method("unlock_achievement"):
			_play_games_plugin.unlock_achievement(achievement_id)
	else:
		print("[PlayGamesBridge] Conquista simulada localmente: %s" % achievement_id)
	achievement_unlocked.emit(achievement_id)

## Abre a tela nativa de Conquistas
func show_achievements() -> void:
	if _play_games_plugin and is_authenticated:
		if _play_games_plugin.has_method("show_achievements"):
			_play_games_plugin.show_achievements()

func _on_user_authenticated(user_info) -> void:
	is_authenticated = true
	if user_info is Dictionary:
		player_display_name = user_info.get("display_name", "Patriota")
	signed_in.emit(player_display_name, "")

func _on_auth_failed(code) -> void:
	is_authenticated = false
	sign_in_failed.emit("Falha no login (%s)" % str(code))
