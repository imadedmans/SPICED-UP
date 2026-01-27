extends Enemy

@onready var irisPart = $Eye/Iris
@onready var pupilPart = $Eye/Pupil
@onready var attackPlayer = $AttackPlayer
@onready var sfx = $SFXPlayer

@export_group("Default Variables")
@export var bossHealth = 100.0
@export var lookDistanceLimit = 1000.0
@export var irisLookDivider = 120.0
@export var pupilLookDivider = 30.0
@export var lookSpeed = 6.0
@export var healthBar: Node
@export var defaultBullet: PackedScene

@export_group("First Phase Attack Variables")
@export var numOfShots: int = 3
@export var timeBetweenShoot = 0.05
@export var rdAngleChange = 100.0
@export var numOfOrbitBullets = 4
var atPlayerShotNum
var shootingAtPlayer = false
var shootingRounabout = false
var canOrbital = false
var roundaboutAngle = 0.0
var canChangeRdAngle = false
var angleChangeMultipler = -1.0

var playerPosDif = Vector2(0, 0)
var lookAtPlayerBool = false
var lookWeight = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	isActive = true
	if player == null:
		player = get_parent().get_node("Player")
	
	curHealth = bossHealth / 2.0

func _process(delta):
	if Input.is_action_just_pressed("test"):
		attackPlayer.play("OrbitalAttack")
	
	if healthBar != null:
		healthBar.value = curHealth

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	lookAtPlayer(lookAtPlayerBool, delta)
	if canChangeRdAngle:
		roundaboutAngle += angleChangeMultipler * rdAngleChange * delta

func lookToggle():
	lookWeight = 0.0
	lookAtPlayerBool = !lookAtPlayerBool

func lookAtPlayer(actuallyLook: bool, fdelta: float):
	playerPosDif = player.global_position - pupilPart.global_position
	if lookWeight < 1.0:
		lookWeight += fdelta * lookSpeed
	
	var lookNorm = playerPosDif.length()
	var irisLookX = playerPosDif.x * (1 / irisLookDivider)
	var irisLookY = playerPosDif.y * (2 / irisLookDivider)
	var pupilLookX = playerPosDif.x * (1 / pupilLookDivider)
	var pupilLookY = playerPosDif.y * (2 / pupilLookDivider)
	
	var iLVector = Vector2(irisLookX, irisLookY)
	var pLVector = Vector2(pupilLookX, pupilLookY)
	var q = easeOutCubic(lookWeight)
	
	if lookAtPlayerBool:
		irisPart.position = lerp(Vector2(0, 0), iLVector, q)
		pupilPart.position = lerp(Vector2(0, 0), pLVector, q)
	else:
		irisPart.position = lerp(iLVector, Vector2(0, 0), q)
		pupilPart.position = lerp(pLVector, Vector2(0, 0), q)
	

func easeOutCubic(x: float):
	return 1 - pow(1 - x, 3)

func death():
	print("uh oh")

func startToFireAtPlayer():
	atPlayerShotNum = numOfShots
	shootingAtPlayer = true
	defTimer.wait_time = timeBetweenShoot
	defTimer.start()

func fireAtPlayer():
	var bulObj = defaultBullet.instantiate()
	add_sibling(bulObj)
	bulObj.global_position = pupilPart.global_position
	bulObj.goTowardsPosition(player.global_position)
	
	if !canOrbital: #check if orbital attack happening
		atPlayerShotNum -= 1
		if atPlayerShotNum <= 0:
			shootingAtPlayer = false
		else:
			defTimer.start()

func startRoundabout():
	shootingRounabout = true
	roundaboutAngle = 0.0
	canChangeRdAngle = false
	defTimer.wait_time = timeBetweenShoot
	defTimer.start()

func roundaboutAttack():
	var bulObj = defaultBullet.instantiate()
	add_sibling(bulObj)
	bulObj.global_position = pupilPart.global_position
	bulObj.angle = roundaboutAngle
	defTimer.start()

func roundaboutStartRotate():
	canChangeRdAngle = true
	var the = [-1.0, 1.0]
	angleChangeMultipler = the[randi() % the.size()]

func stopAttack():
	shootingAtPlayer = false
	shootingRounabout = false
	canOrbital = false

func _on_default_timer_timeout():
	sfx.stream = load("res://SFX/EntityShootDefault.wav")
	sfx.play()
	
	if shootingAtPlayer:
		fireAtPlayer()
	elif shootingRounabout:
		roundaboutAttack()

func startOrbitalAttack(rotateDir: float):
	canOrbital = true
	var newOrbit = get_node("OrbitalParent").duplicate()
	self.add_child(newOrbit)
	
	newOrbit.orbitComplete.connect(_on_orbit_complete.bind())
	newOrbit.obtainOrbits(numOfOrbitBullets)
	newOrbit.rotateSpeed *= rotateDir
	newOrbit.position = irisPart.position
	newOrbit.visible = true
	newOrbit.canRotate = true
	newOrbit.get_child(0).start()
	

func _on_orbit_complete():
	fireAtPlayer()
	sfx.stream = load("res://SFX/EntityShootDefault.wav")
	sfx.play()
