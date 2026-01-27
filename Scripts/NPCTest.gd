extends RigidBody2D

@onready var indicator = $Indicator
@onready var label = $DialogueLabel
@onready var chrTimer = $TypeWaitTimer

@export var dialogueLines := [] as Array[String]
@export var textSpeed = 0.05
@export var rangeLen = 20.0

var npcRange
var player
var withinRange = true

var numOfLines = 0
var currentLine = ""
var curLineInt = -1
var curChrInt = 0
var hasTalked = false
var canTalk = true
var defaultString = "Well Goof, i'm sorry to say, but my eternal soul is attached to this server... Farewell"

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_node("Player")
	label.text = ""
	chrTimer.wait_time = textSpeed
	
	if len(dialogueLines) > 0:
		numOfLines = len(dialogueLines)
	else:
		numOfLines = 1
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	npcRange = Vector2(clamp(player.position.x, position.x - rangeLen, position.x + rangeLen), clamp(player.position.y, position.y - rangeLen, position.y + rangeLen))
	if player.position == npcRange:
		withinRange = true
		indicator.visible = true
	else:
		withinRange = false
		indicator.visible = false
	
	if (Input.is_action_just_pressed("up") and !hasTalked and withinRange):
		curLineInt = -1
		talk_setup()
		
	if Input.is_action_just_pressed("shoot") and hasTalked and canTalk:
		talk_setup()

func talk_setup():
	label.text = ""
	hasTalked = true
	canTalk = false
	curLineInt += 1
	
	if curLineInt < numOfLines:
		if len(dialogueLines) > 0:
			currentLine = dialogueLines[curLineInt]
		else:
			currentLine = defaultString
			
		curChrInt = 0
		player.disableAbilities(false, false, false, false)
		talk()
	else:
		hasTalked = false
		player.disableAbilities(true, true, true, true)

func talk():
	if curChrInt < len(currentLine):
		label.text += currentLine[curChrInt]
		#add text talk sfx here
		chrTimer.start()
	elif curChrInt == len(currentLine):
		canTalk = true

func _on_type_wait_timer_timeout():
	curChrInt += 1
	talk()
