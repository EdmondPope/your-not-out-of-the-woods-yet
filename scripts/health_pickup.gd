extends Area2D

const HEALTH_EFFECT: int = 20
@onready var collected_sound: AudioStreamPlayer2D = $CollectedSound
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@export var itemRes: InventoryItem

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		collect(body.inventory)


func collect(inventory: Inventory):
	inventory.insert(itemRes)
	queue_free()
