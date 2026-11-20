extends Node2D

@onready var game_manager = $GameManager
@onready var truck = $TruckController
@onready var patriota = $PatriotaController
@onready var view_inside = $ViewInside
@onready var view_outside = $ViewOutside
@onready var hud = $HUD

func _ready() -> void:
	# Configura referências nas visões
	view_inside.patriota = patriota
	view_inside.truck = truck
	
	view_outside.patriota = patriota
	view_outside.truck = truck
	
	hud.game_manager = game_manager
	hud.patriota = patriota
	hud.truck = truck
	
	game_manager.camera_switched.connect(_on_camera_switched)
	update_view_visibility(game_manager.is_inside_view())

func _on_camera_switched(is_inside: bool) -> void:
	update_view_visibility(is_inside)

func update_view_visibility(is_inside: bool) -> void:
	view_inside.visible = is_inside
	view_outside.visible = !is_inside
