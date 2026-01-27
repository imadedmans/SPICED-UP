extends RichTextLabel

@export var isNotIntroScene = false
@onready var animPlayer
@onready var typeTimer = $TypeTimer
@onready var typeAudio = $AudioStreamPlayer

var curChrInt = 0
var newLine = ""
var currentLine = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	#text = "[center]"
	animPlayer = get_parent().get_node("CutscenePlayer")
	if (!isNotIntroScene):
		animPlayer.play("IntroCutscene")
	else:
		animPlayer.play("DemoEndCutscene")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = currentLine
	if Input.is_action_just_pressed("pause") and (!isNotIntroScene):
		print(animPlayer.current_animation_length - 1.0)
		animPlayer.seek(animPlayer.current_animation_length - 1.0)

func addDialogue(dialogueLine: String):
	animPlayer.pause()
	newLine = dialogueLine
	typeAudio.stream_paused = false
	typeTimer.start()

func skipLine():
	currentLine += "\n" + "\n"

func _on_type_timer_timeout():
	if curChrInt == 0:
		currentLine += "[p][center]" + newLine[curChrInt]
		curChrInt += 1
	
	if curChrInt < len(newLine):
		currentLine += newLine[curChrInt]
		curChrInt += 1
		typeTimer.start()
	else:
		text += "[p][center]"
		curChrInt = 0
		animPlayer.play()
		typeAudio.stream_paused = true

func loadNextScene():
	get_tree().change_scene_to_file("res://Scenes/LevelA1-1.tscn")
