extends Sprite2D

@export_range(1, 20) var numOfShots = 5
@export var numOfBursts = 3
@export var angleSpread = 22.5

var curNumOfBursts
var angleDif

@onready var boolet = $ABoolet
@onready var waitTimer = $WaitTimer
@onready var timeBetShots = $TimeBetweenShots
@onready var bulletLabel = $BulletLabel
@onready var angleLabel = $AngleLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	curNumOfBursts = numOfBursts

func _process(delta):
	angleDif = angleSpread / float(numOfShots - 1) if numOfShots > 1 else 1
	bulletLabel.text = "Num of Bullets: " + str(numOfShots) 
	angleLabel.text = "Angle Spread: " + str(angleSpread) 
	
	if Input.is_action_just_pressed("left") and numOfShots > 1:
		numOfShots -= 1
		
	if Input.is_action_just_pressed("right") and numOfShots < 20:
		numOfShots += 1
	
	if Input.is_action_just_pressed("up") and angleSpread < 360.0:
		angleSpread += 22.5
	
	if Input.is_action_just_pressed("down") and angleSpread > 0.0:
		angleSpread -= 22.5

func FIREINTHEHOLE():
	var targetNormal = (get_global_mouse_position() - position).normalized()
	var minAngle = (float(numOfShots) / 2.0) - 0.5
	var tAng = targetNormal.angle() - deg_to_rad(minAngle * angleDif)
	
	for i in range(numOfShots):
		var bolAngle = tAng + (i * deg_to_rad(angleDif))
		var curBol = boolet.duplicate()
		curBol.global_position = position
		curBol.moveVector = Vector2(cos(bolAngle), sin(bolAngle))
		curBol.canDelete = true
		add_sibling(curBol)

func _on_wait_timer_timeout():
	FIREINTHEHOLE()
