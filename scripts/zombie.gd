extends CharacterBody2D


const SPEED: int = 100.0
const KNOCKBACK_FORCE: int = 100

var target = null
var health: int = 100
var random_direction: Vector2 = Vector2.ZERO
var random_timer: float = 0.0
var is_alive: bool = true
var is_attacking: bool = false
var last_direction: Vector2 = Vector2.DOWN
var strength: int = 10


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var health_bar: Node2D = $HealthBar





func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	if is_attacking:
		velocity = Vector2.ZERO
		return
	
	
	if random_timer > 0:
		random_timer -= delta
	
	
	if target:
		_attack(delta)
	else:
		velocity = Vector2.ZERO
		
	process_animation()


func _attack(delta: float) -> void:
	var direction = (target.position - position).normalized()
	
	if random_timer <= 0:
		random_timer = randf_range(0.2, 0.5)
		
		random_direction = Vector2( randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	
	direction += random_direction * 0.3
	direction = direction.normalized()
	
	velocity = direction * SPEED
	
	if direction != Vector2.ZERO:
		last_direction = direction
		
	move_and_slide()
	
func play_animation(prefix: String, dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
		
	elif dir.y < 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play(prefix + "_up")
	
	elif dir.y > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play(prefix + "_down")


func process_animation() -> void:
	if not is_alive:
		return
	
	if is_attacking:
		return

	if velocity != Vector2.ZERO:
		play_animation("walk", last_direction)
	else:
		play_animation("idle", last_direction)

func _die() -> void:
	is_alive = false
	velocity = Vector2.ZERO
	
	animated_sprite_2d.play("die")
	
	take_damage_sound.play()
	
	$CollisionShape2D.set_deferred("disabled", true)
	$Sight/CollisionShape2D.set_deferred("disabled", true)
	

func take_damage(damage: int, attacker_position: Vector2) -> void:
	if not is_alive:
		return
	health -= damage
	health_bar.update_health(health)
	if health <= 0:
		_die()
		return
	else:
		take_damage_sound.play()
	
		var knockback_direction = (position - attacker_position).normalized()
		var target_position = position + knockback_direction * KNOCKBACK_FORCE
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "position", target_position, 0.5 )


func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target = body
		print(target)


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player" and is_alive:
		target = null
		animated_sprite_2d.play("idle_down")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.name == "Player" and is_alive and not is_attacking:
		is_attacking = true
		velocity = Vector2.ZERO
		
		var direction = (body.position - position).normalized()
		if direction != Vector2.ZERO:
			last_direction = direction
		
		play_animation("attack", last_direction)
		
		body.take_damage(strength)
		
		var knockback_direction = direction
		var target_position = body.position + knockback_direction * KNOCKBACK_FORCE
		
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(body, "position", target_position, 0.3)


func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
