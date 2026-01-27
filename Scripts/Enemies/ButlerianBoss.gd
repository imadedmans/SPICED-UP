extends Enemy

@onready var attackPhase = $AttackPhases

var despPhase = 0
#Health = 31-45 -> Value: 0
#Health = 16-30 -> Value: 1
#Health =  0-15 -> Value: 2

@export var speed = 200.0
@export var timeTillJump = 2.5
@export var avgDistance = 2000.0
@export var rotateSpeed = 50.0

var curSpeed = 0
var actJumpForce = 0

@export var canJump = false
@export var canRotate = false
var isJumping = false
var beginJump = true
var hasJumped = true

var numOfShots = 20
var curNmOfShots = 0
var canRapidShoot = false
var curTBS = 0
var timeBefSht = 0

var canChangePhase
var phases = [0, 1, 2, 3]
var curPhaseInt = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	phases.shuffle()
	switchPhases()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	if curHealth <= ((2 * healthpoints) / 3):
		despPhase = 1

func _physics_process(delta):
	super(delta)
		
	if canJump:
		velocity.x = curSpeed
		if is_on_floor() and isJumping:
			endJump()
			
		if !is_on_floor() and !isJumping:
			isJumping = true
			velocity.y -= 0
			
	if canRotate:
		sprite.rotation += rotateSpeed * delta
		if is_on_floor():
			sprite.rotation = 0
			canRotate = false
	
	if (curTBS < 0) and (curNmOfShots != 0) and (canRapidShoot):
		rapidFire(0, 0)
	else:
		curTBS -= delta
	
	move_and_slide()

func switchPhases():
	var animToPlay: String = ""
	
	match(phases[curPhaseInt]):
		0:
			animToPlay = "JumpNShoot"
		1:
			animToPlay = "JumpNShoot"
		2:
			animToPlay = "JumpNShoot"
		3:
			animToPlay = "JumpNShoot"
	
	flipInt = pow(-1, curPhaseInt)
	#print(scale.x)
	attackPhase.play(animToPlay)
	
	if curPhaseInt < 3:
		curPhaseInt += 1

func jump(jumpForce: float, xDistance: float, jumpToPlayer: bool):
	var distFromPlayer = absf(position.x - player.position.x)
	
	if (!jumpToPlayer):
		curSpeed = xDistance * flipInt
	else:
		curSpeed = speed if (player.position.x > position.x) else -speed
		if distFromPlayer < avgDistance:
			curSpeed = curSpeed * ((1 / avgDistance) * distFromPlayer) * flipInt
			
	velocity.x = curSpeed
	velocity.y -= jumpForce
	actJumpForce = jumpForce
			
	canJump = true

func rapidFire(numOfShots: int, tbs: float):
	if (curNmOfShots == 0):
		curNmOfShots = numOfShots
	if (timeBefSht == 0):
		timeBefSht = tbs
	curTBS = timeBefSht
	shoot(rad_to_deg(sprite.rotation), 500, 1, shootPos, bulletPrefab)
	curNmOfShots -= 1
	if (curNmOfShots <= 0):
		canRapidShoot = false
	else:
		canRapidShoot = true

		

func targetJump():
	#Kinematics will be applied here
	#s = distance
	#u = 
	#v = 
	#a = -9.81
	#t = uhhh
	pass

func endJump():
	velocity.x = 0
	canJump = false
