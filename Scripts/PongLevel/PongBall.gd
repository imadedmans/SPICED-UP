extends CharacterBody2D

@export var speed: float = 200
@export var startRand = true
@export var limitTime = true
@export var directionX: int = 0
@export var directionY: int = 0
var sprite
var dir: Vector2

# Called when the node enters th e scene tree for the first time.
func _ready():
	sprite = get_node("Sprite2D")
	dir = move_ball(0, 0)
	if limitTime:
		$ExistenceTime.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if (!startRand):
		dir = move_ball(directionX, directionY)
	
	var collision = move_and_collide(dir * speed * delta)
	if collision:
		var collider = collision.get_collider()
		dir = dir.bounce(collision.get_normal())
		startRand = true
		#print(collider.get_parent().name)

func move_ball(dx: int, dy: int):
	var newDir: Vector2
	if (startRand):
		newDir.x = [-1, 1].pick_random()
		newDir.y = [-1, 1].pick_random()
	else:
		newDir.x = dx
		newDir.y = dy
	return newDir.normalized()

func _on_body_entered(body):
	print("Oh jesus christ...")

func _on_effect_timer_timeout():
	var newSprite = sprite.duplicate()
	
	newSprite.z_index = (z_index - 1)
	newSprite.position = position
	newSprite.canTrail = true
	
	get_parent().add_sibling(newSprite)

func _on_existence_time_timeout():
	queue_free()
