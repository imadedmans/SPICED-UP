extends RigidBody2D

@onready var sprite = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func launch():
	gravity_scale = randi_range(1, 3)
	linear_velocity = Vector2(randi_range(-500, 500), randi_range(-500, 500))
	modulate.a = randf_range(0.5, 0.8)
