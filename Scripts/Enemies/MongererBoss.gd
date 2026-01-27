extends Enemy

@onready var body = $Body
@onready var attackPhases = $AttackPhases
@onready var ballShotPosA = $Body/BallShotPos1
@onready var ballShotPosB = $Body/BallShotPos2
@onready var linkPosA = $Body/LinkPos1
@onready var linkPosB = $Body/LinkPos2
@onready var eye = $Body/Eye
@onready var clawA = $Claw1
@onready var clawB = $Claw2
@onready var debrisTile = $DebrisTile

@export var link: PackedScene
@export var theBall: PackedScene
@export var moveSpeed = 1.0 
@export var minPoint = Vector2(-80, -150)
@export var maxPoint = Vector2(40, 150)
@export var normBulletSpeed = 400.0 
@export var numOfLinks: int = 5
@export var part2Delete: NodePath

var moveWeight = 0
var curPos = Vector2(0, 0)
var origPos = Vector2(0, 0)
var newPos = Vector2(0, 0)
var linkObjs = []
var wakeUp = false

var moveToRand = false
var moveToCenter = false
var moveToPlayer = false
var normShootCount = 2
var shakeIt = false
var canLink = true
var lookAtPlayer = true

var isDying = false
var oneOverLinkNumFlt = 0.0
var curLinkPairInt = 0

var debrisTileArr = []
var eyeOGPos
 
# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	
	shootPos = $Body/NormShotPos
	enemyArea = $Body/EnemyArea
	sprite = $Body/Sprite2D
	
	origPos = body.global_position
	newPos = body.global_position
	curPos = body.global_position
	
	minPoint = minPoint + body.global_position
	maxPoint = maxPoint + body.global_position
	
	eyeOGPos = eye.global_position
	normShootCount = randi_range(2, 3)
	
	#Create fake blocks
	debrisTile.visible = true
	debrisTileArr.append(debrisTile)
	for i in range(3):
		var newDebrs = debrisTileArr[0].duplicate()
		add_child(newDebrs)
		newDebrs.position.y += 96 * (i + 1)
		debrisTileArr.append(newDebrs)
	
	#print(get_node("Link").position)
	for i in range(2):
		var newLinkArray = []
		for j in range(numOfLinks):
			var newLink = link.instantiate()
			add_child(newLink)
			newLink.name = "Link " + str(j * (i + 1))
			newLinkArray.append(newLink)
			#print(newLinkArray[i].name)
		linkObjs.append(newLinkArray)
	
	if (canLink):
		linkBody()
	
	#if (isActive):
	#	attackPhases.play("MongererShoot")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if (isActive) and (!wakeUp):
	#	attackPhases.play("MongererShoot")
	#	wakeUp = true
		

func _physics_process(delta):
	if moveWeight < 1:
		body.global_position = curPos.lerp(newPos, moveWeight) 
		moveWeight += delta * moveSpeed
		moveWeight = pow(moveWeight, 0.8)
	
	if (moveToRand):
		newPos.x = randf_range(minPoint.x, maxPoint.x)
		newPos.y = clamp(player.position.y, minPoint.y, maxPoint.y)
		curPos = body.global_position
		moveWeight = 0
		moveToRand = false
	
	if (moveToCenter):
		newPos = origPos
		curPos = body.global_position
		moveWeight = 0
		moveToCenter = false
	
	if (moveToPlayer):
		newPos = player.position
		curPos = body.global_position
		moveWeight = 0
		moveToPlayer = false
	
	if (shakeIt):
		body.global_position.x = randi_range(origPos.x - 10, origPos.x + 10)
		body.global_position.y = randi_range(origPos.y - 10, origPos.y + 10)
	
	if (canLink):
		linkBody()
	
	if (lookAtPlayer):
		eyeShake()
	
	if (isDying):
		destroyLinks()

func startAttacking():
	origPos = body.global_position
	attackPhases.play("MongererShoot")

func moveToAPosition(moveInt: int):
	match(moveInt):
		0: #Move To Random Position
			moveToRand = true
		1: #Move Back To Center
			moveToCenter = true
		2: #Move To Player Position
			moveToPlayer = true

func shootBullet():
	shoot(270, normBulletSpeed, flipInt, $NormShotPos, bulletPrefab)

func finishShoot():
	normShootCount -= 1
	
	if normShootCount <= 0:
		normShootCount = randi_range(2, 3)
		attackPhases.play("MongererBalls!")
	else:
		attackPhases.play("MongererShoot")

func shootBall(firstTime: bool):
	var curBall = theBall.instantiate()
	add_sibling(curBall)
	
	if (firstTime):
		curBall.global_position = ballShotPosA.global_position
		curBall.directionX = -1
		curBall.directionY = -1
	else:
		curBall.global_position = ballShotPosB.global_position
		curBall.directionX = -1
		curBall.directionY = 1
	
	curBall.speed = 800

func finishBallin():
	#origPos = global_position
	attackPhases.play("MongererShoot")

func letHimShake(canShake: bool):
	shakeIt = canShake
	
func linkBody():
	var distFromA = linkPosA.position + body.position - clawA.position
	var distFromB = linkPosA.position + body.position - clawB.position

	for i in range(len(linkObjs[0])):
		linkObjs[0][i].position = ((distFromA) * (float(i + 1) / (numOfLinks + 2))) + clawA.position
		
	for j in range(len(linkObjs[1])):
		linkObjs[1][j].position = ((distFromB) * (float(j + 1) / (numOfLinks + 2))) + clawB.position
		
func eyeShake():
	var eyeVectX = ((player.position.x - eyeOGPos.x) / 90.0) + 9 
	var eyeVectY = (player.position.y - eyeOGPos.y) / 20.0
	eye.position = Vector2(eyeVectX, eyeVectY)

func debrisToss():
	for i in range(len(debrisTileArr)):
		var debrisCol = Color(1, 1, 1, randf_range(0.1, 0.5))
		debrisTileArr[i].gravity_scale = randi_range(1, 3)
		debrisTileArr[i].linear_velocity.x = randi_range(-100, -500)
		debrisTileArr[i].linear_velocity.y = randi_range(-100, -500)
		debrisTileArr[i].modulate.a = randf_range(0.5, 0.8)
	
	#Cause screen to shake
	var camera = get_parent().get_node("CameraObj")
	if (camera != null):
		camera.canShake = true

func loseHealth(h: int):
	if(isActive) and (canTakeDamage):
		healthpoints -= h
		
		if healthpoints <= 0:
			enemyArea.monitoring = false
			enemyArea.monitorable = false
			canTakeDamage = false
			origPos = body.global_position
			attackPhases.play("MongererDeath")
			oneOverLinkNumFlt = 1.0 / float(numOfLinks + 1) 
			isDying = true

func death():
	eye.visible = false
	if part2Delete != null:
		get_node(part2Delete).queue_free()
	super()

func destroyLinks():
	if attackPhases.current_animation_position >= oneOverLinkNumFlt:
		var L0 = linkObjs[0][curLinkPairInt]
		var L1 = linkObjs[1][curLinkPairInt]
		tossEnemy(L0.global_position, L0)
		tossEnemy(L1.global_position, L1)
		L0.visible = false
		L1.visible = false
		oneOverLinkNumFlt += 1.0 / float(numOfLinks + 1)
		if curLinkPairInt < (numOfLinks - 1):
			curLinkPairInt += 1

func _on_enemy_area_area_entered(area):
	super(area) 

func _on_enemy_area_area_exited(area):
	super(area)

func _on_trigger_entered(area):
	attackPhases.play("MongererIntro")
	$TriggerArea.queue_free()
