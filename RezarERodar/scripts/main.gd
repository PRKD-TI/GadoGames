class_name MainGame
extends Node2D

@onready var game_manager: GameManager = $GameManager
@onready var scenery: Scenery = $Scenery
@onready var tire_altar: TireAltar = $TireAltar
@onready var patriot_player: PatriotPlayer = $PatriotPlayer
@onready var bonus_spawner: BonusSpawner = $BonusSpawner
@onready var wheel_minigame: WheelMinigame = $WheelLayer/WheelMinigame
@onready var hud: HUD = $HUD
@onready var sfx: SoundEffects = $SoundEffects

var prayer_sound_cooldown: float = 0.0

func _ready() -> void:
	# Configurar referências
	wheel_minigame.sfx = sfx
	
	# Conexões do GameManager
	game_manager.faith_changed.connect(_on_faith_changed)
	game_manager.score_changed.connect(_on_score_changed)
	game_manager.tire_upgraded.connect(_on_tire_upgraded)
	game_manager.ceremony_started.connect(_on_ceremony_started)
	game_manager.rodar_boost_activated.connect(_on_rodar_boost_activated)
	game_manager.game_over_triggered.connect(_on_game_over_triggered)
	
	# Conexões da Roleta
	wheel_minigame.wheel_completed.connect(_on_wheel_completed)
	
	# Conexões do HUD
	hud.touch_left_pressed.connect(_on_touch_left)
	hud.touch_right_pressed.connect(_on_touch_right)
	hud.touch_pray_pressed.connect(_on_touch_pray)
	hud.touch_rodar_clicked.connect(_on_touch_rodar)
	hud.restart_clicked.connect(_on_restart_clicked)
	
	# Inicializar HUD
	var cur_data: Dictionary = tire_altar.get_current_tier_data()
	hud.update_tire_display(cur_data["name"])
	hud.update_highscore(game_manager.high_score)

func _process(delta: float) -> void:
	if game_manager.current_state == GameManager.State.GAME_OVER:
		if Input.is_action_just_pressed("restart"):
			_on_restart_clicked()
		return
		
	# 1. Checagem de colisão e coleta de bônus caindo
	check_bonus_collisions()
	
	# 2. Mecânica de Reza contínua perto do Pneu
	if patriot_player.is_in_prayer() and tire_altar.is_near(patriot_player.position):
		# Rezar junto ao pneu converte oração em fé contínua!
		var pray_rate := 24.0 * delta
		game_manager.add_faith(pray_rate)
		tire_altar.rotation_angle += 4.0 * delta # Pneu gira mais rápido com o clamor
		
		prayer_sound_cooldown -= delta
		if prayer_sound_cooldown <= 0.0:
			prayer_sound_cooldown = 0.45
			sfx.play_pray()
			
	# 3. Atualizar barra de energia do Rodar
	hud.update_rodar_energy(game_manager.rodar_energy, GameManager.MAX_RODAR_ENERGY)
	
	# 4. Input de Teclado para Rodar
	if Input.is_action_just_pressed("spin"):
		_on_touch_rodar()

func check_bonus_collisions() -> void:
	var catch_pos := patriot_player.get_catch_position()
	var catch_radius := 55.0
	
	for child in bonus_spawner.get_children():
		if child is BonusItem and not child.is_collected:
			var dist := catch_pos.distance_to(child.position)
			if dist < catch_radius:
				child.is_collected = true
				if child.is_hazard:
					game_manager.add_faith(child.faith_value)
					patriot_player.trigger_hit()
					sfx.play_bad()
				else:
					game_manager.add_faith(child.faith_value)
					game_manager.add_score(child.score_value)
					sfx.play_pickup()
				child.queue_free()

func _on_faith_changed(current: float, max_f: float, percent: float) -> void:
	hud.update_faith(current, max_f, percent)

func _on_score_changed(score: int, mult: float) -> void:
	hud.update_score(score, mult)

func _on_tire_upgraded(new_tier: int, tier_name: String, tier_desc: String) -> void:
	tire_altar.set_tier(new_tier)
	hud.update_tire_display(tier_name)
	hud.show_upgrade_banner(tier_name, tier_desc)
	sfx.play_upgrade()

func _on_ceremony_started(duration: float) -> void:
	patriot_player.trigger_ceremony(duration)
	bonus_spawner.is_active = false
	
	# Ao terminar a reverência da reza, abre a Roleta das 72 Horas!
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func():
		wheel_minigame.open_wheel()
	)

func _on_rodar_boost_activated(duration: float) -> void:
	tire_altar.trigger_rodar_boost(duration)
	sfx.play_upgrade()

func _on_wheel_completed(prize: Dictionary) -> void:
	game_manager.apply_wheel_prize(prize)
	bonus_spawner.is_active = true
	bonus_spawner.trigger_frenzy(7.0)
	tire_altar.trigger_rodar_boost(7.0)
	hud.show_upgrade_banner("BÊNÇÃO DAS 72 HORAS!", prize["title"])

func _on_game_over_triggered(final_score: int, max_tire: String, rank: String) -> void:
	bonus_spawner.is_active = false
	sfx.play_bad()
	hud.show_game_over(final_score, game_manager.high_score, max_tire, rank)

func _on_touch_left(pressed: bool) -> void:
	patriot_player.set_touch_dir(-1.0 if pressed else 0.0)

func _on_touch_right(pressed: bool) -> void:
	patriot_player.set_touch_dir(1.0 if pressed else 0.0)

func _on_touch_pray(pressed: bool) -> void:
	patriot_player.set_praying(pressed)

func _on_touch_rodar() -> void:
	if wheel_minigame and wheel_minigame.visible:
		return
	if game_manager and game_manager.can_activate_rodar():
		if bonus_spawner:
			bonus_spawner.is_active = false
		if tire_altar:
			tire_altar.trigger_rodar_boost(10.0)
		if wheel_minigame:
			wheel_minigame.open_wheel()
		game_manager.activate_rodar_boost()
		if sfx:
			sfx.play_upgrade()

func _on_restart_clicked() -> void:
	get_tree().reload_current_scene()
