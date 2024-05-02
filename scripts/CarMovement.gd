extends CharacterBody2D

var car_heading
var steer_angle = 15
var acceleration = Vector2.ZERO
var friction = -0.9
var drag = -0.001
var engine_power = 1000
var wheel_base = 70
var braking = -450
var max_speed_reverse = 250
var slip_speed = 400
var traction_fast = 0.01
var traction_slow = 0.7

var steer_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction()
	steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	


func get_input():
	var turn = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
		
	steer_direction = turn * deg_to_rad(steer_angle)
	
	if Input.is_action_pressed("accelerate"):
		acceleration = transform.x * engine_power
	if Input.is_action_pressed("brake"):
		acceleration = transform.x * braking

func steering(delta):
	
	var front_wheel = position + transform.x * wheel_base / 2
	var back_wheel = position - transform.x * wheel_base / 2

	back_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta

	print("buu")
	print( (Vector2(2,5) - Vector2(1,1)).normalized())
	print("bi de bu")
	print(atan2(front_wheel.y - back_wheel.y, front_wheel.x - back_wheel.x))
	
	car_heading = (front_wheel - back_wheel).normalized()
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	var d = car_heading.dot(velocity.normalized())
	if d > 0:	
		velocity = velocity.lerp(car_heading * velocity.length(), traction)
	if d < 0:
		velocity = -car_heading * min(velocity.length(), max_speed_reverse)

	rotation = car_heading.angle()

func apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	
	var friction_force = velocity * friction
	var drag_force = velocity * velocity.length() * drag
	acceleration += friction_force + drag_force

