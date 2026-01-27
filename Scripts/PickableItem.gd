extends Sprite2D

@onready var area = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_entered(area):
	var playerObj = area.get_parent()
	if playerObj.curHealth < playerObj.healthpoints:
		playerObj.curHealth += 1
		visible = false
		area.monitoring = false
	teleportPlayer()
	queue_free()
	
func teleportPlayer():
	pass
