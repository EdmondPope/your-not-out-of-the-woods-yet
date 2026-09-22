extends CharacterBody2D


const SPEED: int = 80.0
const KNOCKBACK_FORCE: int = 100
var target = null
var health: int = 100

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage




func _physics_process(delta: float) -> void:
	if target:
		_attack(delta)
	


func _attack(delta) -> void:
	var direction = (target.position - position).normalized()
	position += direction * SPEED * delta
	animated_sprite_2d.play()

func take_damage(damage: int, attacker_position: Vector2) -> void:
	health -= damage
	print(health)
	take_damage_sound.play()
	
	var knockback_direction = (position - attacker_position).normalized()
	var target_position = position + knockback_direction * KNOCKBACK_FORCE
	
	var tween = create_tween()
	tween.tween_property(self, "position", target_position, 0.5 )


func _on_sight_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		target = body
		print(target)


func _on_sight_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		target = null
