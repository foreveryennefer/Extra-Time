extends KinematicBody

var speed = 800
var direction = Vector3()
#var gravity = -9.81
var velocity = Vector3()
var camera_angle = 0
var mouse_sensitivity = 0.3

#walk variables
var gravity = -9.8 *3
const MAX_SPEED = 20
const MAX_RUNNING_SPEED = 30
const ACCEL = 2
const DEACCEL = 6

#jumping
var jump_height = 15

#fly variables
const FLY_SPEED = 40
const FLY_ACCEL = 4

#z is y, y is x, x is z

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass

func _input(event):
	#Move the camera based on the basis components of the mouse movement
	if event is InputEventMouseMotion:
		#Set horizontal rotation
		$Head.rotate_z(deg2rad(event.relative.x * mouse_sensitivity))
		
		#Set vertical rotation
		var change = -event.relative.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_y(deg2rad(change))
			camera_angle += change

func _physics_process(delta):
	walk(delta)

func walk(delta):
	#Reset the direction of the player
	direction = Vector3(0, 0, 0)
	
	#Get the rotation of the camera
	var aim = $Head/Camera.get_global_transform().basis
	
	#Check input and change direction
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	direction = direction.normalized()
	
	velocity.y += gravity * delta
	
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	var speed
	if Input.is_action_pressed("sprint"):
		speed = MAX_RUNNING_SPEED
	else:
		speed = MAX_SPEED
	
	# Where would the player go at max speed
	var target = direction * speed
	
	var acceleration
	if direction.dot(temp_velocity) > 0:
		acceleration = ACCEL
	else:
		acceleration = DEACCEL
	
	#Calculate the portion of the distance to go
	temp_velocity = temp_velocity.linear_interpolate(target, acceleration * delta)
	
	velocity.x = temp_velocity.x
	velocity.z = temp_velocity.z
	
	#Calling and returning the movement
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
	if Input.is_action_just_pressed("jump"):
		velocity.y = jump_height
	
	var hitCount = get_slide_count()
	if hitCount > 0:
		var collision = get_slide_collision(0)
		if collision.collider is RigidBody:
			collision.collider.apply_impulse(collision.position, -collision.normal)


func fly(delta):
	#Reset the direction of the player
	direction = Vector3(0, 0, 0)
	
	#Get the rotation of the camera
	var aim = $Head/Camera.get_global_transform().basis
	
	#Check input and change direction
	if Input.is_action_pressed("move_forward"):
		direction -= aim.z
	if Input.is_action_pressed("move_backward"):
		direction += aim.z
	if Input.is_action_pressed("move_left"):
		direction -= aim.x
	if Input.is_action_pressed("move_right"):
		direction += aim.x
	direction = direction.normalized()
	
	# Where would the player go at max speed
	var target = direction * FLY_SPEED
	
	#Calculate the portion of the distance to go
	velocity = velocity.linear_interpolate(target, FLY_ACCEL * delta)
	
#	if velocity.y > 0:
#		gravity = -20
#	else:
#		gravity = -30
	
	move_and_slide(velocity)
	
#	velocity.y += gravity * delta
#	velocity.x = direction.x
#	velocity.z = direction.z
	
#	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
#
#	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
#		velocity.y = 10
		
	var hitCount = get_slide_count()
	if hitCount > 0:
		var collision = get_slide_collision(0)
		if collision.collider is RigidBody:
			collision.collider.apply_impulse(collision.position, -collision.normal)


