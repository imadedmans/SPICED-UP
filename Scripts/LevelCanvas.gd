extends CanvasLayer

@onready var levelName = $LevelName
@onready var playerHealth = $PlayerHealth
@onready var nateBanter = $NATEBanter
@onready var transitBar = $TransitionBar
@onready var dashCooldown = $DashCooldown

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	offset = get_viewport().size * 0.5
	var crt = get_parent().get_node("/root/CRTLayer")
	crt.visible = false
	get_node("CRTEffect").visible = true
	levelName.visible = false
	
	player = get_parent().get_node("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	playerHealth.text = "PLAYER HEALTH: " + str(player.curHealth)
	if (dashCooldown != null):
		dashCooldownBar()

func dashCooldownBar():
	if (!player.isDashing):
		dashCooldown.fill_mode = 1
		dashCooldown.min_value = 0
		dashCooldown.max_value = player.dashCooldownTime
		dashCooldown.value = player.curDashClDwnTime
	else:
		dashCooldown.fill_mode = 0
		dashCooldown.max_value = player.dashTime
		dashCooldown.value = player.dashTime - player.dashTimer.time_left
		#print(player.dashTimer.time_left)
		

func enableHUD(isEnable: bool):
	nateBanter.visible = isEnable
	playerHealth.visible = isEnable
	#nateBanter.visible = isEnable

func transitRight():
	transitBar.get_child(0).play("TransitionRight")
