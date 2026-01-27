extends CharacterBody2D

@onready var coyoteTimer = $Timers/CoyoteTimer
@onready var shootTimer = $Timers/ShootTimer
@onready var invinTimer = $Timers/InvincibilityTimer
@onready var dashTimer = $Timers/DashTimer
@onready var trailTimer = $Timers/TrailTimer

@onready var shootPos = $ShootPos
@onready var animPlayer = $MainAnimation
@onready var hurtAnim = $HurtAnimation
@onready var sprite = $Sprite2D
@onready var sfx = $SFXPlayer
@onready var grdPartc = $GroundParticles
@onready var deathExplod = $DeathExplosion
@onready var trigArea = $TriggerArea

var gameManager
var camera

@export_group("Basic Variables")
@export var canMove = true
@export var canJump = true
@export var canShoot = true
@export var canDash = true

@export_group("Move Variables")
@export var speed = 300.0
var xDirection
var yDirection

@export_group("Jump Variables")
@export var jumpVelocity = 600.0
@export var maxFallVelocity = 1000.0
@export var coyoteTime := 0.1
var isJumping = false
var allowJump = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var canInitiateCoyote = false

@export_group("Shoot Variables")
@export var bulletPrefab: PackedScene
@export var shootCooldown := 0.2
@export var shootPosHorizontal = 24.0
@export var shootPosVertical = 27.0
var allowShoot = true

@export_group("Dash Variables")
@export var dashSpeed := 500.0
var isDashing = false
@export var dashTime = 0.3
@export var dashCooldownTime = 0.2
@export var dashCooldownGroundMultiplier = 2.0
var curDashClDwnTime = 0.0

@export_group("Health Variables")
@export var healthpoints = 3
@export var invincibilityTime = 3.0
var canTakeDamage = true
var curHealth = 0

var shakeIt = false
var isDead
var hasFlipped = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.

func _ready():
	coyoteTimer.wait_time = coyoteTime
	shootTimer.wait_time = shootCooldown
	invinTimer.wait_time = invincibilityTime
	curHealth = healthpoints
	
	print(get_tree().get_current_scene().name)
	camera = get_parent().get_node("CameraObj")

func _process(delta):
	delta = delta * GlobalVar.timeScale
	if Input.is_action_just_pressed("left"):
		hasFlipped = -1
	elif Input.is_action_just_pressed("right"):
		hasFlipped = 1
		
	if (canShoot == true) and (GlobalVar.timeScale != 0.0):
		shoot()
		
	GlobalVar.playerHealth = curHealth

func _physics_process(delta):
	delta = delta * GlobalVar.timeScale
	xDirection = Input.get_axis("left", "right")
	yDirection = Input.get_axis("up", "down")

	if (shakeIt):
		sprite.position.x = randf_range(-5, 5)
		sprite.position.y = randf_range(-5, 5)

	if (isDead):
		velocity.x = 0.0
		velocity.y = 0.0

	if (GlobalVar.timeScale > 0.0):
		if canMove == true:
			movement(delta)
			
		if canJump == true:
			jumping(delta)
		
		if canDash == true:
			dash(delta)
		
		move_and_slide()
	
	dashCooldown(delta)

func movement(subDelta):		
	velocity.x = (xDirection * speed) if (xDirection) else move_toward(velocity.x, 0, speed)
	
	if is_on_floor() and (xDirection != 0):
		animPlayer.play("PlayerRun")
	
	#if (animPlayer.is_playing() == false):
	#	if (xDirection != 0) and is_on_floor():
	#		animPlayer.play("PlayerRun")
	#	else:
	#		animPlayer.pause()

