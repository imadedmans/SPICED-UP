extends Sprite2D

@export var powVar = 0.5
@export var speed = 1
@export var targetPos: Vector2

var startingScale
var parentName: String
var canAttack = false
var lerpValue = 0
var initiateAttack = true

var curScale
var curModulate
var curPos

# Called when the node enters the scene tree for the first time.
func _ready(): 
	startingScale = global_scale
	parentName = get_parent().get_name()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_parent().get_name() != parentName && initiateAttack:
		canAttack = true
		initiateAttack = false
	
	if canAttack && lerpValue < 1:
		if curPos == null:
			curScale = global_scale
			curModulate = modulate
			curPos = global_position
			
		var smoothing = smoothstep(0, 1, lerpValue)
		global_position = lerp(curPos, targetPos, smoothing)
		global_scale = lerp(curScale, startingScale, smoothing)
		modulate = lerp(curModulate, Color(1, 1, 1), smoothing)
		
		lerpValue += delta * speed
		
