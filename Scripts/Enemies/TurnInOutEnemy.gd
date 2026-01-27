extends Enemy

@export var targetXNorm = 240.0
@export var targetXSlow = 40.0
@export var speed = 50.0
@export var minSpeed = 10.0

var posA1
var posA2
var posB1
var posB2

var slowSpeedF = 1.0
var newSpeed
var targetPos
var switchDir = true
var goToB = true
var reachSlowPoint = false

func _ready():
	if scale.y > 0: 
		targetXNorm *= -1
		targetXSlow *= -1
	
	posA1 = position + Vector2(targetXSlow, 0)
	posA2 = position
	posB1 = position + Vector2(targetXNorm, 0)
	posB2 = position + Vector2(targetXNorm + targetXSlow, 0)
	
	targetPos = posB1
	newSpeed = speed

func _process(delta):
	pass
	
func _physics_process(delta): 
	super(delta)
	position.x = move_toward(position.x, targetPos.x, delta * newSpeed)
	
	if (!reachSlowPoint):
		newSpeed = speed
		if (position.x == targetPos.x):
			targetPos = (posA2) if (!goToB) else (posB2)
			reachSlowPoint = true
	else:
		newSpeed = lerp(minSpeed, speed, slowSpeedF)
		slowSpeedF -= delta * 3
		slowSpeedF = clamp(slowSpeedF, 0.0, 1.0)
		
		if (position.x == targetPos.x):
			scale.x *= -1
			slowSpeedF = 1.0
			goToB = !goToB
			targetPos = (posA1) if (!goToB) else (posB1)
			reachSlowPoint = false
			
	if (isDead):
		speed = 0
		enemyArea.monitorable = false
		enemyArea.monitoring = false
		

func _on_default_timer_timeout():
	pass

func _on_enemy_area_area_entered(area):
	super(area)
	
func _on_enemy_area_area_exited(area):
	super(area)
