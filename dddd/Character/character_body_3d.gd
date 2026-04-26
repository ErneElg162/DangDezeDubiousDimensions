extends CharacterBody3D

var look_sensitivity: float = 0.005

@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
var coyote_time = 0.15
var can_jump = true
var buffer = false
var buffer_time = 0.1

@onready var camera: Camera3D = $Camera3D
@onready var ray: RayCast3D = $Camera3D/RayCast3D
@onready var rope: Node3D = $Camera3D/GrapplingGun/Rope
@onready var gun: Node3D = $Camera3D/GrapplingGun

@export var ALLOW_GRAPPLE: bool = true

var retract_vel = 60.0
var rope_len = 1.0
var K = 5

var MAX_SPEED = 30
var max_grap = 210

var target: Vector3
var launched = false

const SPEED = 15.0
const JUMP_VELOCITY = 10.0

@onready var tesseract = $Camera3D/tesseract

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if not ALLOW_GRAPPLE:
		ray.visible = false
		gun.visible = false
	
	else:
		ray.visible = true
		gun.visible = true

func launch():
	if ray.is_colliding():
		target = ray.get_collision_point()
		launched = true

func retract():
	launched = false

func handle_grapple(delta: float, shrink: bool, move_vec: Vector3):	
	var target_dir = position.direction_to(target)
	var target_dist = position.distance_to(target)
	
	var force = K * (target_dist - rope_len)
	
	if shrink:
		velocity += target_dir * retract_vel * delta
	
	if abs(force) > max_grap:
		force = max_grap
	
	velocity += target_dir * force * delta
	
	if move_vec != Vector3.ZERO:
		velocity += move_vec.project(target_dir.cross(target_dir.cross(move_vec)))

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
	# Add the gravity.
	if not is_on_floor():
		if not buffer and Input.is_action_just_pressed("ui_accept"):
			buffer = true
			jump_buffer_timer.start(buffer_time)
		
		if can_jump:
			if coyote_timer.is_stopped():
				coyote_timer.start(coyote_time)
			
		if velocity.y < 0:
			velocity += 2 * get_gravity() * delta
		
		else:
			velocity += 1.5 * get_gravity() * delta
	
	else:
		can_jump = true
		coyote_timer.stop()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or can_jump):
		velocity.y = JUMP_VELOCITY
	
	elif can_jump and buffer:
		velocity.y = JUMP_VELOCITY
		buffer = false
		jump_buffer_timer.stop()
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.

		
	#Grappling Hook
	if Input.is_action_just_pressed("shoot"):
		launch()
	
	if Input.is_action_just_released("shoot"):
		retract()
	
	var move_vec = Vector3.ZERO
	
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
	if direction:
		move_vec.x = direction.x * SPEED
		move_vec.z = direction.z * SPEED
	else:
		move_vec.x = velocity.x
		move_vec.z = velocity.z
		
		move_vec.x = move_toward(move_vec.x, 0, SPEED)
		move_vec.z = move_toward(move_vec.z, 0, SPEED)
	
	if launched and ALLOW_GRAPPLE:
		if Input.is_action_pressed("pull"):
			handle_grapple(delta, true, move_vec)
		
		else:
			handle_grapple(delta, false, move_vec)
	
	else:
		velocity.x = move_vec.x
		velocity.z = move_vec.z

	if velocity.length() > MAX_SPEED:
		velocity *= MAX_SPEED / velocity.length()

	update_rope()
	move_and_slide()

func _on_coyote_timer_timeout():
	can_jump = false


func _on_jump_buffer_timer_timeout() -> void:
	buffer = false
