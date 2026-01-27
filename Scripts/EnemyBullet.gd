extends Node2D

var bulletParent 
var moveVector: Vector2
@export var angle: float = 45
@export var speed: float = 200.0

var newAngle: float
var passNewAngle = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	newAngle = deg_to_rad(angle)
	translate(Vector2(sin(newAngle), cos(newAngle)) * speed * delta)

func goTowardsPosition(vec: Vector2):
	var distX = vec.x - self.global_position.x
	var distY = vec.y - self.global_position.y
	angle = atan2(distX, distY)
	angle = rad_to_deg(angle)

func _on_delete_timer_timeout():
	queue_free()
