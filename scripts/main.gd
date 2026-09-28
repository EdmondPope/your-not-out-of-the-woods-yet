extends Node2D

@onready var player: CharacterBody2D = $Topdownworldgeneration/Player
@onready var hud: CanvasLayer = $HUD

func _ready() -> void:
	print("Main Started")
	print("PLAYER = ", player)
	print("HUD = ", hud)
	
	player.died.connect(_on_player_died)
	hud.set_player(player)
	
	await hud.fade_in()


func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout
	
	print("Fadeing out")
	await hud.fade_out()
	print("relaoding")

	playerstats.health = playerstats.max_health
	get_tree().reload_current_scene()
