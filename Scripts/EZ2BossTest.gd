extends Node2D

@onready var replaceNode = $ReplacementNode
@onready var attackTimer = $AttackTimer

@export_group("Movement Variables")
@export var circleXRange = 200.0
@export var circleYRange = 100.0

@export_group("Colour Variables")
@export var colourSpeed: float = 2.0
@export var modulateLimit: float = 0.5

@export_group("Size Variables")
@export var sizeLimit = 0.9

var childIntDel
var removedChild
var nerdChild = []
var childOgSizes = []
var canReturn = false

var childPosFloat = 0.0
var positionX = 0.0
var positionY = 0.0
var curSizeValue = 1
var curColorValue = 1
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	for j in range(get_child_count()):
		if get_child(j) is Sprite2D:
			nerdChild.append(get_child(j))
			childOgSizes.append(nerdChild[j].global_scale)
	
	modulateLimit = (modulateLimit + 1) / 2
	sizeLimit = (sizeLimit + 1) / 2
	childPosFloat = (2 * PI) / len(nerdChild)
	
	attackTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotateChildren()
	time += delta * colourSpeed

func rotateChildren():
	for i in range(len(nerdChild)):
		#Position Change
		positionX = sin(time + (childPosFloat * i)) * circleXRange
		positionY = cos(time + (childPosFloat * i)) * circleYRange
		nerdChild[i].global_position = global_position + Vector2(positionX, positionY)	
		nerdChild[i].z_index = -1 if (positionY < 0) else 1
		#Size Change
		curSizeValue = ((1 - sizeLimit) * cos(time + (childPosFloat * i))) + sizeLimit
		nerdChild[i].global_scale = childOgSizes[i] * curSizeValue
		#Colour Change
		curColorValue = ((1 - modulateLimit) * cos(time + (childPosFloat * i))) + modulateLimit
		nerdChild[i].modulate = Color(curColorValue, curColorValue, curColorValue)

func _on_attack_timer_timeout():
	if !canReturn:
		childIntDel = randi() % len(nerdChild)
		removedChild = nerdChild[childIntDel]
		removedChild.reparent(get_tree().root, true)
		nerdChild[childIntDel] = replaceNode
		#canReturn = true
	#else:
		#nerdChild[childIntDel] = removedChild
		#canReturn = false
	
	attackTimer.start()
	
