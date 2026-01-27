extends Sprite2D

#Place this into the sprite you want duplicated!
@export var canTrail = false
@export var timeToTrail := 0.05
var aMultiplier 

# Called when the node enters the scene tree for the first time.
func _ready():
	aMultiplier = 1 / timeToTrail

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (canTrail):
		timeToTrail -= delta
		modulate.a = aMultiplier * timeToTrail
		if (timeToTrail <= 0):
			queue_free()
