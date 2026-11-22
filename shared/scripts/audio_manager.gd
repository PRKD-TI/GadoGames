extends Node

## AudioManager — Gerenciador Central de Áudio e Feedback Tátil (Haptic)
## Salva automaticamente preferências de volume e vibração.

const SETTINGS_PATH: String = "user://audio_settings.cfg"

var music_volume: float = 0.8:
	set(val):
		music_volume = clampf(val, 0.0, 1.0)
		_apply_volumes()
var sfx_volume: float = 1.0:
	set(val):
		sfx_volume = clampf(val, 0.0, 1.0)
		_apply_volumes()
var haptic_enabled: bool = true

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
const MAX_SFX_PLAYERS: int = 8

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_players()
	load_settings()

func _setup_audio_players() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music" if AudioServer.get_bus_index("Music") != -1 else "Master"
	add_child(_music_player)
	
	for i in range(MAX_SFX_PLAYERS):
		var p = AudioStreamPlayer.new()
		p.bus = "SFX" if AudioServer.get_bus_index("SFX") != -1 else "Master"
		add_child(p)
		_sfx_players.append(p)

## Toca música de fundo em loop
func play_music(stream: AudioStream, crossfade: float = 0.5) -> void:
	if not stream:
		return
	if _music_player.stream == stream and _music_player.playing:
		return
	_music_player.stream = stream
	_music_player.play()

## Para a música
func stop_music() -> void:
	_music_player.stop()

## Toca efeito sonoro em um canal livre
func play_sfx(stream: AudioStream, pitch_scale: float = 1.0) -> void:
	if not stream:
		return
	for p in _sfx_players:
		if not p.playing:
			p.stream = stream
			p.pitch_scale = pitch_scale
			p.play()
			return
	# Se todos ocupados, reutiliza o primeiro
	_sfx_players[0].stream = stream
	_sfx_players[0].pitch_scale = pitch_scale
	_sfx_players[0].play()

## Dispara vibração curta no celular (Haptic Feedback)
func trigger_haptic(duration_ms: int = 40) -> void:
	if haptic_enabled and OS.has_feature("mobile"):
		Input.vibrate_handheld(duration_ms)

func _apply_volumes() -> void:
	var music_bus_idx = AudioServer.get_bus_index("Music")
	if music_bus_idx != -1:
		AudioServer.set_bus_volume_db(music_bus_idx, linear_to_db(music_volume))
		AudioServer.set_bus_mute(music_bus_idx, music_volume <= 0.01)
		
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		AudioServer.set_bus_volume_db(sfx_bus_idx, linear_to_db(sfx_volume))
		AudioServer.set_bus_mute(sfx_bus_idx, sfx_volume <= 0.01)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "haptic_enabled", haptic_enabled)
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		music_volume = config.get_value("audio", "music_volume", 0.8)
		sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
		haptic_enabled = config.get_value("audio", "haptic_enabled", true)
	_apply_volumes()
