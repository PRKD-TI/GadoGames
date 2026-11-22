extends CanvasLayer

var game_manager: Node = null
var patriota: Node2D = null
var truck: Node2D = null

@onready var timer_label: Label = $TopBar/TimerLabel
@onready var coins_label: Label = $TopBar/CoinsLabel
@onready var rewards_label: Label = $TopBar/RewardsLabel
@onready var alert_label: Label = $TopBar/AlertLabel
@onready var achievement_popup: Label = $TopBar/AchievementPopup

@onready var balance_bar: ProgressBar = $CenterHUD/BalanceBar
@onready var balance_indicator: ColorRect = $CenterHUD/BalanceIndicator
@onready var camera_btn: Button = $TopBar/CameraBtn
@onready var tilt_btn: Button = $TopBar/TiltBtn
@onready var restart_top_btn: Button = $TopBar/RestartTopBtn
@onready var leaderboard_btn: Button = $TopBar/LeaderboardBtn

@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_time_label: Label = $GameOverPanel/VBox/FinalTimeLabel
@onready var best_time_label: Label = $GameOverPanel/VBox/BestTimeLabel
@onready var coins_earned_label: Label = $GameOverPanel/VBox/CoinsEarnedLabel
@onready var total_coins_label: Label = $GameOverPanel/VBox/TotalCoinsLabel
@onready var items_earned_label: Label = $GameOverPanel/VBox/ItemsEarnedLabel
@onready var rank_label: Label = $GameOverPanel/VBox/RankLabel
@onready var restart_btn: Button = $GameOverPanel/VBox/ButtonsBox/RestartBtn
@onready var leaderboard_game_over_btn: Button = $GameOverPanel/VBox/ButtonsBox/LeaderboardGameOverBtn

@onready var btn_left: Button = $TouchControls/BtnLeft
@onready var btn_right: Button = $TouchControls/BtnRight

var alert_timer: float = 0.0
var achievement_timer: float = 0.0

func _ready() -> void:
	game_over_panel.visible = false
	alert_label.visible = false
	if achievement_popup:
		achievement_popup.visible = false
		
	if rewards_label:
		rewards_label.text = ""
		
	# Conexão e exibição inicial de GadoCoins
	update_coins_display()
	GadoEconomy.coins_changed.connect(func(_total, _delta): update_coins_display())
	
	if game_manager:
		game_manager.connect("game_over_triggered", Callable(self, "_on_game_over"))
		game_manager.connect("camera_switched", Callable(self, "_on_camera_switched"))
		game_manager.connect("flag_earned", Callable(self, "_on_flag_earned"))
		game_manager.connect("tire_earned", Callable(self, "_on_tire_earned"))
		_on_camera_switched(game_manager.is_inside_view())
		
	if truck:
		truck.connect("turn_event_started", Callable(self, "_on_turn_event"))
		
	camera_btn.pressed.connect(_on_camera_btn_pressed)
	if tilt_btn:
		tilt_btn.pressed.connect(_on_tilt_btn_pressed)
		update_tilt_btn_label()
		
	if restart_top_btn:
		restart_top_btn.pressed.connect(_on_restart_pressed)
		
	if leaderboard_btn:
		leaderboard_btn.pressed.connect(_on_leaderboard_pressed)
		
	if restart_btn:
		restart_btn.pressed.connect(_on_restart_pressed)
		
	if leaderboard_game_over_btn:
		leaderboard_game_over_btn.pressed.connect(_on_leaderboard_pressed)
	
	# Configura botões de toque para mobile com haptic feedback suave
	btn_left.button_down.connect(func():
		AudioManager.trigger_haptic(20)
		if patriota: patriota.touch_input_axis = -1.0
	)
	btn_left.button_up.connect(func():
		if patriota and patriota.touch_input_axis < 0.0: patriota.touch_input_axis = 0.0
	)
	
	btn_right.button_down.connect(func():
		AudioManager.trigger_haptic(20)
		if patriota: patriota.touch_input_axis = 1.0
	)
	btn_right.button_up.connect(func():
		if patriota and patriota.touch_input_axis > 0.0: patriota.touch_input_axis = 0.0
	)

func _process(delta: float) -> void:
	if not game_manager:
		return
		
	if game_manager.current_state == 1: # PLAYING
		var mins := int(game_manager.elapsed_time / 60.0)
		var secs := fmod(game_manager.elapsed_time, 60.0)
		timer_label.text = "⏱️ TEMPO: %02d:%04.1fs" % [mins, secs]
		
		# Atualiza barra de recompensas no topo
		update_rewards_display()
		
		if patriota:
			var normalized_pos: float = (patriota.balance_pos + 1.0) / 2.0 # 0.0 a 1.0
			var bar_width: float = 400.0
			var center_x: float = get_viewport().get_visible_rect().size.x / 2.0
			balance_indicator.position.x = (center_x - (bar_width / 2.0)) + (normalized_pos * (bar_width - 20.0))
			
			if abs(patriota.balance_pos) > 0.65:
				balance_indicator.color = Color.RED
			elif abs(patriota.balance_pos) > 0.35:
				balance_indicator.color = Color.YELLOW
			else:
				balance_indicator.color = Color.GREEN
				
	if alert_timer > 0.0:
		alert_timer -= delta
		if alert_timer <= 0.0:
			alert_label.visible = false
			
	if achievement_timer > 0.0:
		achievement_timer -= delta
		if achievement_timer <= 0.0 and achievement_popup:
			achievement_popup.visible = false

