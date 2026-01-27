extends Node2D

var normalMusic = preload("res://Music/EverHigher.mp3")
var winMusic = preload("res://Music/TennaDanceMusic.mp3")
var loseMusic = preload("res://Music/YouAreDead.mp3")

@export var startingPlayerHealth = 20

var canSkip = false
var playerHealth
var gameBegan = false

@onready var cardObj = $CardObject
@onready var cardPos = $CardPositions
var cardDeck = []
var spaces = [0, 0, 0, 0]
var curCardInt = -1
var weaponCard = null
var hasWeaponed = false
var endPoints = 0 

var lastHealthPotionInt
var cardsInRoom = 0
var attackWithFist = true
var maxAttackDamage = 0

var numOfCardsLeft = 48
var canFillSpaces = true

# Called when the node enters the scene tree for the first time.
func _ready():
	playerHealth = startingPlayerHealth
	addCards(0, 13)
	addCards(1, 13)
	addCards(2, 11)
	addCards(3, 11)
	cardDeck.shuffle()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HealthLabel.text = "Player Health: " + str(playerHealth) + "/20" 
	$CardNumLabel.text = "Cards Left: " + str(numOfCardsLeft) + "/46" 
	if weaponCard != null:
		$WeaponDamage.visible = true
		$WeaponDamage.text = "Max Weapon Damage: " + str(maxAttackDamage) + "/13"
	#" + startingPlayerHealth
	
	if playerHealth <= 0:
		$GameOver.visible = true
		if $MusicPlayer.stream != loseMusic:
			$MusicPlayer.stream = loseMusic
			$MusicPlayer.play()
	else:
		actionInputs()

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func actionInputs():
	if numOfCardsLeft <= 0:
		if spaces == [0, 0, 0, 0]:
			gameWin()
	
	if Input.is_action_just_pressed("begin") and cardsInRoom <= 1:
		if canSkip == true:
			fillSpaces()
		
		$BeginGame.visible = false
		if $MusicPlayer.stream == null:
			$MusicPlayer.stop()
			$MusicPlayer.stream = normalMusic
			$MusicPlayer.play()
			canSkip = true #Turn on canSkip for beginning
		
		
		fillSpaces()
		canFillSpaces = false
	
	if Input.is_action_just_pressed("down") and curCardInt != -1:
		if typeof(spaces[curCardInt]) != TYPE_INT:
			attackWithFist = true
			cardInteract(spaces[curCardInt].frame_coords)
	
	if Input.is_action_just_pressed("up") and curCardInt != -1:
		if (typeof(spaces[curCardInt]) != TYPE_INT) and weaponCard != null:
			attackWithFist = false
			cardInteract(spaces[curCardInt].frame_coords)
	
	
	if Input.is_action_just_pressed("card1") and typeof(spaces[0]) != TYPE_INT:
		selectCard(0)
	
	if Input.is_action_just_pressed("card2") and typeof(spaces[1]) != TYPE_INT:
		selectCard(1)
	
	if Input.is_action_just_pressed("card3") and typeof(spaces[2]) != TYPE_INT:
		selectCard(2)
	
	if Input.is_action_just_pressed("card4") and typeof(spaces[3]) != TYPE_INT:
		selectCard(3)

func addCards(typeInt: int, numOfCards: int):
	for i in range(numOfCards):
		cardDeck.append(Vector2i(i, typeInt))
		

func fillSpaces():
	for i in range(len(spaces)):
		if (numOfCardsLeft > 0 and typeof(spaces[i]) == TYPE_INT) or (canSkip):
			var newCardObj = cardObj.duplicate()
			add_child(newCardObj)
			newCardObj.position = cardPos.get_child(i).global_position
			spaces[i] = newCardObj
			newCardObj.frame_coords = cardDeck[numOfCardsLeft - 1]
			cardDeck.pop_back()
			cardsInRoom += 1
			numOfCardsLeft -= 1
	
	canFillSpaces = true
	gameBegan = true

func selectCard(n: int):
	if typeof(spaces[curCardInt]) != TYPE_INT:
		spaces[curCardInt].position.y = 0
	curCardInt = n
	if typeof(spaces[curCardInt]) != TYPE_INT:
		spaces[curCardInt].position.y = -100

func cardInteract(crd):
	$FistReminder.visible = false
	match(crd.y):
		0, 1:
			lastHealthPotionInt = 0
			attackCard(crd.x + 1)
		2:
			if crd.x == 10:
				exchangeWeapon()
			else:
				healthCard(crd.x + 1)
		3:
			lastHealthPotionInt = 0
			if crd.x == 10:
				exchangeWeapon()
			else:
				equipWeapon()

func attackCard(enemyHealth: int):
	if !attackWithFist:
		if (enemyHealth > maxAttackDamage) and hasWeaponed:
			$FistReminder.visible = true
		else:
			attackWithWeapon(enemyHealth)
			deleteCard()
	else:
		playerHealth -= enemyHealth
		deleteCard()

func attackWithWeapon(enemyHealth: int):
	var damagePool = enemyHealth - (weaponCard.frame_coords.x + 1)
	damagePool = maxi(0, damagePool)
	playerHealth -= damagePool
	maxAttackDamage = enemyHealth
	hasWeaponed = true

func healthCard(healthAmt: int):
	lastHealthPotionInt = healthAmt
	if playerHealth < startingPlayerHealth:
		playerHealth += healthAmt
		playerHealth = mini(playerHealth, 20)
	deleteCard()

func equipWeapon():
	hasWeaponed = false
	
	#Remove pre-existing card if there is
	if weaponCard != null:
		var crdToDel = weaponCard
		weaponCard = null
		crdToDel.queue_free()
	
	weaponCard = spaces[curCardInt]
	weaponCard.position = $WeaponCardPos.position
	maxAttackDamage = weaponCard.frame_coords.x + 1
	spaces[curCardInt] = 0
	cardsInRoom -= 1

func deleteCard():
	var crdToDel = spaces[curCardInt]
	crdToDel.queue_free()
	spaces[curCardInt] = 0
	cardsInRoom -= 1

func exchangeWeapon():
	if weaponCard != null:
		if hasWeaponed and (maxAttackDamage < weaponCard.frame_coords.x + 1):
			playerHealth += maxAttackDamage
			playerHealth = mini(playerHealth, 20)
		else:
			playerHealth += weaponCard.frame_coords.x + 1
			playerHealth = mini(playerHealth, 20)
		
		var crdToDel = weaponCard
		weaponCard = null
		crdToDel.queue_free()
	
	deleteCard()

func gameWin():
	$YouWin.visible = true
	if playerHealth == startingPlayerHealth:
		$EndPoints.text = "Points Gained: " + str(playerHealth + lastHealthPotionInt)
	else:
		$EndPoints.text = "Points Gained: " + str(playerHealth)
	$EndPoints.visible = true
	if $MusicPlayer.stream != winMusic:
		$MusicPlayer.stream = winMusic
		$MusicPlayer.play()
