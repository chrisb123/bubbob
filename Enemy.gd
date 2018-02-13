extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var _in_bubble = false
var vel = Vector2()
const MIN_SPEED = 150
const MAX_SPEED = 350
const Y_SPEED_REDUCTION = 0.5 #divisor factor for Y axis speeds
export (PackedScene) var Explode
export (PackedScene) var Fireball
var _is_minion = false
var facing #1 right, 2 left
const NUM_FIREBALLS = 8
export (int) var enemy_type 
var score_for_killing 

#add variables and node from other enemies
#add enemy_type variable
#initialise scene depending on enemy_type
# - Need to add in different speeds and other changes to make enemies different
func _ready():
	if enemy_type == 1:
		$Enemy.region_rect = Rect2(0,0,80,100)
		score_for_killing = Global_Vars.score_enemy1
	if enemy_type == 2:
		$Enemy.region_rect = Rect2(73,0,70,100)
		score_for_killing = Global_Vars.score_enemy2
		$Fireball_Timer.wait_time = 3
		$Fireball_Timer.start()
	if enemy_type == 3:
		$Enemy.region_rect = Rect2(143,0,70,100)
		score_for_killing = Global_Vars.score_enemy3
		$Fireball_Timer.wait_time = 2
		$Fireball_Timer.start()
		
	if get_parent().is_in_group("enemyboss"):
		_is_minion = true

#func _process(delta):

#no need to process physics every frame for rigid bodies
#func _physics_process(delta):
#	rotation_degrees = 0
#	if _in_bubble == false:
#		linear_velocity.x = vel.x
#		linear_velocity.y = vel.y
#	else:
#		gravity_scale = -0.5
#		bounce = 0.35
#		if linear_velocity.x > 50:
#			linear_velocity.x = linear_velocity.x * 0.97
#		if linear_velocity.y > 50:
#			linear_velocity.y = linear_velocity.y * 0.97


func killbub(pk):
	if _in_bubble && pk:
		#Stop enemy
		$AnimatedSprite.play()
		$Death_Sound.play()
		$Particles.emitting = true
		$Enemy.hide()
		$Bubble.hide()
		$Move_Timer.stop()
		$CollisionShape2D.disabled = true
		linear_damp = 10
		linear_velocity = Vector2(0,0)
#And explode it
func _on_AnimatedSprite_animation_finished():
	if _is_minion == false:
		Global_Vars.score += score_for_killing
		Global_Vars.enemyn -= 1
	else:
		get_parent().minion_count -= 1
	queue_free()


func _on_RigidBody2D_body_entered( body ):
	if body.is_in_group("bubble") && ! _in_bubble:
		body.queue_free()
		$Bubble.show()
		_in_bubble = true
		$Bubble_Timer.start()
		if enemy_type != 1:
			$Fireball_Timer.stop()
		#Shrink monster into bubble (Animated)
		$Enemy/Shrink.interpolate_property($Enemy, 'scale', $Enemy.get_scale(),
		Vector2(0.33,0.33), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
		#$Enemy/Shrink.set_speed_scale(5)
		$Enemy/Shrink.start() 
		gravity_scale = -0.5
		bounce = 0.35
		linear_velocity.x = vel.x / 5
		linear_velocity.y = vel.y / 5
		#$Enemy.scale = Vector2(0.33,0.33)


func _on_Move_Timer_timeout():
#Randomize Enemy direction and speed every timeout
	randomize()
	var temp = randi()%2
	if temp == 1:
		vel.x = randi()%MAX_SPEED
		vel.x = clamp(vel.x, MIN_SPEED,MAX_SPEED)
		facing = 1
		$Enemy.flip_h = false
	else:
		vel.x = -1 * randi()%MAX_SPEED
		vel.x = clamp(vel.x, -MAX_SPEED,-MIN_SPEED)
		facing = -1
		$Enemy.flip_h = true
	var temp2 = randi()%2
	if temp2 == 1:
		vel.y = randi()%MAX_SPEED
		vel.y = clamp(vel.y, MIN_SPEED/Y_SPEED_REDUCTION,MAX_SPEED/Y_SPEED_REDUCTION)
	else:
		vel.y = -1 * randi()%MAX_SPEED
		vel.y = clamp(vel.y, -MAX_SPEED/Y_SPEED_REDUCTION,-MIN_SPEED/Y_SPEED_REDUCTION)
	#print(temp," ",temp2)
	if _in_bubble == false:
		#linear_velocity.x = vel.x
		#linear_velocity.y = vel.y
		$Enemy/Move.interpolate_property(self, 'linear_velocity', linear_velocity, Vector2(vel.x,vel.y), 0.25, Tween.TRANS_QUAD, Tween.EASE_OUT)
		$Enemy/Move.start()
	

func _on_Bubble_Timer_timeout():
	#Remove Bubble and expand Enemy to original size
	$Enemy/Pop.interpolate_property($Enemy, 'scale', $Enemy.get_scale(),
	Vector2(0.8,0.8), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Enemy/Pop.interpolate_property($Bubble, 'scale', $Enemy.get_scale(),
	Vector2(2.0,2.0), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Enemy/Pop.start() 
	gravity_scale = 0
	bounce = 0
	


func _on_Pop_tween_completed( object, key ):
	$Pop_Bubble.play()
	$Enemy/Shrink.interpolate_property($Enemy, 'scale', $Enemy.get_scale(),
	Vector2(0.75,0.75), 0.5, Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Enemy/Shrink.start() 
	$Bubble.hide() 
	$Bubble.scale = Vector2(1.0,1.0)
	$Bubble_Timer.stop()
	_in_bubble = false
	if enemy_type != 1:
		$Fireball_Timer.start()

#add fireball function from other enemies execute based on type
func _on_Fireball_Timer_timeout():
	if enemy_type == 2:
		var pos = $Enemy.position
		var rot = 0
		var lin = 150
		var i = 1
		pos.x += 0 #* facing
		pos.y -= 0
		while i <= NUM_FIREBALLS:
			var fireball = Fireball.instance()
			rot = (360 / NUM_FIREBALLS) * i
			fireball.rotation_degrees = rot
			lin += 0
			fireball.apply_impulse(Vector2(0,0), Vector2(lin * 1,0).rotated(deg2rad(rot)))
			fireball.position = pos
			add_child(fireball)
			i += 1
	if enemy_type == 3:
		var fireball = Fireball.instance()
		var pos = $Enemy.position
		pos.x += 50 * facing
		pos.y -= 0
		fireball.linear_velocity = Vector2(300 * facing,0)
		if fireball.linear_velocity.x > 0:
			fireball.rotation_degrees += 0 
		else:
			fireball.rotation_degrees += 180
		fireball.position = pos
		add_child(fireball)