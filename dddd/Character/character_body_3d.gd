extends CharacterBody3D

var look_sensitivity: float = 0.005

@onready var camera: Camera3D = $Camera3D
@export var ray: RayCast3D
@export var rope: Node3D

var retract_vel = 100.0
var rope_len = 2.0
var stiffness = 5.0
var damping = 5.0

var MAX_SPEED = 15

var target: Vector3
var launched = false

const SPEED = 5.0
const JUMP_VELOCITY = 5.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func launch():
	if ray.is_colliding():
		target = ray.get_collision_point()
		launched = true

func retract():
	launched = false

func handle_grapple(delta: float, shrink: bool):
	if !launched:
		return
	
	var target_dir = position.direction_to(target)
	var target_dist = position.distance_to(target)
	
	if target_dist > 2 * rope_len:
		retract()
		return
	
	var displacement = target_dist - rope_len
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var mag = stiffness * displacement
		var spring_force = target_dir * mag
		
		var vel_dot = velocity.dot(target_dir)
		var dang = -damping * vel_dot * target_dir
		
		force = spring_force * dang
	
	if shrink:
		force += target_dir * retract_vel
	
	velocity += force * delta

func update_rope():
	if !launched:
		rope.visible = false
		return
	
	rope.visible = true
	
	var dist = global_position.distance_to(target)
	
	rope.look_at(target)
	rope.scale = Vector3(1, 1, dist / 2)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Global.w += Global.sensitivity
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Global.w -= Global.sensitivity
			
	Global.w = clamp(Global.w, 0, 1)
	
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * look_sensitivity)
		camera.rotate_x(-event.relative.y * look_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
	if Input.is_action_just_pressed("escape"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

		
	#Grappling Hook
	if Input.is_action_just_pressed("shoot"):
		launch()
	
	if Input.is_action_just_released("shoot"):
		retract()
	
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if Input.is_action_pressed("pull"):
		handle_grapple(delta, true)
	
	else:
		handle_grapple(delta, false)
	
	update_rope()

	if velocity.length() > MAX_SPEED:
		velocity *= MAX_SPEED / velocity.length()

	move_and_slide()
