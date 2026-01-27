extends TextureRect

@onready var anim = $TransitionAnim

@export var playingTransition = false
var isPaused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause") and (!playingTransition):
		print("Paused")

func pause():
	if (!GlobalVar.isPaused):
		#Engine.time_scale = 0
		GlobalVar.isPaused = true
		anim.play("TransitionLeft")
	elif (GlobalVar.isPaused):
		#Engine.time_scale = 1
		GlobalVar.isPaused = false
		anim.play("TransitionRight")
