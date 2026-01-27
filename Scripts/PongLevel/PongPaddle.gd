extends Sprite2D

@export var speed: float = 400
var pongBall
var isOnRight: bool = false
var moveRandomly: bool = false
var randNewY

# Called when the node enters the scene tree for the first time.
func _ready():
	if name == "PaddleR":
		isOnRight = true
		
	pongBall = get_parent().find_child("PongBall")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if ((pongBall.position.x > 0) and (isOnRight)) or ((pongBall.position.x < 0) and (!isOnRight)):
		position.y = move_toward(position.y, pongBall.position.y, speed * delta)
		moveRandomly = false
	else:
		if !moveRandomly:
			randNewY = randf_range(-300, 300)
			moveRandomly = true
		position.y = move_toward(position.y, randNewY, speed * delta)
