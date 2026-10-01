extends CanvasLayer




@onready var fade_overlay: ColorRect = $FadeOverlay
@onready var heart_container: HBoxContainer = $Heart
@onready var inventory = $"InventoryGui"


var player

const HEART_FULL = preload("res://Assets/images/player/Heart_full.png")
const HEART_HALF = preload("res://Assets/images/player/Heart_half.png")
const HEART_EMPTY = preload("res://Assets/images/player/Heart_empty.png")

const HEART_SIZE: int = 20

func _ready() -> void:
	inventory.close()
	
	fade_overlay.visible = true
	fade_overlay.color.a = 1.0



func set_player(p) -> void:
	player = p
	print("hud got player: ", player)
	print("player health: ", player.health)
	print("player max health: ", player.max_health)
	
	
	
	
	
	if not player.health_changed.is_connected(_update_health):
		player.health_changed.connect(_update_health)
	
	
	_update_health(player.health)
	


func _update_health(new_health: int) -> void:
	print("UPDATE HEALTH: ", new_health)
	
	if player == null:
		return
	
	
	new_health = clampi(new_health, 0, player.max_health)
	
	
	var hearts = heart_container.get_children()
	
	print("number of hearts: ", hearts.size())
	
	for i in range(hearts.size()):
		var heart_start := i * HEART_SIZE
		
		if new_health >= heart_start + HEART_SIZE:
			hearts[i].texture = HEART_FULL
			print("heart", i + 1, ": FULL")
		
		elif new_health >= heart_start + (HEART_SIZE / 2):
			hearts[i].texture = HEART_HALF
			print("heart", i + 1, ": HALF")
		
		else:
			hearts[i].texture = HEART_EMPTY
			print("heart", i + 1, ": EMPTY")

func fade_in() -> void:
	fade_overlay.visible = true
	fade_overlay.color.a = 1.0
	
	var tween := create_tween()
	tween.tween_property(fade_overlay, "color:a", 0.0, 1.5)
	
	await tween.finished
	
	fade_overlay.visible = false

func fade_out() -> void:
	fade_overlay.visible = true
	fade_overlay.color.a = 0.0
	
	var tween:= create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 1.5)
	
	await tween.finished


func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		if inventory.isOpen:
			inventory.close()
		else:
			inventory.open()





func _on_inventory_gui_closed() -> void:
	get_tree().paused = false


func _on_inventory_gui_opened() -> void:
	get_tree().paused = true
