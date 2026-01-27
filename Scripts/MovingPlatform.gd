extends Node2D

@onready var platform = $Path2D/Platform
@export var numOfPlatforms: int = 1
@export var speed = 10.0

#var platformArray: Array[AnimatableBody2D]
var pathFollowArray: Array[PathFollow2D]
@onready var path = $Path2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pathFollowArray.append(platform)
	for i in range(1, numOfPlatforms):
		var newPlatform = platform.duplicate()
		path.add_child(newPlatform)
		newPlatform.progress_ratio = (1 / float(numOfPlatforms)) * float(i)
		print(newPlatform.progress_ratio)
		pathFollowArray.append(newPlatform)
		#print(newPlatform.get_parent().name)
	#if len(targetPos) > 0:
	#	position = targetPos[0]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(len(pathFollowArray)):
		pathFollowArray[i].progress += speed * delta

func oldVer(subDelta):
	var targetPos: Array[Vector2] = []
	var speed = 10.0
	var origPos
	var currentPosInt: int = 0
	#Underneath is the process code
	position = position.move_toward(origPos + targetPos[currentPosInt], speed * subDelta)
	if position == origPos + targetPos[currentPosInt]:
		if (len(targetPos) - 1) <= currentPosInt:
			currentPosInt = 0
		else:
			currentPosInt += 1
