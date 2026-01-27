extends Enemy

@onready var waitTimer = $WaitTimer

@export var speed = 5.0
@export var timeToShake = 0.4
@export var waitTime = 0.4
@export var maxDistance = 96.0

var canDetectPlayer = true
var canShake = false
var canSpikeMove = false
var spikeReturn = false

var ogPos
var newPos

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	
	ogPos = position
	newPos = position
	newPos.y += maxDistance
	
	defTimer.wait_time = timeToShake
	waitTimer.wait_time = waitTime

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)

func _physics_process(delta):
	super(delta)
	if (canShake):
		sprite.position.x = randf_range(-5.0, 5.0)
		sprite.position.y = randf_range(-5.0, 5.0)
		
	if (canSpikeMove):
		sprite.position = Vector2.ZERO
		position = position.move_toward(newPos, speed * delta)
		if position == newPos:
			waitTimer.start()
			canSpikeMove = false
	
	if (spikeReturn):
		position = position.move_toward(ogPos, speed * 0.5 * delta)
		if position == ogPos:
			canDetectPlayer = true
			spikeReturn = false
		

func _on_enemy_area_area_entered(area):
	super(area)

func _on_enemy_area_area_exited(area):
	super(area)

func _on_player_detect(area):
	if (canDetectPlayer):
		canShake = true
		defTimer.start()
		canDetectPlayer = false

func _on_default_timer_timeout():
	canShake = false
	canSpikeMove = true

func _on_wait_timer_timeout():
	spikeReturn = true
