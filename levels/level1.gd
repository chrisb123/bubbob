extends TileMap

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func waves():
	var level1wave1 = [1,201,3,201,1,201,1,1,998,101]
	var level1wave2 = [1,1,3,3,1,1,1,3,3,1]
	var level1wave3 = [3,3,1,1,2,1,1,3,3,1]
	return [0, level1wave1, level1wave2, level1wave3]
	