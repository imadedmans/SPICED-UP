extends Node

var playerHealth: int = 0
var curLevel: NodePath
var checkpointInt: int = 0
var weapons: PackedStringArray
var powerups: PackedStringArray

var startLevelFirst: bool = true
var isPaused: bool = false
var timeScale: float = 1.0

var playerWithinCameraView: bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#print("Game saved")
	#print("player health: ", playerHealth)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("save"):
		saveState()
		
	if (isPaused):
		timeScale = 0.0
	else:
		timeScale = 1.0

func saveState():
	print("Saved")
	get_tree().reload_current_scene()

func loadState():
	print("Game saved")
	print("player health: ", playerHealth)
