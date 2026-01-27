extends Node2D

@onready var firstNode = $FirstNode
@onready var cp0 = $ControlPoint
@onready var tp0 = $TargetPoint
@onready var cp1 = $ControlPoint2
@onready var tp1 = $TargetPoint2

@export var moveSpeed = 1.5

var moveBack = false
var origin = 0
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	origin = firstNode.position
	cp0 = cp0.position
	tp0 = tp0.position
	cp1 = cp1.position
	tp1 = tp1.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var q0 = origin.lerp(cp0, time)
	var q1 = cp0.lerp(tp0, time)
	
	var q2 = tp0.lerp(cp1, time - 1)
	var q3 = cp1.lerp(tp1, time - 1)
	
	if time < 1:
		firstNode.position = q0.lerp(q1, time)
	else:
		firstNode.position = q1.lerp(q3, time - 1)
	
	time += delta * moveSpeed
	
	if time >= 2 and !moveBack:
		moveSpeed *= -1
		moveBack = true
	elif time <= 0 and moveBack:
		moveSpeed *= -1
		moveBack = false
