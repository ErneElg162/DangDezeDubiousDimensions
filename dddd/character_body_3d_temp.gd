extends CharacterBody3D

var look_sensitivity: float = 0.005

@onready var camera: Camera3D = $Camera3D
@onready var ray_cast_3d: RayCast3D = $Camera3D/RayCast3D
@onready var gun: CharacterBody3D = $Gun
 
@onready var tesseract = $Camera3D/tesseract

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var activeGrap = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Global.w += Global.sensitivity
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Global.w -= Global.sensitivity
 
	Global.w = clamp(Global.w, 0, 1)
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * look_sensitivity)
		tesseract.rotate_y(-event.relative.x * look_sensitivity)
		
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
		tesseract.rotate_x(-event.relative.y * look_sensitivity)
		tesseract.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("left_mouse_click") and ray_cast_3d.is_colliding() and not activeGrap:
		activeGrap = true
		gun.shoot(ray_cast_3d.get_collision_point())
	elif Input.is_action_just_pressed("left_mouse_click") and activeGrap:
		activeGrap = false
		gun.remove_line()

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	print(velocity)

	move_and_slide()
