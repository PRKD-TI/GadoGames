class_name HUD
extends CanvasLayer

signal touch_left_pressed(pressed: bool)
signal touch_right_pressed(pressed: bool)
signal touch_pray_pressed(pressed: bool)
signal touch_rodar_clicked
signal restart_clicked

@onready var score_label: Label = $TopBar/ScoreLabel
@onready var multiplier_label: Label = $TopBar/MultiplierLabel
@onready var tire_label: Label = $TopBar/TireLabel
@onready var highscore_label: Label = $TopBar/HighScoreLabel

@onready var faith_bar: ProgressBar = $CenterHUD/FaithBar
@onready var faith_text: Label = $CenterHUD/FaithLabel
@onready var rodar_bar: ProgressBar = $CenterHUD/RodarBar
@onready var rodar_label: Label = $CenterHUD/RodarLabel

@onready var upgrade_panel: Panel = $UpgradePanel
@onready var upgrade_title: Label = $UpgradePanel/VBox/TitleLabel
@onready var upgrade_desc: Label = $UpgradePanel/VBox/DescLabel

@onready var game_over_panel: Panel = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/VBox/FinalScoreLabel
@onready var max_tire_label: Label = $GameOverPanel/VBox/MaxTireLabel
@onready var rank_label: Label = $GameOverPanel/VBox/RankLabel
@onready var restart_btn: Button = $GameOverPanel/VBox/RestartBtn

@onready var btn_left: Button = $TouchControls/BtnLeft
@onready var btn_right: Button = $TouchControls/BtnRight
@onready var btn_pray: Button = $TouchControls/BtnPray
@onready var btn_rodar: Button = $TouchControls/BtnRodar

var upgrade_banner_timer: float = 0.0

func _ready() -> void:
	if upgrade_panel:
		upgrade_panel.visible = false
	if game_over_panel:
		game_over_panel.visible = false
		
	# Conexão dos botões touch para celular
	if btn_left:
		btn_left.button_down.connect(func(): emit_signal("touch_left_pressed", true))
		btn_left.button_up.connect(func(): emit_signal("touch_left_pressed", false))
	if btn_right:
		btn_right.button_down.connect(func(): emit_signal("touch_right_pressed", true))
		btn_right.button_up.connect(func(): emit_signal("touch_right_pressed", false))
	if btn_pray:
		btn_pray.button_down.connect(func(): emit_signal("touch_pray_pressed", true))
		btn_pray.button_up.connect(func(): emit_signal("touch_pray_pressed", false))
	if btn_rodar:
		btn_rodar.pressed.connect(func(): emit_signal("touch_rodar_clicked"))
	if restart_btn:
		restart_btn.pressed.connect(func(): emit_signal("restart_clicked"))

func _process(delta: float) -> void:
	if upgrade_banner_timer > 0.0:
		upgrade_banner_timer -= delta
		if upgrade_banner_timer <= 0.0 and upgrade_panel:
			upgrade_panel.visible = false

func update_score(score: int, mult: float) -> void:
	if score_label:
		score_label.text = "⚡ PONTOS: %d" % score
	if multiplier_label:
		multiplier_label.text = "🔥 x%.1f" % mult

func update_highscore(h_score: int) -> void:
	if highscore_label:
		highscore_label.text = "🏆 RECORDE: %d" % h_score

func update_tire_display(tier_name: String) -> void:
	if tire_label:
		tire_label.text = "🛞 " + tier_name

func update_faith(cur: float, max_f: float, percent: float) -> void:
	if faith_bar:
		faith_bar.value = percent * 100.0
	if faith_text:
		faith_text.text = "FÉ NO PNEU: %d / %d (%d%%)" % [int(cur), int(max_f), int(percent * 100.0)]

func update_rodar_energy(cur: float, max_energy: float) -> void:
	if rodar_bar:
		rodar_bar.value = (cur / max_energy) * 100.0
	var is_ready := cur >= 80.0
	if rodar_label:
		if is_ready:
			rodar_label.text = "🌀 RODAR PRONTO! (PRESSIONE S OU CLIQUE NO BOTÃO)"
			rodar_label.modulate = Color(1.0, 0.9, 0.1)
		else:
			rodar_label.text = "ENERGIA PARA RODAR: %d%%" % int((cur / max_energy) * 100.0)
			rodar_label.modulate = Color.WHITE
			
	if btn_rodar:
		btn_rodar.disabled = not is_ready
		if is_ready:
			var pulse := sin(Time.get_ticks_msec() * 0.008) * 0.2 + 0.8
			btn_rodar.text = "🌀 RODAR! (S)"
			btn_rodar.modulate = Color(1.0, 0.95 * pulse, 0.2, 1.0)
		else:
			btn_rodar.text = "RODAR: %d%%" % int((cur / max_energy) * 100.0)
			btn_rodar.modulate = Color(0.7, 0.7, 0.7, 0.6)

func show_upgrade_banner(tier_name: String, tier_desc: String) -> void:
	if upgrade_panel:
		upgrade_panel.visible = true
		upgrade_banner_timer = 2.8
	if upgrade_title:
		upgrade_title.text = "✨ NOVO PNEU SAGRADO: " + tier_name + "! ✨"
	if upgrade_desc:
		upgrade_desc.text = tier_desc

func show_game_over(final_score: int, best_score: int, max_tire: String, rank_title: String) -> void:
	if game_over_panel:
		game_over_panel.visible = true
	if final_score_label:
		final_score_label.text = "Pontuação de Clamor: %d" % final_score
	if max_tire_label:
		max_tire_label.text = "Maior Pneu Alcançado: " + max_tire
	if rank_label:
		rank_label.text = "Patente Patriota:\n" + rank_title
	if highscore_label:
		highscore_label.text = "🏆 RECORDE: %d" % best_score