func jumping(subDelta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * subDelta
		velocity.y = min(velocity.y, maxFallVelocity) 
		if canInitiateCoyote:
			coyoteTimer.start()
			canInitiateCoyote = false
	elif is_on_floor():
		if (isJumping):
			groundParticles(true)
		
		isJumping = false
		allowJump = true
		canInitiateCoyote = true

	# Handle jump.
	if Input.is_action_just_pressed("jump") and allowJump:
		velocity.y = -jumpVelocity
		animPlayer.play("PlayerJump")
		playerSound("Jump")
		isJumping = true
		allowJump = false
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = -(jumpVelocity / 4)

func shoot():
	#Ensure direction of shooting in right direction
	var shootVector = Vector2(0, 0)
	shootPos.position = shootVector
	shootVector = Vector2(shootPosHorizontal * hasFlipped, 0) if (yDirection == 0) else Vector2(0, yDirection * shootPosVertical)
	
	#Actual shoot function
	if Input.is_action_just_pressed("shoot") and allowShoot && (bulletPrefab != null):
		var bulletOrigin = shootPos.global_position
		var bulletDestin = shootVector
		
		#Old bullet system, scrapped due to weird collision
		
		#shootPos.request_projectile(0, bulletOrigin, bulletDestin + bulletOrigin)
		
		var curBul = bulletPrefab.instantiate()
		add_sibling(curBul)
		curBul.global_position = position
		if (yDirection != 0):
			curBul.moveVector = Vector2(0, yDirection)
		else:
			curBul.moveVector = Vector2(hasFlipped, 0)
		
		#playerSound("Shoot")
		allowShoot = false
		shootTimer.start()

func playerHealthLose(h: int):
	if (canTakeDamage):
		curHealth -= h 
		if curHealth <= 0:
			justDied(false)
		else:
			canTakeDamage = false
			invinTimer.start()
			
			hurtAnim.play("PlayerHurt")
			if camera != null:
				camera.canShake = true
		
		playerSound("Hurt")

func dash(subDelta):
	var dashVector
	
	if Input.is_action_just_pressed("dash") and (!isDashing):
		dashVector = Vector2(hasFlipped, yDirection)
		if (yDirection != 0) and (xDirection == 0):
			dashVector.x = 0

		velocity = dashVector.normalized() * dashSpeed
		disableAbilities(false, false, false, true)
		animPlayer.play("PlayerDash")
		playerSound("Dash")
		dashTimer.start()
		trailTimer.start()
		
		if camera != null:
			camera.canZoom = true
			
		isDashing = true
		
func dashCooldown(subDelta: float):
	var dcm = 1.0
	if is_on_floor():
		dcm = dashCooldownGroundMultiplier
	 
	if (!canDash):
		if is_on_floor() and (curDashClDwnTime <= 0):
			canDash = true
		else:
			curDashClDwnTime -= subDelta * dcm

func justDied(hasFallen: bool):
	curHealth = 0
	isDead = true
	disableAbilities(false, false, false, false)
	var gameManger = get_tree().get_current_scene()
	
	gameManger.playerDeath(hasFallen)
	animPlayer.stop()
	trigArea.monitorable = false
	trigArea.monitoring = false

func death():
	#CHANGE THIS IDIOT >:(
	sprite.visible = false
	deathExplod.emitting = true
	#get_tree().reload_current_scene()

func disableAbilities(move: bool, jump: bool, shoot: bool, dash: bool):
	canMove = move
	canJump = jump
	canShoot = shoot
	canDash = dash

func playerSound(soundName: String):
	var SFXtoUse = load("res://SFX/Player" + soundName + ".wav")
	sfx.stream = SFXtoUse
	sfx.play()

func groundParticles(hasLanded: bool):
	var partObj = grdPartc.duplicate()
	add_child(partObj)
	
	partObj.restart()
	partObj.amount = 12 if (hasLanded) else 4
	partObj.emitting = true

func canShake(shk: bool):
	shakeIt = shk

#Timers
func _on_coyote_timer_timeout():
	allowJump = false
	#print("Cannot jump")

func _on_shoot_timer_timeout():
	allowShoot = true

func _on_invincibility_timer_timeout():
	canTakeDamage = true
	hurtAnim.stop()
	sprite.visible = true

func _on_dash_timer_timeout():
	if(canDash):
		if velocity.y < 0:
			velocity.y = -(jumpVelocity / 4)
			
		curDashClDwnTime = dashCooldownTime
		isDashing = false
		sprite.canTrail = false
		disableAbilities(true, true, true, false)
		dashTimer.start()
		
		animPlayer.stop()
		animPlayer.play("RESET")
	#else:
	#	dashTimer.wait_time = dashTime
	#	canDash = true

func _on_trail_timer_timeout():
	if isDashing == true:
		var newSprite = sprite.duplicate()
		
		newSprite.z_index = (z_index - 1)
		newSprite.position = position
		newSprite.canTrail = true
		
		get_parent().add_sibling(newSprite)
		trailTimer.start()

func _on_trigger_area_entered(area):
	if area.collision_layer == 16:
		print(area.name)
		if (canTakeDamage) and (!isDashing):
			playerHealthLose(1)
