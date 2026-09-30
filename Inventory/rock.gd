extends Area2D

@export var itemRes: InventoryItem

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		collect(body.inventory)


func collect(inventory: Inventory):
	inventory.insert(itemRes)
	queue_free()
