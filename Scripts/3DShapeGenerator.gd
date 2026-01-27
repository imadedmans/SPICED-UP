extends Node2D

@export var numOfVertexes: int = 1
@export var shapeSize = 200.0
@export var speed := 2.0

var vertexPrefab
var vertexObj = []
var xRange = 0.0
var xMove = 0.0
var yMove = 0.0
var idkLol = 0.0
var nameGoesHere := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	vertexPrefab = get_parent().get_node("VertexPrefab")
	
	for a in range(numOfVertexes):
		vertexObj.append(vertexPrefab.duplicate())
		add_child(vertexObj[a])
		vertexObj[a].position = self.position
		vertexObj[a].name += str(a + 1)
	
	idkLol = (2 * PI) / speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	xMove += delta * Input.get_axis("left", "right")
	yMove += delta * Input.get_axis("up", "down")
	shapeSetter(0)
		
func shapeSetter(shapeNum: int):
	for i in range(len(vertexObj)):
		nameGoesHere = (float(i) / numOfVertexes) * idkLol
		var sineMovementX = sin(speed * (xMove + nameGoesHere))
		var sineMovementY = cos(speed * (yMove + nameGoesHere))
		
		#var cosMovementX = cos(xSpeed * (time + nameGoesHere))
		#if cosMovementX < 0:
		#	vertexObj[i].z_index = -1
		#	vertexObj[i].modulate = Color.html("777777")
		#else:
		#	vertexObj[i].z_index = 0
		#	vertexObj[i].modulate = Color.html("ffffff")
		
		vertexObj[i + shapeNum].position = shapeSize * Vector2(sineMovementX, sineMovementY)
