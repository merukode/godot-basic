extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const WALL_JUMP_VELOCITY = Vector3(0, 4.5, -3) # Custom velocity for wall jump

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Camera control variables
var rotation_speed = 0.005
var rotation_x = 0.0
var rotation_y = 0.0

# Reference to the Camera node
@onready var camera = $neck/Camera3D

# Variables for wall jumping
var can_wall_jump = false
var wall_node = null

func _ready():
	# Capture the mouse and make it invisible
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Reference to the wall node in the scene
	wall_node = get_node("/root/YourScenePath/wall") # Update this path to your actual wall node

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# Rotate the camera based on mouse movement
		rotation_y -= event.relative.x * rotation_speed
		rotation_x -= event.relative.y * rotation_speed

		# Clamp the vertical rotation to prevent flipping
		rotation_x = clamp(rotation_x, -PI/2, PI/2)

		# Apply the rotation to the camera
		camera.rotation.x = rotation_x
		rotation.y = rotation_y

func _physics_process(delta):
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Detect wall contact
	can_wall_jump = is_on_specific_wall(wall_node)

	# Handle jump
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif can_wall_jump:
			# Apply wall jump
			velocity = WALL_JUMP_VELOCITY
			can_wall_jump = false # Reset the wall jump

	# Get the input direction and handle movement/deceleration
	var input_dir = Input.get_vector("left", "right", "up", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func is_on_specific_wall(wall) -> bool:
	# Check for collision specifically with the wall node
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision and collision.get_collider() == wall:
			return true
	return false
