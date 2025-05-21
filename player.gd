extends CharacterBody2D

signal health_changed (new_health)
# Константы
const SPEED = 200.0
const JUMP_VELOCITY = -300.0
const DASH_SPEED = 450.0
const DASH_DURATION = 0.3
const ATTACK_COOLDOWN = 0.6
const FALL_LIMIT = 750  # Порог, ниже которого игрок считается упавшим
@onready var talk_button = $MobileControl/talk
var health = 5
@onready var dash = $Sounds/dash
var alive = true
@onready var anim = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@onready var attack_area: Area2D = $AttackArea
@onready var actionable_finder:Area2D = $Direction/ActionableFinder
@onready var hurt_sound = $Sounds/hurt
var is_dashing = false
var can_attack = true

var is_in_dialogue = false


func _physics_process(delta: float) -> void:
	if is_in_dialogue:
		return  # Пропускаем обработку физики, если идёт диалог


	if not alive:
		return  # Если игрок мертв, пропускаем обработку физики

	# Проверка падения ниже лимита
	if global_position.y > FALL_LIMIT:  # Если игрок упал ниже установленного лимита
		die()  # Вызовем смерть игрока

	# Гравитация
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0
	
	
	if Input.is_action_just_pressed("talk"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size()>0:
			actionables[0].action()
			if state.answer_correct:
				global_position = Vector2(3000, 500)
				state.answer_correct = false  # чтобы не телепортировать каждый кадр
			return
	# Прыжок
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Дэш-атака
	if Input.is_action_just_pressed("attack") and can_attack and not is_dashing:
		start_dash_attack()
		return  # Прерываем обычное движение во время атаки

	# Обычное движение
	if not is_dashing:
		var direction := Input.get_axis("move_left", "move_right")
		if direction != 0:
			velocity.x = direction * SPEED
			anim.flip_h = direction > 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

		# Выбор анимации
		if not is_on_floor():
			anim.play("Jump")
		elif direction != 0:
			anim.play("Walk")
		else:
			anim.play("Idle")

	move_and_slide()

func start_dash_attack() -> void:
	# Активация дэш-атаки
	is_dashing = true
	can_attack = false
	attack_area.monitoring = true
	anim.play("Dash")
	dash.play()

	# Определяем направление дэша
	var dash_direction = Vector2.RIGHT if anim.flip_h else Vector2.LEFT

	# Перемещаем AttackArea в сторону дэша
	if anim.flip_h:
		attack_area.position.x = 20  # Позиция справа от игрока
		set_collision_layer_value(1,false)
		set_collision_mask_value(2,false)
	else:
		attack_area.position.x = -20  # Позиция слева от игрока
		set_collision_layer_value(1,false)
		set_collision_mask_value(2,false)

	velocity = dash_direction * DASH_SPEED

	# Таймер для продолжительности дэш-атаки
	await get_tree().create_timer(DASH_DURATION).timeout
	set_collision_layer_value(1,true)
	set_collision_mask_value(2,true)
	velocity = Vector2.ZERO
	attack_area.position.x = 0  # Возвращаем AttackArea в исходное положение
	attack_area.monitoring = false
	is_dashing = false

	# Таймер восстановления атаки
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout
	can_attack = true
	
	
func _on_AttackArea_body_entered(body: Node2D) -> void:
	print("Body entered: ", body.name)  # Выводим имя объекта
	if body.is_in_group("Enemy") and is_dashing:
		print("Враг: ", body.name)  # Выводим имя врага
		
		# Наносим урон врагу
		body.take_damage(1)
		
		# Толкаем врага
		var knockback_direction = Vector2.RIGHT if anim.flip_h else Vector2.LEFT
		if body is CharacterBody2D:
			body.velocity = knockback_direction * 300
		elif body is RigidBody2D:
			body.apply_impulse(knockback_direction * 500)
			
			
func take_damage(amount: int) -> void:
	if not alive:
		return  # Если игрок мертв, не уменьшаем здоровье
	health -= amount
	emit_signal("health_changed",health)
	hurt_sound.play()
	
	anim.modulate= Color(1,0,0,1)
	print("Player health: ", health)
	
	if health <= 0:
		die()
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(anim,"modulate",Color(1,1,1,1),0.1)

func die() -> void:
	if not alive:  # Если игрок уже мертв, не повторяем смерть
		return
	
	alive = false  # Устанавливаем флаг смерти
	anim.play("death")
	print("Player died!")

	# Ожидаем окончания анимации смерти
	await anim.animation_finished  # Используем await для ожидания завершения анимации
	
	# После окончания анимации смерти вызываем удаление персонажа
	call_deferred("queue_free")  # Используем call_deferred для безопасного удаления после окончания анимации
	
	# Переключаем сцену на главное меню
	get_tree().change_scene_to_file("res://menu.tscn")



func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.has_method("action"):
		talk_button.visible = true
