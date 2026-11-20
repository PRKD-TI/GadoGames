class_name SoundEffects
extends Node

# Sintetizador procedural de áudio para Godot 4.3 (100% autônomo, Web e Mobile)
var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _sample_rate := 44100.0

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = _sample_rate
	generator.buffer_length = 0.15
	_player.stream = generator
	add_child(_player)
	_player.play()
	_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback

func play_tone(freq: float, duration: float, volume: float = 0.25, wave_type: String = "sine") -> void:
	if not _playback:
		return
	var frames := int(_sample_rate * duration)
	for i in range(frames):
		var t := float(i) / _sample_rate
		var sample := 0.0
		var envelope := 1.0 - (float(i) / float(frames)) # Fade out
		
		if wave_type == "sine":
			sample = sin(TAU * freq * t)
		elif wave_type == "square":
			sample = 1.0 if sin(TAU * freq * t) > 0.0 else -1.0
		elif wave_type == "triangle":
			sample = (asin(sin(TAU * freq * t)) * (2.0 / PI))
			
		var val := sample * volume * envelope
		if _playback.can_push_buffer(1):
			_playback.push_frame(Vector2(val, val))

func play_pickup() -> void:
	# Dois bips alegres ascendentes
	play_tone(587.33, 0.06, 0.2, "sine") # D5
	play_tone(880.0, 0.10, 0.2, "sine")  # A5

func play_pray() -> void:
	# Tom ressonante / coro espiritual
	play_tone(329.63, 0.12, 0.18, "triangle") # E4
	play_tone(659.25, 0.08, 0.12, "sine")     # E5

func play_upgrade() -> void:
	# Fanfarra triunfante
	play_tone(440.0, 0.08, 0.3, "triangle") # A4
	play_tone(554.37, 0.08, 0.3, "triangle") # C#5
	play_tone(659.25, 0.10, 0.35, "triangle") # E5
	play_tone(880.0, 0.22, 0.4, "sine")      # A5

func play_spin_tick() -> void:
	# Clique mecânico da roleta
	play_tone(900.0, 0.02, 0.15, "square")

func play_bad() -> void:
	# Som de choque / erro
	play_tone(150.0, 0.15, 0.3, "square")
	play_tone(110.0, 0.25, 0.3, "sawtooth" if false else "square")

func play_cheer() -> void:
	# Glória e confetes
	play_tone(523.25, 0.08, 0.25, "sine") # C5
	play_tone(659.25, 0.08, 0.25, "sine") # E5
	play_tone(783.99, 0.15, 0.3, "sine")  # G5
	play_tone(1046.50, 0.25, 0.35, "triangle") # C6
