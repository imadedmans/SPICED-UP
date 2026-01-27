extends Node2D

@export var speed: float = 30.0

@onready var pendulum = $Pendulum
@onready var centre = $Centre

var pendulumParts = []
var realSpeed
var speedVarTime = 0.0
var ogPos
var moveTime = 0.0
var amplitude 
var directionInt = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	ogPos = pendulum.position
	amplitude = abs(pendulum.position.y - centre.position.y)
	
	var m = 5
	
	for i in range(1, m):
		var newPart = centre.duplicate()
		add_child(newPart)
		newPart.position.y = (float(i) * (amplitude / 4)) + centre.position.y
		pendulumParts.append(newPart)
	
	pendulumParts.append(pendulum)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	realSpeed = speed * cos(speed * speedVarTime)
	speedVarTime += delta
	moveTime += delta * realSpeed
	
	for n in range(len(pendulumParts)):
		var j: float = float(n)
		var moveX = ((j / len(pendulumParts) * (amplitude)) * sin(moveTime)) + centre.position.x
		var moveY = ((j / len(pendulumParts) * (amplitude)) * cos(moveTime)) + centre.position.y
		pendulumParts[j].position = Vector2(moveX, moveY)
	
	
