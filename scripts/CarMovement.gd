extends CharacterBody2D

var car_heading
var steer_angle = 15
var acceleration = Vector2.ZERO
var friction = -0.55
var drag = -0.001
var engine_power = 2000
var wheel_base = 70
var braking = -50
var max_speed_reverse = 450
var slip_speed = 400
var traction_fast = 0.1
var traction_slow = 0.7
var traction_handbrake = 0.005

var handbraking_slow = -500
var handbraking_fast = -50
var handbrake_speed = 400
var handbrake:=false


var steer_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	steering(delta)
	velocity += acceleration * delta
	move_and_slide()

	#print(steer_angle)
	


func get_input():
	var turn = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")

	steer_direction = turn * deg_to_rad(steer_angle)
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	#only brake
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking
	#backwards motion
	if Input.is_action_pressed("brake") and car_heading.dot(velocity.normalized()) < 0:
		acceleration = transform.x * -400
		#print("geri gidiyoruz")
	#handbrake but car's sliding rather than slowing, it is slowing but very little.
	if Input.is_action_pressed("handbrake") and velocity.length() > handbrake_speed:
		handbrake = true
		acceleration = transform.x * handbraking_fast
	#Stops very fast
	elif Input.is_action_pressed("handbrake"):
		handbrake = true
		#print("duruluyor")
		if velocity >= Vector2.ZERO:
			acceleration = transform.x * handbraking_slow
		else:
			acceleration = transform.x * -handbraking_slow
			
	else:
		handbrake = false

func steering(delta):
	
	var front_wheel = position + transform.x * wheel_base / 2
	var back_wheel = position - transform.x * wheel_base / 2

	back_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta

	#print("buu")
	#print( (Vector2(2,5) - Vector2(1,1)).normalized())
	#print("bi de bu")
	#print(atan2(front_wheel.y - back_wheel.y, front_wheel.x - back_wheel.x))
	
	car_heading = (front_wheel - back_wheel).normalized()

	var traction = traction_slow
	steer_angle = 15

	if velocity.length() > slip_speed:
		traction = traction_fast
		steer_angle = 7
	if handbrake and velocity.length() > handbrake_speed:
		steer_angle = 20
		traction = traction_handbrake

	print(traction)

	var d = car_heading.dot(velocity.normalized())
	if d > 0:	
		velocity = velocity.lerp(car_heading * velocity.length(), traction)
	if d < 0:
		velocity = -car_heading * min(velocity.length(), max_speed_reverse)

	rotation = car_heading.angle()

func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag
	acceleration += friction_force + drag_force
