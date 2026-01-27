extends Area2D

var bulletParent 
var moveVector: Vector2
@export var amplitude: float = 10.0
@export var period: float = 10.0
@export var speed: float = 200.0

var ogPos
var newAngle: float

# Called when the node enters the scene tree for the first time.
func _ready():
	ogPos = position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position.x += speed * delta
	if bulletParent != null:
		position.x *= bulletParent.flipInt
		
	position.y = (amplitude * sin((position.x * PI) / period)) + ogPos
	#translate(Vector2(xValue, yValue))

func _on_area_entered(area):
	if area.collision_layer == 2:
		var playerScript = area.owner
		
		if (playerScript.canTakeDamage) and (!playerScript.isDashing):
			playerScript.playerHealthLose(1)
	
	queue_free()
