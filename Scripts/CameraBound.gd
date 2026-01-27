#@tool
extends Area2D

@export var screenText: String = "nothing"
@export_range(1, 20) var xSize: int = 1
@export_range(1, 20) var ySize: int = 1
@export var reduceMusicVolume: bool = false

@onready var shape = $CollisionShape2D

var musicPlayer
var camera
var player
var labelText

var areaMinX
var areaMaxX
var areaMinY
var areaMaxY

var viewSize
var viewSizeHalf
var areaTouched = true

# Called when the node enters the scene tree for the first time.
func _ready():
	#shape.get_shape().size = get_viewport_rect().size * Vector2(xSize, ySize)
	#viewSize = get_viewport_rect().size
	viewSizeHalf = get_viewport_rect().size / 2
	
	camera = get_parent().get_node(get_parent().camera)
	labelText = get_parent().get_node(get_parent().labelText)
	player = get_parent().get_node(get_parent().player)
	musicPlayer = get_parent().get_node(get_parent().musicPlayer)
	
	#(shape.get_shape().size.x)
	
	areaMinX = position.x - viewSizeHalf.x
	areaMaxX = position.x + (shape.get_shape().size.x / 2)# - viewSizeHalf.x
	areaMinY = position.y - viewSizeHalf.y
	areaMaxY = position.y + (shape.get_shape().size.y / 2)# - viewSizeHalf.y
	
	areaMaxX += viewSizeHalf.x * (xSize - 1)
	areaMaxY += viewSizeHalf.y * (ySize - 1)
	
	#print(name, " Min: ", areaMinX, ", ", areaMinY)
	#print(name, " Max: ", areaMaxX, ", ", areaMaxY)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var plPosX = clamp(player.position.x, areaMinX, areaMaxX)
	var plPosY = clamp(player.position.y, areaMinY, areaMaxY)
	var boundsVector = Vector2(plPosX, plPosY)
	
	var camPosX = clamp(player.position.x, areaMinX + viewSizeHalf.x, areaMaxX - viewSizeHalf.x)
	var camPosY = clamp(player.position.y, areaMinY + viewSizeHalf.y, areaMaxY - viewSizeHalf.y)
	
	if (player.position == boundsVector):	
		if (xSize > 1):
			camera.position.x = camPosX
		else:
			camera.position.x = position.x
			
		if (ySize > 1):
			camera.position.y = camPosY
		else:
			camera.position.y = position.y
			
		labelText.text = "[p align=center]" + screenText.to_upper()
		if (reduceMusicVolume):
			musicPlayer.volume_db = -6.0

#func _on_body_entered(body):
#	areaTouched = true
	#withinArea = true

#func _on_body_exited(body):
#	areaTouched = false
	
#func areaEnter(areaTouched: bool):
