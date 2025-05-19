extends CharacterBody2D

var chase = false
var speed = 150
var alive = true

@onready var anim = $AnimatedSprite2D
@onready var player = $"../Player"
@onready var hurt_sound = $Node2D/hurt
@onready var attack_sound = $Node2D/attack
var health = 3
var attack_range = 30
var damage = 1
var can_attack = true
var attack_cooldown = 2.0
var already_hit = false  # Чтобы не нанести урон дважды за одну анимацию
func _ready():
	add_to_group("Enemy")
# Кадр, в который враг наносит урон (проверь в редакторе)
const ATTACK_HIT_FRAME = 3

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player and alive:
		var direction = (player.position - position).normalized()
		var distance = position.distance_to(player.position)

		if chase:
			if distance > attack_range:
				velocity.x = direction.x * speed
				anim.play("walk")
			else:
				velocity.x = 0
				if can_attack:
					attack()
			anim.flip_h = direction.x < 0
		else:
			velocity.x = 0
			anim.play("Idle")
			anim.flip_h = direction.x < 0

	move_and_slide()


func attack():
	anim.play("attack")
	attack_sound.play()
	can_attack = false
	already_hit = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true


func _on_animatedSprite2D_frame_changed():
	if anim and anim.animation == "attack" and anim.frame == ATTACK_HIT_FRAME and not already_hit:
		if player and position.distance_to(player.position) <= attack_range:
			if player.has_method("take_damage"):
				player.take_damage(damage)
				already_hit = true


func take_damage(amount: int):
	if not alive:
		return
	health -= amount
	hurt_sound.play()
	anim.modulate= Color(1,0,0,1)
	anim.play("hurt")
	print("Enemy health: ", health)
	if health <= 0:
		death()
	else:
		anim.play("hurt")
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(anim,"modulate",Color(1,1,1,1),0.1)


func death():
	alive = false
	anim.play("death")
	velocity = Vector2.ZERO
	await anim.animation_finished
	queue_free()


func _on_detector_body_entered(body: Node2D):
	if body.name == "Player":
		chase = true

func _on_detector_body_exited(body: Node2D):
	if body.name == "Player":
		chase = false
