extends CharacterBody2D


var steer_angle = 15
var steer_angle_fast = 12
var steer_angle_very_fast = 8
var acceleration = Vector2.ZERO
var friction = -55
var drag = -0.06
var engine_power = 0
var wheel_base = 70
var braking = -450
var max_speed_reverse = 750
var slip_speed = 1500 #type of: vel. length
var traction_fast = 3
var traction_slow = 8

var is_pushing_state:=false

# var traction_handbrake = 0

# var handbraking_fast = -50
# var handbrake_speed = 100
# var handbrake:=false

var raycast


var steer_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	raycast = $RayCast2D
	raycast.enabled = true


var collision_info = Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("player") and raycast.is_colliding():
			is_pushing_state = true
			collision_info = collision.get_normal()
			var direction_to_collision = collision.get_position() - position
			direction_to_collision = -direction_to_collision.normalized()
			collision_info = direction_to_collision
			
			
	_pushed_off(collision_info, delta)



	
	#print(velocity.length())
	print(friction)
	#print(steer_angle)
	
	
var temp_friction = friction
func _pushed_off(opp, delta):
	if is_pushing_state:
			friction = temp_friction
			var push_strength = 250000
			velocity += opp * push_strength * delta
			engine_power = 0
			friction = 1000
			await get_tree().create_timer(0.5).timeout
			is_pushing_state = false
			friction = lerpf(friction, temp_friction, 0.1)

		#is_pushing_state = false
		
func get_input():
	var turn = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")

	if not is_pushing_state:
		steer_direction = turn * deg_to_rad(steer_angle)
	
	acceleration = transform.x * engine_power
	if Input.is_action_pressed("accelerate"):
		engine_power = lerpf(engine_power, 7500, 0.005)
		
	else:
		engine_power = lerpf(engine_power, 0, 0.01)

	
	
	if Input.is_action_pressed("brake"):
		engine_power = lerpf(engine_power, 0, 0.1)
		acceleration = transform.x * braking

var old_steer_angle = steer_angle
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
	var car_heading = back_wheel.direction_to(front_wheel)

	var steer_angle_speed_bound = 1500 # type of: vel. length
	var traction = traction_slow
	if velocity.length() > steer_angle_speed_bound + 500:
		steer_angle = steer_angle_very_fast
		traction = traction_fast - 2
	elif velocity.length() > steer_angle_speed_bound:
		steer_angle = steer_angle_fast
		traction = traction_fast
	else:
		steer_angle = old_steer_angle

	
		

	
	var d = car_heading.dot(velocity.normalized())
	if d > 0:	
		velocity = lerp(velocity, car_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -car_heading * min(velocity.length(), max_speed_reverse)

	rotation = car_heading.angle()

func apply_friction(delta):
	if  acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += friction_force + drag_force
