extends TileMapLayer

@export var grass_atlas_cords := Vector2i(1, 0)

@export var tree_source_id := 0
@export var tree_atlas_cords := Vector2i(0, 0)

@export var rock_source_id := 1
@export var rock_atlas_cords := Vector2i(0, 1)

@export_range(0.0, 1.0) var tree_chance := 0.005
@export_range(0.0, 1.0) var rock_chance := 0.005


@onready var ground_layer: TileMapLayer = $"../TileMapLayer"

var rng := RandomNumberGenerator.new()



func _ready() -> void:
	rng.randomize()
	
	await get_tree().process_frame
	spawn_decorations()
	

func spawn_decorations() -> void:
	clear()
	
	var used_rect := ground_layer.get_used_rect()
	
	for x in range(used_rect.position.x, used_rect.end.x):
		for y in range(used_rect.position.y, used_rect.end.y):
			
			var cell := Vector2i(x, y)
			
			var source_id := ground_layer.get_cell_source_id(cell)
			
			if source_id == -1:
				continue
			
			var atlas_cords: Vector2i = ground_layer.get_cell_atlas_coords(cell)
			
			if atlas_cords != grass_atlas_cords:
				continue
			
			
			var random_value := rng.randf()
			
			if random_value < tree_chance:
				set_cell(cell, tree_source_id, tree_atlas_cords)
			elif random_value < tree_chance + rock_chance:
				set_cell(cell, rock_source_id, rock_atlas_cords)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
