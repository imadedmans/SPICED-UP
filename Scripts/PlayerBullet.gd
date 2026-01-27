extends Node2D

@onready var destroyTimer = $DestroyTimer

@export var speed = 5.0
#enum direction {UP, DOWN, LEFT, RIGHT}
var curDirection = "up"

var moveVector = Vector2(1, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	destroyTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#match (curDirection):
	#	"up":
	#		moveVector = Vector2(0, -1)
	#	"down":
	#		moveVector = Vector2(0, 1)
	#	"left":
	#		moveVector = Vector2(-1, 0)
	#	"right":
	#		moveVector = Vector2(1, 0)
	
	global_position += (moveVector * speed * delta)
	if moveVector.y != 0:
		rotation = deg_to_rad(270.0)

func _on_destroy_timer_timeout():
	queue_free()
	
func _on_area_entered(area):
	if (area.collision_layer == 4):
		var enemyScript = area.get_node(area.parentPath)
		if enemyScript.canTakeDamage == true:
			enemyScript.loseHealth(1)
			queue_free()
