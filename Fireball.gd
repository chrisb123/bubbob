extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if linear_velocity.x > 0:
		$Fireballanim.flip_v = false
	else:
		$Fireballanim.flip_v = true

func _on_Area2D_body_entered( body ):
	#if body.is_in_group("player"):
	#	print("hit")
	if body.is_in_group("tiles"):
		print("tilemap hit")
		queue_free()
		
func _on_Area2D_area_entered( area ):
	if area.is_in_group("bubble_area"):
		area.get_parent()._on_Life_timeout()