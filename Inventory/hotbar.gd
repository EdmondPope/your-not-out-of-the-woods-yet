extends Panel

@onready var inventory: Inventory = preload("res://Inventory/playerinventory.tres")
@onready var slots: Array = $container.get_children()
@onready var selector: Sprite2D = $Selector
@onready var hud = $"../.."



var currently_selected: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update()
	inventory.updated.connect(update)


func update() -> void:
	for i in range(slots.size()):
		var inventory_slot: InventorySlot = inventory.slots[i]
		slots[i].update_to_slot(inventory_slot)
		

func move_selector() -> void:
	currently_selected = (currently_selected + 1) % slots.size()
	selector.global_position = slots[currently_selected].global_position




func _unhandled_input(event) -> void:
	if event.is_action_pressed("use"):
		inventory.use_item_at_index(currently_selected)
		playerstats.health += 20
		playerstats.health = min(playerstats.health, playerstats.max_health)
		print("health after: ", playerstats.health)
		hud._update_health(playerstats.health)
		
	if event.is_action_pressed("move_selector"):
		move_selector()
		
