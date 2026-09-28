extends CharacterBody2D

signal died
signal health_changed(new_health: int)

const SPEED = 350.0
var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var hitbox_offset: Vector2
var bodies_in_hitbox: Array[Node2D] = []
var strength: int = 20
var max_health: int
var health: int
var knockback_velocity: Vector2 = Vector2.ZERO
var alive: bool = true


@onready var hitbox: Area2D = $Hitbox
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swingsword: AudioStreamPlayer2D = $swingsword
@onready var player_hurt: AudioStreamPlayer2D = $PlayerHurt
@onready var damage_cooldown: Timer = $DamageCooldown
@onready var footsteps: AudioStreamPlayer2D = $footsteps

@export var inventory: Inventory

func _ready() -> void:
	health = playerstats.health
	max_health = playerstats.max_health
	hitbox_offset = hitbox.position
	
func _physics_process(_delta: float) -> void:
	if alive:
		if knockback_velocity != Vector2.ZERO:
			velocity = knockback_velocity
			knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 800.0 * _delta)
			process_animation()
			move_and_slide()
			return 
		else:
			
			if Input.is_action_just_pressed("attack") and not is_attacking :
				attack()
			if is_attacking:
				velocity = Vector2.ZERO
				return
		
		_process_movement()
		process_animation()
		move_and_slide()


# Movement and Animation



func _process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
		if not footsteps.playing:
			footsteps.play()
	else:
		velocity = Vector2.ZERO
		footsteps.stop()

	


func process_animation() -> void:
	if is_attacking:
		return
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)



func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	elif dir.y < 0:
		animated_sprite_2d.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite_2d.play(prefix + "_down")

# Attacking

func attack() -> void:
	is_attacking = true 
	swingsword.play()
	play_animation("attack", last_direction)
	 
	for body in bodies_in_hitbox:
		if body.name.begins_with("Zombie"):
			body.take_damage(strength, position)
			print("HIT: ", body.name)
	



func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false


# Hitbox 

func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match last_direction:
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.DOWN:
			hitbox.position = Vector2(y, x)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)


func _on_hitbox_body_entered(body: Node2D) -> void:
	bodies_in_hitbox.append(body)
	print("ENTERED: ", body.name)




func _on_hitbox_body_exited(body: Node2D) -> void:
	bodies_in_hitbox.erase(body)
	print("EXITED: ", body.name)

func heal(amount: int) -> void:
	health += amount
	if health >= max_health:
		health = max_health
	playerstats.health = health
	health_changed.emit(health)



func take_damage(amount: int) -> void:
	if not alive:
		return
	if damage_cooldown.time_left > 0:
		return
		
	health -= amount
	health = max(health, 0)
	
	
	playerstats.health = health
	health_changed.emit(health)
	player_hurt.play()
	print("player took damage: ", health)
	damage_cooldown.start()
	if health <= 0:
		die()

func die() -> void:
	alive = false
	animated_sprite_2d.play("die")
	await animated_sprite_2d.animation_finished
	died.emit()
