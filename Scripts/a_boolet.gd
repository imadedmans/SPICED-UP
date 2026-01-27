extends Sprite2D

@export var moveSpeed = 100.0
var moveVector = Vector2(0, 0)
var canDelete = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += moveVector * moveSpeed * delta

func _on_delete_timer_timeout():
	if canDelete:
		queue_free()
