class_name Enemy extends CharacterBody2D

@onready var anim = $AnimationPlayer
@onready var deathSFX = $DeathSFX
@onready var enemyArea = $EnemyArea
@onready var sprite = $Sprite2D
@onready var deathPrtcles = $DeathParticles
@onready var defTimer = $DefaultTimer
@onready var shootPos = $ShootPosition
@onready var sfxPlayer = $SFXPlayer

@export var canTakeDamage = true
@export var bulletPrefab: PackedScene
@export var healthpoints = 5
@export var contactDamage = 1
@export var affectedByGravity = false
@export var maxFallVelocity = 200.0
@export var enemyDeathEffect: PackedScene

var flipInt = 1
var isDead = false
var isActive = false

#Movement variables

var player
var curHealth = 0
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	curHealth = healthpoints
	
	if scale.x >= 0:
		flipInt = 1
	else:
		flipInt = -1
	
	#print(name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause"):
		defTimer.paused = !defTimer.paused
	
	#if scale.x >= 0:
	#	flipInt = 1
	#else:
	#	flipInt = -1

func _physics_process(delta):
	delta = delta * GlobalVar.timeScale
	if (GlobalVar.timeScale > 0.0):
		if not is_on_floor() && affectedByGravity:
			velocity.y += get_gravity().y * delta
			velocity.y = min(velocity.y, maxFallVelocity) 
		
		move_and_slide()

func shoot(angle: float, speed: float, flpInt: int, shtPos: Node, bullet: PackedScene):
	var shootVector = Vector2(cos(deg_to_rad(angle)), sin(deg_to_rad(angle)))
	
	#var bulletOrigin = shootPos.global_position
	#var bulletDestin = shootVector
	#shootPos.request_projectile(0, bulletOrigin, bulletDestin + bulletOrigin)
	#curBul.speed *= flipInt
	
	
	var curBullet = bullet.instantiate()
	add_sibling(curBullet)
		
	curBullet.global_position = shootPos.global_position
	curBullet.bulletParent = self
	curBullet.angle = angle
	if (flpInt == -1):
		curBullet.angle -= 180
	curBullet.speed = speed
	
# This function will change the way projectiles collide.
func custom_collision(proj: Projectile2D, area_rid: RID, area: Node2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.collision_layer == 2:
		var playerScript = area
		print(playerScript.name)
		if (playerScript.canTakeDamage) and (!playerScript.isDashing):
			playerScript.playerHealthLose(1)
	
	# The "on_pierced" method makes sure that:
	# -> The projectile refreshes its rehit cooldown and angular speed.
	# -> The projectile appends colliding areas/bodies to its excluded targets.
	# -> The projectile instance reduces its remaining pierce.
	proj.on_pierced(area_rid)

func loseHealth(h: int):
	if(isActive) and (canTakeDamage):
		curHealth -= h
		
		if curHealth <= 0:
			death()

func death():
	defTimer.stop()
	enemyArea.monitoring = false
	enemyArea.monitorable = false
	#enemyArea.queue_free()
	canTakeDamage = false
	if anim != null:
		anim.stop()
	
	deathPrtcles.emitting = true
	sprite.visible = false
	deathSFX.play()
	isDead = true
	
	tossEnemy(global_position, sprite)

func tossEnemy(edePos: Vector2, sprt: Sprite2D):
	if (enemyDeathEffect != null):
		var ede = enemyDeathEffect.instantiate()
		add_sibling(ede)
		ede.global_position = edePos
		ede.sprite.hframes = sprt.hframes
		ede.sprite.vframes = sprt.vframes
		ede.sprite.frame = sprt.frame
		ede.sprite.texture = sprt.texture
		ede.launch()
		
#func tossEnemyNode(curEDE: Node):
#	if (curEDE != null):
#		var ede = curEDE.duplicate()
#		add_sibling(ede)
#		ede.global_position = curEDE.global_position
#		ede.sprite.hframes = sprite.hframes
#		ede.sprite.vframes = sprite.vframes
#		ede.sprite.frame = sprite.frame
#		ede.sprite.texture = sprite.texture
#		ede.launch()

func _on_enemy_area_area_entered(area):
	if area.collision_layer == 2:
		print("Aw geez...", healthpoints)
		var playerScript = area.owner
		playerScript.playerHealthLose(contactDamage)
	
	if area.collision_layer == 4:
		print("Aw geez...", healthpoints)
		loseHealth(1)
	
	if (area.name == "CameraObj"):
		defTimer.paused = false
		isActive = true

func _on_enemy_area_area_exited(area):
	if (area.name == "CameraObj"):
		defTimer.paused = true
		isActive = false
	
	#if area.collision_layer == 8:
	#	loseHealth(1)
	#	area.queue_free()
