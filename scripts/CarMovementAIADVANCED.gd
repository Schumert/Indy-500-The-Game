extends CharacterBody2D

@export var target_position: Vector2
@export var navigation_agent: NavigationAgent2D

var steer_angle = 3
var friction = -55
var temp_friction = friction
var acceleration = Vector2.ZERO
var drag = -0.06
var power = 1000
var wheel_base = 70
var braking = -1000
var max_speed_reverse = 2000
var slip_speed = 500
var traction_fast = 3
var traction_slow = 7
@export var car_id : String

var min_pitch = 0.8
var max_pitch = 1.4
var min_volume = -20
var max_volume = 0
@export var engine_sound: AudioStreamPlayer2D

var steer_direction

func _ready():
	Global.player_ai = self
	position = Vector2(229, 197)

	navigation_agent.target_position = target_position
	engine_sound.play()

var collision_info = Vector2.ZERO

func _physics_process(delta):
	if Global.current_state == Global.GameState.PLAYING:
		acceleration = Vector2.ZERO
		get_ai_input(delta)

		apply_friction(delta)
		steering(delta)
		velocity += acceleration * delta
		move_and_slide()

		if target_position == null or target_position == Vector2.ZERO:
			target_position = get_parent().get_closest_coin_direction(position)
			navigation_agent.target_position = target_position

func get_ai_input(delta):
	if not navigation_agent.is_navigation_finished():
		var path_direction = navigation_agent.get_next_path_position() - global_position
		path_direction = path_direction.normalized()

		var target_angle = path_direction.angle()
		var current_angle = rotation
		var result = angle_difference(target_angle, current_angle)

		if result > 0:
			steer_direction = deg_to_rad(steer_angle)
		elif result < 0:
			steer_direction = -deg_to_rad(steer_angle)
		else:
			steer_direction = 0

		acceleration = transform.x * power
		
func angle_difference(target_angle, current_angle):
	return wrapf(target_angle - current_angle, -PI, PI)

func steering(delta):
	var front_wheel = position + transform.x * wheel_base / 2
	var back_wheel = position - transform.x * wheel_base / 2

	back_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta

	var car_heading = back_wheel.direction_to(front_wheel)

	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
	elif velocity.length() > slip_speed * 2:
		traction = traction_fast - 2

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

func collect_coin():
	Global.collected_coins["car2"] += 1
	Global.gui.update_players_info()

	AudioManager.play_coin()


