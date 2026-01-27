extends Enemy

@export var speed = 200.0
@export var jumpForce = 200.0
@export var timeTillJump = 2.5
@export var avgDistance = 280.0

var curSpeed
var canJump = false
var isJumping = false
var beginJump = true

func _ready():
	super()
	curSpeed = speed
	defTimer.wait_time = timeTillJump

func _process(delta):
	pass
	
func _physics_process(delta):
	super(delta)
	
	if (isActive) :
		jump()
		if (beginJump):
			anim.play("JumperAnimation")
			beginJump = false
		
	move_and_slide()

func jump():
	var distFromPlayer = absf(position.x - player.position.x)
	velocity.x = curSpeed
	
	if is_on_floor():
		curSpeed = 0
		if canJump:
			curSpeed = speed if (player.position.x > position.x) else -speed
			if distFromPlayer < avgDistance:
				curSpeed = curSpeed * ((1 / avgDistance) * distFromPlayer)
				
			velocity.y -= jumpForce
			canJump = false
		elif isJumping:
			anim.play("JumperAnimation")
			isJumping = false
	else:
		isJumping = true

func canJumpMethod():
	canJump = true

func _on_enemy_area_area_entered(area):
	super(area)
	
func _on_enemy_area_area_exited(area):
	super(area)
