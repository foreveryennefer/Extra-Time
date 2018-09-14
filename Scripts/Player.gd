extends KinematicBody

var speed = 800
var direction = Vector3()
var gravity = -9.81
var velocity = Vector3()
var camera_angle = 0
var mouse_sensitivity = 0.3

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
	direction = Vector3(0, 0, 0)
	
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_up"):
		direction.z -= 1
	if Input.is_action_pressed("ui_down"):
		direction.z += 1
	direction = direction.normalized() * speed * delta
	
	if velocity.y > 0:
		gravity = -20
	else:
		gravity = -30
	
	velocity.y += gravity * delta
	velocity.x = direction.x
	velocity.z = direction.z
	
	velocity = move_and_slide(velocity, Vector3(0, 1, 0))
	
	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
		velocity.y = 10
		
	var hitCount = get_slide_count()
	if hitCount > 0:
		var collision = get_slide_collision(0)
		if collision.collider is RigidBody:
			collision.collider.apply_impulse(collision.position, -collision.normal)
