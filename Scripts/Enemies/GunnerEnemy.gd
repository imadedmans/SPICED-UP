extends Enemy

@export var numOfBullets = 3
@export var timeCooldown = 2.0
@export var timeBetweenShot = 0.2

var isShooting = false
@export var isSTILLshooting = false
var curBulletNum = 0

func _ready():
	super()
	curBulletNum = numOfBullets
	defTimer.wait_time = timeCooldown

func _process(delta):
	super(delta)
	#super._on_area_2d_area_entered(Area2D)
	if (isActive) and (!isDead) and (!isShooting):
		print("Is Dead: ", isDead)
		defTimer.start()
		isShooting = true
		
	if (!isSTILLshooting):
		anim.play("GunnerIdle")

func _physics_process(delta):
	super(delta)

func _on_default_timer_timeout():
	shoot(270, 550, flipInt, shootPos, bulletPrefab)
		
	curBulletNum -= 1
	isSTILLshooting = true
	
	anim.stop()
	anim.play("GunnerShoot")
	sfxPlayer.playing = true
	
	if curBulletNum > 0:
		defTimer.wait_time = timeBetweenShot
	else: 
		curBulletNum = numOfBullets
		defTimer.wait_time = timeCooldown
		 
	defTimer.start()

func _on_enemy_area_area_entered(area):
	super(area)

func _on_enemy_area_area_exited(area):
	super(area)
