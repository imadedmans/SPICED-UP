extends Node2D

@export var initialRadius = 60.0
@export var rotateSpeed = 10.0
@export var decreaseRadiusMultiplier = 2.0
var curRadius
var canRotate = false
var t = 0.0
var n = 3

signal orbitComplete

# Called when the node enters the scene tree for the first time.
func _ready():
	curRadius = initialRadius
	var n = self.get_child_count() - 1
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for i in range(1, n + 1):
		var orbitVector = Vector2(0, 0)
		orbitVector.x = curRadius * sin(t + ((i * 2 * PI) / n))
		orbitVector.y = curRadius * cos(t + ((i * 2 * PI) / n))
		if self.get_child(i).name != "AnimTimer":
			self.get_child(i).position = orbitVector

	if canRotate and curRadius > 0:
		curRadius -= delta * decreaseRadiusMultiplier
		t += delta * rotateSpeed
	if curRadius <= 0:
		orbitComplete.emit()
		queue_free()

func _on_anim_timer_timeout():
	for i in range(1, n + 1):
		if self.get_child(i).frame == 11:
			self.get_child(i).frame = 0
		else:
			self.get_child(i).frame += 1

func obtainOrbits(count: int):
	if (self.get_child_count() - 1) < count:
		var newOrb = self.get_child(1).duplicate()
		add_child(newOrb)
		n += 1
