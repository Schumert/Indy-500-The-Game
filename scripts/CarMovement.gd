extends CharacterBody2D


var steer_angle = 3
var friction = -55
var temp_friction = friction
var acceleration = Vector2.ZERO
var game_world_ref
var drag = -0.06
var rpm = 0
var engine_power = 20000
var temp_engine_power = engine_power
var wheel_base = 70
var braking = -1000
var max_speed_reverse = 2000
var slip_speed = 500
var traction_fast = 3
var traction_slow = 7
@export var car_id : String


var is_pushing_state:=false
# var traction_handbrake = 0

# var handbraking_fast = -50
# var handbrake_speed = 100
# var handbrake:=false

var raycast


var steer_direction

# Called when the node enters the scene tree for the first time.
func _ready():
	game_world_ref = get_parent()
	raycast = $RayCast2D
	raycast.enabled = true
	# camera_instance = camera.instantiate()
	# add_sibling(camera_instance)

	Global.player = self
	Global.collected_coins[car_id] = 0
	Global.finished_laps[car_id] = 0
	Global.gui.update_players_info()
	if car_id == "car1":
		position = Global.start_pos
	elif car_id =="car2":
		position = Global.start_pos2
		rotation = Global.start_rot2

	
	if Global.active_map.contains("icy"):
		friction = -20
		temp_friction = friction
		traction_slow = 1
		traction_fast = 1



var collision_info = Vector2.ZERO
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	acceleration = Vector2.ZERO
	if car_id == "car1" and Global.current_state == Global.GameState.PLAYING:
		get_input()
	elif car_id == "car2" and Global.current_state == Global.GameState.PLAYING:
		get_input2()
	apply_friction(delta)
	steering(delta)
	velocity += acceleration * delta
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().is_in_group("wall") and raycast.is_colliding():
			is_pushing_state = true
			var direction_to_collision = collision.get_position() - position
			direction_to_collision = -direction_to_collision.normalized()
			collision_info = direction_to_collision

	if Input.is_action_just_pressed("main_menu"):
		#Global.change_state(Global.GameState.GAMEOVER)
		get_tree().change_scene_to_file("res://menu.tscn")
	
	
			
			
	_pushed_off(collision_info, delta)

	
	#print(velocity.length())
	#print(game_world_ref.friction)
	#print(steer_angle)
	#print(rpm)
var old_s_angle = steer_angle
func increase_steer_angle(value):
	steer_angle = old_s_angle + value
func to_old_s_angle():
	if steer_angle != old_s_angle:
		steer_angle = old_s_angle
func collect_coin():
	if car_id == "car1":
		Global.collected_coins["car1"] += 1
		Global.gui.update_players_info()
	elif car_id == "car2":
		Global.collected_coins["car2"] += 1
		Global.gui.update_players_info()

func finish_lap():
	if car_id == "car1":
		Global.finished_laps["car1"] += 1
		Global.gui.update_players_info()
	elif car_id == "car2":
		Global.finished_laps["car2"] += 1
		Global.gui.update_players_info()

func _pushed_off(opp, delta):
	if is_pushing_state:
			var push_strength = 3000
			velocity += opp * push_strength * delta
			rpm = 0
			await get_tree().create_timer(0.5).timeout
			is_pushing_state = false

		#is_pushing_state = false
		
func get_input():
	var turn = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")

	if is_pushing_state:
		turn = 0

	steer_direction = turn * deg_to_rad(steer_angle)
	
	acceleration = transform.x * rpm
	if Input.is_action_pressed("accelerate"):
		rpm = lerpf(rpm, engine_power, 0.005)
		to_old_s_angle()
	else:
		rpm = lerpf(rpm, 0, 0.05)


	if Input.is_action_pressed("brake"):
		rpm = lerpf(rpm, 0, 0.1)
		acceleration = transform.x * braking

		increase_steer_angle(2)

func get_input2():
	var turn = Input.get_action_strength("steer_right2") - Input.get_action_strength("steer_left2")

	if is_pushing_state:
		turn = 0

	steer_direction = turn * deg_to_rad(steer_angle)
	
	acceleration = transform.x * rpm
	if Input.is_action_pressed("accelerate2"):
		rpm = lerpf(rpm, engine_power, 0.005)
		to_old_s_angle()
	else:
		rpm = lerpf(rpm, 0, 0.05)


	if Input.is_action_pressed("brake2"):
		rpm = lerpf(rpm, 0, 0.1)
		acceleration = transform.x * braking

		increase_steer_angle(2)


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
	if  acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += friction_force + drag_force

	


	
	
