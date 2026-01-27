extends Area2D

@onready var childCam = $Camera2D

@export_group("Camera Shake")
@export var canShake = false
@export var force = 10
@export var timeToShake: float = 2.0

@export_group("Camera Zoom")
@export var canZoom = false
@export var zoomMax = 1.05
@export var timeToZoom = 0.5

var orgPos: Vector2
var curForce
var curTime

var curZoomTime
var zoomValue
var zoomLerper = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	orgPos = childCam.position
	curForce = force
	curTime = timeToShake
	
	curZoomTime = timeToZoom
	zoomValue = zoomMax

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if (canShake) && (curTime > 0):
		childCam.position.x = randf_range(-curForce, curForce) + orgPos.x
		childCam.position.y = randf_range(-curForce, curForce) + orgPos.y
		curForce = (curTime * force) / timeToShake #1.5 value temp there
		curTime -= delta
	else:
		childCam.position = orgPos
		canShake = false
		curForce = force
		curTime = timeToShake
	
	if (canZoom) && (curZoomTime > 0):
		zoomValue = lerp(1.0, zoomMax, pow(curZoomTime / timeToZoom, 2))
		childCam.zoom = Vector2(zoomValue, zoomValue)
		curZoomTime -= delta
	else:
		canZoom = false
		curZoomTime = timeToZoom
		zoomValue = zoomMax
		
	
