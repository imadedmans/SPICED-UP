extends Node2D

@export var music: AudioStreamMP3
@export var doIntro: bool = true

@onready var musicPlayer = $MusicPlayer
@onready var player = $Player
@onready var levelCanvas = $LevelCanvas
@onready var camera =  $CameraObj
@onready var introCover = $IntroCover
@onready var introAnim = $IntroCover/AnimationPlayer

@onready var pauseMenu = $LevelCanvas/PauseMenu

var checkpoints = []

# Called when the node enters the scene tree for the first time.
func _ready():
	checkpoints = get_tree().get_nodes_in_group("Checkpoint")
	
	if (!GlobalVar.startLevelFirst):
		doIntro = false
	
	if (doIntro) and (GlobalVar.checkpointInt == 0):
		player.disableAbilities(false, false, false, false)
		player.visible = false
		levelCanvas.enableHUD(false) 
		GlobalVar.startLevelFirst = false
		
		introCover.visible = true 
		introCover.position = camera.position
		introAnim.play("LevelIntro")
	elif (GlobalVar.checkpointInt > 0):
		print("Checkpoint: " + str(GlobalVar.checkpointInt))
		player.position = checkpoints[GlobalVar.checkpointInt - 1].position
		introCover.visible = false
		levelCanvas.transitRight()
		musicPlayer.stream = music
		musicPlayer.play()
	else:
		introCover.visible = false
		levelCanvas.transitRight()
		musicPlayer.stream = music
		musicPlayer.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	introCover.position = camera.position


func introOver():
	player.disableAbilities(true, true, true, true)
	player.visible = true
	levelCanvas.enableHUD(true) 
	introCover.visible = false 
	
	#doIntro = false
	musicPlayer.stream = music
	musicPlayer.play()

func playerDeath(playerHasFallen: bool):
	levelCanvas.enableHUD(false) 
	if (playerHasFallen == false):
		introAnim.play("PlayerDeath")
	else:
		introAnim.play("PlayerQuickDeath")

func endLevel():
	player.disableAbilities(false, false, false, false)
	introAnim.play("LevelEnd")

func levelRestart():
	get_tree().reload_current_scene()

func nextScene():
	get_tree().change_scene_to_file("res://Scenes/DemoEndScene.tscn")

func _on_camera_obj_area_exited(area):
	if area.collision_layer == 2:
		GlobalVar.playerWithinCameraView = false
