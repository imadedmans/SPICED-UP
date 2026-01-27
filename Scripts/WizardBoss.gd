extends StaticBody2D

#Timers
@onready var moveTimer = $MoveTimer
@onready var shootATimer = $ShootATimer
@onready var shootBTimer = $ShootBTimer
@onready var circlingTimer = $CirclingTimer

@export_group("Phase 1 Variables")
@export var timeToPosition = 0.1
@export var speed = 500
@export var moveWaitTime = 0.6

@export_group("Phase 2 Variables")
@export var numberOfShotIntervals: int = 5
@export var shotsAPerInterval: int = 8
@export var shootAWaitTime = 0.02

@export_group("Phase 3 Variables")
@export var circleXRange = 20.0
@export var circleYRange = 10.0
@export var circlingSpeed = 20.0
@export var numOfBInterval: int = 6
@export var shotsBPerInterval: int = 8
@export var shootBWaitTime = 0.02
var canCircle = false
var circleMove: Vector2

@export_group("Positions")
@export var minRandPos: Vector2
@export var maxRandPos: Vector2
@export var arenaCenter: Vector2

@export_group("Bullet Prefabs")
@export var bulletPrefab: PackedScene

var currentPhase = 0
var curIntervNum
var curBIntervals
var curBShotNum = 0
var determinedSpeed = 0.0
var circlingTime = 0.0
var posToMoveTo: Vector2
var canMove = false

# Called when the node enters the scene tree for the first time.
func _ready():
	curIntervNum = numberOfShotIntervals
	curBShotNum = shotsBPerInterval
	curBIntervals = numOfBInterval
	moveTimer.wait_time = moveWaitTime
	shootATimer.wait_time = shootAWaitTime
	phaseSelector(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if canMove:
		position = position.move_toward(posToMoveTo, determinedSpeed * delta)
		circlingTime = 0
		if position == posToMoveTo:
			if !canCircle:
				phaseSelector(1)
				phaseSelector(2)
			if canCircle:
				phaseSelector(3)
			canMove = false
	if !canMove and canCircle:
		circleMove.x = (sin(circlingSpeed * circlingTime) * circleXRange) + arenaCenter.x
		circleMove.y = (cos(circlingSpeed * circlingTime) * circleYRange) + arenaCenter.y
		self.global_position = circleMove
		circlingTime += delta
	
func phaseSelector(phase: int):
	match phase:
		1:
			moveTimer.start()
		2:
			if curIntervNum == 0:
				curIntervNum = numberOfShotIntervals
			shootATimer.start()
		3:
			circlingTimer.start()
			canMove = false
			
	currentPhase = phase

func positionChooser(typeMove: int):
	match typeMove:
		1:
			posToMoveTo.x = randf_range(minRandPos.x, maxRandPos.x)
			posToMoveTo.y = randf_range(minRandPos.y, maxRandPos.y)
		2:
			posToMoveTo.x = (sin(circlingSpeed) * circleXRange) + arenaCenter.x
			posToMoveTo.y = (cos(circlingSpeed) * circleYRange) + arenaCenter.y
	determinedSpeed = sqrt(pow(posToMoveTo.x - position.x, 2) + pow(posToMoveTo.y - position.y, 2)) / timeToPosition

func _on_move_timer_timeout():
	canMove = true
	if !canCircle:
		positionChooser(1)
	else:
		positionChooser(2)
		

func _on_shoot_timer_timeout():
	for i in range(shotsAPerInterval):
		var bullet = bulletPrefab.instantiate()
		self.add_sibling(bullet)
		bullet.global_position = self.global_position
		var bulletAngle = ((360 / shotsAPerInterval) * i)
		#if ((curIntervNum + 1) % 2) == 0:
		#	bulletAngle += (360 / (shotsPerInterval * 2))
		bullet.angle = bulletAngle
	curIntervNum -= 1
		
	if curIntervNum <= 0:
		canCircle = true

func _on_circling_timer_timeout():
	if curBIntervals > 0:
		curBShotNum = shotsBPerInterval
		curBIntervals -= 1
		shootBTimer.start()

func _on_shoot_b_timer_timeout():
	var bullet = bulletPrefab.instantiate()
	self.add_sibling(bullet)
	bullet.global_position = self.global_position
	bullet.angle = 0
	curBShotNum -= 1
	
	if curBShotNum > 0:
		shootBTimer.start()
	else:
		circlingTimer.start()
