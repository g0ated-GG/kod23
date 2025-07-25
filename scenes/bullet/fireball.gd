class_name Fireball
extends GenericEnemy

@export var explosion_damage : int = 40
@export var caster : Node2D
@export var speed_min : int = 100
@export var speed_max : int = 150
@export var life_time : float = 7.0

func _ready() -> void:
	$ExplosionArea2D.body_entered.connect(ignition)
	death.connect(explosion)
	speed = randi_range(speed_min, speed_max)
	$LifeTimer.start(life_time)
	$GPUParticles2D.emitting = Globals.particles

func ignition(target) -> void:
	if alive and target != self and target != caster:
		explosion()

func explosion() -> void:
	alive = false
	$LifeTimer.stop()
	$FireballAnimationPlayer.play('explosion')
	$AfterLifeTimer.start(1.0)
	for target in $ExplosionArea2D.get_overlapping_bodies():
		if target is Player and target.get_collision_layer_value(7):
			continue
		if target != self and target is not Arrow:
			target.damage(explosion_damage)
	$CollisionShape2D.set_deferred('disabled', true)

func explosion_effect() -> void:
	if Globals.particles:
		$ExplosionParticles2D.emitting = true
	else:
		hide()

func damage(points : int) -> void:
	hp = clamp(hp - points, 0, hp_max)
	hp_changed.emit()
	if hp == 0 and alive:
		alive = false
		death.emit()

func _on_life_timer_timeout() -> void:
	self.damage(1)

func _on_after_life_timer_timeout() -> void:
	queue_free()
