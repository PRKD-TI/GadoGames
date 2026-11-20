class_name BonusSpawner
extends Node2D

signal item_spawned(item: BonusItem)

var spawn_timer: float = 0.0
var base_interval: float = 1.3
var is_active: bool = true
var is_frenzy_mode: bool = false
var frenzy_timer: float = 0.0
var current_difficulty: float = 1.0

func _process(delta: float) -> void:
	if not is_active:
		return
		
	if is_frenzy_mode:
		frenzy_timer -= delta
		if frenzy_timer <= 0.0:
			is_frenzy_mode = false
			
	var current_interval := (base_interval / current_difficulty)
	if is_frenzy_mode:
		current_interval = 0.35 # Chuva torrencial de bônus!
		
	spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = current_interval
		spawn_random_item()

func trigger_frenzy(duration: float = 5.0) -> void:
	is_frenzy_mode = true
	frenzy_timer = duration

func set_difficulty(diff: float) -> void:
	current_difficulty = clamp(diff, 1.0, 2.5)

func spawn_random_item() -> void:
	var item := BonusItem.new()
	var start_x := randf_range(160.0, 1120.0)
	
	var chosen_type: BonusItem.ItemType
	if is_frenzy_mode:
		# Só bônus divinos durante o frenzy do Rodar!
		var positive_types := [
			BonusItem.ItemType.ZAP_72H,
			BonusItem.ItemType.LANTERNA,
			BonusItem.ItemType.CLOROQUINA,
			BonusItem.ItemType.BANDEIRA,
			BonusItem.ItemType.CAFE_TERMO,
			BonusItem.ItemType.CHURRASCO
		]
		chosen_type = positive_types[randi() % positive_types.size()]
	else:
		# 75% chance de bônus positivo, 25% de obstáculo
		var roll := randf()
		if roll < 0.28:
			# Obstáculos / perigos
			var hazard_types := [
				BonusItem.ItemType.URNA,
				BonusItem.ItemType.CHUVA,
				BonusItem.ItemType.FATO_OU_BOATO
			]
			chosen_type = hazard_types[randi() % hazard_types.size()]
		else:
			# Bônus positivos
			var positive_types := [
				BonusItem.ItemType.ZAP_72H,
				BonusItem.ItemType.LANTERNA,
				BonusItem.ItemType.CLOROQUINA,
				BonusItem.ItemType.BANDEIRA,
				BonusItem.ItemType.CAFE_TERMO,
				BonusItem.ItemType.CHURRASCO
			]
			chosen_type = positive_types[randi() % positive_types.size()]
			
	item.init_item(chosen_type, start_x, current_difficulty)
	add_child(item)
	emit_signal("item_spawned", item)
