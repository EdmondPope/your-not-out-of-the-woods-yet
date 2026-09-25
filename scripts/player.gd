extends CharacterBody2D


const SPEED = 350.0
var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var hitbox_offset: Vector2
var bodies_in_hitbox: Array[Node2D] = []
var strength: int = 20
var max_health: int = 100
var health: int = 100


@onready var hitbox: Area2D = $Hitbox
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swingsword: AudioStreamPlayer2D = $swingsword

func _ready() -> void:
	hitbox_offset = hitbox.position

func _physics_process(_delta: float) -> void:
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
	else:
		velocity = Vector2.ZERO
	
	velocity=direction * SPEED
	


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



func take_damage(amount: int) -> void:
	health -= 10
	print(health)
