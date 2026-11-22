extends Node

## GadoEconomy — Gerenciador Central de Moeda e Recompensas (GadoCoin 🪙)
## Singleton / Utilitário para salvar, carregar e transacionar GadoCoins em jogos do GadoGames.

signal coins_changed(total_coins: int, delta: int)
signal purchase_successful(item_id: String, cost: int)
signal purchase_failed(item_id: String, reason: String)

const SAVE_PATH: String = "user://gadocoin.dat"
const ENCRYPTION_KEY: String = "GadoGames2026MooSecretKey" # Chave para evitar edições triviais de save

var total_coins: int = 0
var unlocked_items: Array[String] = []

func _ready() -> void:
	load_data()

## Adiciona moedas com segurança e emite sinal
func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	total_coins += amount
	coins_changed.emit(total_coins, amount)
	save_data()

## Gasta moedas se o saldo for suficiente
func spend_coins(amount: int, item_id: String = "") -> bool:
	if amount <= 0:
		return false
	if total_coins >= amount:
		total_coins -= amount
		if item_id != "" and not unlocked_items.has(item_id):
			unlocked_items.append(item_id)
		coins_changed.emit(total_coins, -amount)
		purchase_successful.emit(item_id, amount)
		save_data()
		return true
	else:
		purchase_failed.emit(item_id, "Saldo insuficiente")
		return false

## Verifica se o jogador possui um item ou skin cosmética
func has_item(item_id: String) -> bool:
	return unlocked_items.has(item_id)

## Salva dados em disco (com criptografia local)
func save_data() -> void:
	var file := FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, ENCRYPTION_KEY)
	if file:
		var data := {
			"total_coins": total_coins,
			"unlocked_items": unlocked_items,
			"version": 1
		}
		file.store_string(JSON.stringify(data))
		file.close()

## Carrega dados salvos
func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		total_coins = 0
		unlocked_items = []
		return
		
	var file := FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, ENCRYPTION_KEY)
	if file:
		var json_str := file.get_as_text()
		file.close()
		var parsed = JSON.parse_string(json_str)
		if parsed is Dictionary:
			total_coins = parsed.get("total_coins", 0)
			var items = parsed.get("unlocked_items", [])
			unlocked_items = []
			for it in items:
				unlocked_items.append(str(it))
