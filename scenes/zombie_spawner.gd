extends Node2D

@export var zombie_scene: PackedScene

@export var grass_atlas_cords := Vector2i(1, 0)

@export var zombies_per_spawn := 1
@export var spawn_interval := 5.0
@export var max_zombies := 10

@onready var ground_layer: TileMapLayer = $"../TileMapLayer"

var rng := RandomNumberGenerator.new()
var is_night := false
var spawn_timer := 0.0


func _ready() -> void:
	rng.randomize()


func _process(delta: float) -> void:
	if not is_night:
		return
	
	spawn_timer -= delta
	
	if spawn_timer <= 0.0:
		spawn_zombies()
		spawn_timer = spawn_interval

func spawn_zombies() -> void:
	var current_zombies := get_tree().get_nodes_in_group("zombies").size()
	
	if current_zombies >= max_zombies:
		return
	
	var used_rect := ground_layer.get_used_rect()
	
	for i in range(zombies_per_spawn):
		if current_zombies >= max_zombies:
			return
		
		var x := rng.randi_range(used_rect.position.x, used_rect.end.x - 1)
		
		var y := rng.randi_range(used_rect.position.y, used_rect.end.y - 1)
		
		var cell := Vector2i(x, y)
		
		if ground_layer.get_cell_source_id(cell) == -1:
			continue
		
		var atlas_coords: Vector2i = ground_layer.get_child_atlas_coords(cell)
		
		if atlas_coords != grass_atlas_cords:
			continue
		
		var zombie = zombie_scene.instantiate()
		
		add_child(zombie)
		
		zombie.global_position = ground_layer.to_global(ground_layer.map_to_local(cell))
		
		current_zombies += 1


func start_night() -> void:
	is_night = true

func start_day() -> void:
	is_night = false
	kill_all_zombies()
	

func kill_all_zombies() -> void:
	for zombie in get_tree().get_nodes_in_group("zombies"):
		zombie.queue_free()
	
	
	
