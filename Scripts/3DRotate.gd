extends Node3D

@export var rotateSpeed = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation.x += rotateSpeed * delta
	rotation.y += rotateSpeed * delta
	#rotation.z += rotateSpeed * delta
