extends Sprite2D

@export var moveSpeed = 1000.0
@export var targetPos = Vector2(0, 0)
@export var height = 100

var midPoint = Vector2(0, 0)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var framesPerSec = ProjectSettings.get_setting("physics/common/physics_ticks_per_second")
var xSpeed = 0.0
var ySpeed = 0.0

var canMove = false

# Called when the node enters the scene tree for the first time.
func _ready():
	gravity = -gravity
	midPoint = Vector2(((global_position.x + targetPos.x) / 2) + global_position.x, targetPos.y + height) 
	determineSpeed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if canMove:
		global_position += Vector2(xSpeed, ySpeed) * delta
		ySpeed -= gravity * delta

func determineSpeed():
	var angle = asin(sqrt(-2 * gravity * height) / moveSpeed)
	print(rad_to_deg(angle))
	xSpeed = moveSpeed * cos(angle) 
	ySpeed = -moveSpeed * sin(angle)

func _on_timer_timeout():
	canMove = true