func update_rewards_display() -> void:
	if not rewards_label or not game_manager:
		return
	var text := ""
	
	# Bandeirinhas
	var flags: int = game_manager.flags_count if "flags_count" in game_manager else 0
	var tires: int = game_manager.tires_count if "tires_count" in game_manager else 0
	
	if flags > 0:
		# Exibe até 6 bandeirinhas ou contador agrupado
		if flags <= 5:
			for i in range(flags):
				text += "🇧🇷 "
		else:
			text += "🇧🇷 x%d " % flags
			
	if tires > 0:
		for i in range(tires):
			text += "🛞 "
			
	rewards_label.text = text

func _on_flag_earned(count: int) -> void:
	if not achievement_popup:
		return
	achievement_popup.text = "🇧🇷 +1 BANDEIRA DA PÁTRIA! (%ds Resistidos!)" % (count * 10)
	achievement_popup.modulate = Color(1.0, 0.9, 0.2, 1.0)
	achievement_popup.visible = true
	achievement_timer = 2.4

func _on_tire_earned(count: int) -> void:
	if not achievement_popup:
		return
	achievement_popup.text = "🛞 SAGRADO PNEU DE CAMINHÃO CONQUISTADO! (1 MINUTO!) 🛞"
	achievement_popup.modulate = Color(0.3, 1.0, 0.4, 1.0)
	achievement_popup.visible = true
	achievement_timer = 4.0

func update_coins_display() -> void:
	if coins_label:
		coins_label.text = "[ 🪙 %s ]" % format_number(GadoEconomy.total_coins)

func format_number(num: int) -> String:
	var s := str(num)
	var res := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		res = s[i] + res
		count += 1
		if count % 3 == 0 and i > 0:
			res = "." + res
	return res

func _on_turn_event(text: String) -> void:
	alert_label.text = text
	alert_label.visible = true
	alert_timer = 1.6

func _on_camera_btn_pressed() -> void:
	AudioManager.trigger_haptic(25)
	if game_manager:
		game_manager.toggle_camera()

func _on_tilt_btn_pressed() -> void:
	AudioManager.trigger_haptic(25)
	if patriota and "tilt_enabled" in patriota:
		patriota.tilt_enabled = !patriota.tilt_enabled
		update_tilt_btn_label()

func update_tilt_btn_label() -> void:
	if not tilt_btn:
		return
	if patriota and "tilt_enabled" in patriota and patriota.tilt_enabled:
		tilt_btn.text = "📱 SENSOR: LIGADO"
		tilt_btn.modulate = Color(0.4, 1.0, 0.5, 1.0)
	else:
		tilt_btn.text = "📱 SENSOR: DESLIGADO"
		tilt_btn.modulate = Color(0.8, 0.8, 0.8, 0.8)

func _on_camera_switched(is_inside: bool) -> void:
	if is_inside:
		camera_btn.text = "🎥 VISÃO: CABINE (C)"
	else:
		camera_btn.text = "🎥 VISÃO: EXTERNA (C)"

func _on_restart_pressed() -> void:
	AudioManager.trigger_haptic(30)
	if game_manager:
		game_manager.restart_game()

func _on_leaderboard_pressed() -> void:
	AudioManager.trigger_haptic(30)
	PlayGamesBridge.show_leaderboard("leaderboard_patriota_do_caminhao")

func _on_game_over(score: float, rank_title: String, coins_earned: int = 0, is_new_record: bool = false) -> void:
	game_over_panel.visible = true
	var mins := int(score / 60.0)
	var secs := fmod(score, 60.0)
	final_time_label.text = "Tempo Resistido: %02d:%04.1fs" % [mins, secs]
	
	var best_mins := int(game_manager.high_score / 60.0)
	var best_secs := fmod(game_manager.high_score, 60.0)
	if is_new_record:
		best_time_label.text = "🏆 NOVO RECORDE: %02d:%04.1fs! (+100 🪙)" % [best_mins, best_secs]
		best_time_label.modulate = Color(1.0, 0.9, 0.2, 1.0)
	else:
		best_time_label.text = "🏆 Recorde: %02d:%04.1fs" % [best_mins, best_secs]
		best_time_label.modulate = Color.WHITE
		
	if coins_earned_label:
		coins_earned_label.text = "🪙 Ganho na Rodada: +%d GadoCoins" % coins_earned
	if total_coins_label:
		total_coins_label.text = "🪙 Saldo Atual: [ 🪙 %s ]" % format_number(GadoEconomy.total_coins)
	
	var flags: int = game_manager.flags_count if "flags_count" in game_manager else 0
	var tires: int = game_manager.tires_count if "tires_count" in game_manager else 0
	
	if items_earned_label:
		var items_txt := "Conquistas: "
		if flags > 0:
			items_txt += "🇧🇷 x%d Bandeiras  " % flags
		if tires > 0:
			items_txt += "🛞 x%d PNEU DE CAMINHÃO! " % tires
		if flags == 0 and tires == 0:
			items_txt += "Nenhum item coletado."
		items_earned_label.text = items_txt
		
	rank_label.text = "Título: " + rank_title
