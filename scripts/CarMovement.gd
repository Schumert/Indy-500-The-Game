extends CharacterBody2D

var car_heading
var steer_angle = 7
var steer_angle_slow = 3
var steer_angle_speed_bound = 2000 # type of: vel. length
var acceleration = Vector2.ZERO
var friction = -5
var drag = -0.06
var engine_power = 2000 #max vel. length = 3400
var wheel_base = 70
var braking = -450
var max_speed_reverse = 250
var slip_speed = 1000 #type of: vel. length
var traction_fast = 5
var traction_slow = 10
var traction_handbrake = 0

var handbraking_fast = -50
var handbrake_speed = 600
var handbrake:=false

var traction = traction_slow
var is_sliding:= false


var steer_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input(delta)
	apply_friction(delta)
	steering(delta)
	velocity += acceleration * delta
	move_and_slide()

	#print(velocity.length())
	#print(engine_power)
	print(steer_angle)
	

var old_engine_power = engine_power
var old_steer_angle = steer_angle
func get_input(delta):
	var turn = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")

	steer_direction = turn * deg_to_rad(steer_angle)
	if Input.is_action_pressed("accelerate"):
		engine_power = lerpf(engine_power, 12000, 0.001)
		acceleration = transform.x * engine_power
	else:
		engine_power = lerpf(engine_power, old_engine_power, 0.005)

	#only brake
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking

	
	#handbrake but car's sliding rather than slowing, it is slowing but very little.
	#Handbrake speed is necessary because without it, car's behaving weird after pressing long enough the handbrake button. 
	if Input.is_action_pressed("handbrake") and velocity.length() > handbrake_speed:
		handbrake = true
		is_sliding = true

		velocity = lerp(velocity, Vector2.ZERO, 0.02)#Makes you stop faster than normal break if you handbrake without acceleration.
		#engine_power = lerpf(engine_power, 0, 0.005) #Prevents longer slidings

	elif Input.is_action_pressed("handbrake"):
		handbrake = true
		is_sliding = false
		#velocity = Vector2.ZERO
		velocity = lerp(velocity, Vector2.ZERO, 0.2) #And eventually, car stops.

	
	
	if Input.is_action_just_released("handbrake") and velocity.length() > 1000:
		#await get_tree().create_timer(0.5).timeout
		is_sliding = false
		handbrake = false
	elif Input.is_action_just_released("handbrake"):
		is_sliding = false
		handbrake = false


func drifting():
	if is_sliding:
		pass


func steering(delta):
	
	var front_wheel = position + transform.x * wheel_base / 2
	var back_wheel = position - transform.x * wheel_base / 2

	back_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta

	#print("buu")
	#print( (Vector2(2,5) - Vector2(1,1)).normalized())
	#print("bi de bu")
	#print(atan2(front_wheel.y - back_wheel.y, front_wheel.x - back_wheel.x))
	
	#car_heading = (front_wheel - back_wheel).normalized()
	car_heading = back_wheel.direction_to(front_wheel)

	
	
	steer_angle = 7
	if velocity.length() > steer_angle_speed_bound and not handbrake:
		steer_angle = steer_angle_slow

	#Lerping here make sure us that the transition between traction_slow and traction_handbrake is smooth.
	traction = lerpf(traction, traction_slow, 0.1)
	if velocity.length() > slip_speed and not is_sliding:
		#traction = traction_fast
		traction = lerpf(traction, traction_fast, 0.1)

	if handbrake:
		steer_angle = lerpf(steer_angle, 12, 0.05)
		traction = traction_handbrake
	

	var d = car_heading.dot(velocity.normalized())
	if d > 0:	
		velocity = lerp(velocity, car_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -car_heading * min(velocity.length(), max_speed_reverse)

	rotation = car_heading.angle()

func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += friction_force + drag_force
