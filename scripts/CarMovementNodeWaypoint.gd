extends CharacterBody2D

var min_distance = 500  # hedefe bu kadar yaklaşınca dur veya hız kes
var wheel_base = 70
var friction = -55
var steer_angle = 4
var steer_direction
var traction = 3
var max_speed_reverse = 200
var power = Vector2.ZERO
var drag = -0.06
var target_transform = null
var target_speed = 500


var gas = 0.0
var engine_power = 20000.0
var brake = -1
@export var turn_number = 0

enum AIMode { FOLLOWPLAYER, FOLLOWCHECKPOINTS, FOLLOWMOUSEPOSITION}
var current_mode = AIMode.FOLLOWCHECKPOINTS

var current_waypoint: Object
var all_waypoints = []




@export var nav: NavigationAgent2D
var current_direction: Vector2 = Vector2.ZERO

var cursor

var rng = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.player_ai = self
	position = Global.start_pos2

	Global.collected_coins["car2"] = 0
	Global.finished_laps["car2"] = 0
	Global.player_checkpoints["car2"] = []
	Global.gui.update_players_info()

	steer_direction = deg_to_rad(steer_angle)

	all_waypoints = get_tree().get_nodes_in_group("Waypoints")

	cursor = preload("res://Levels/cursor.tscn")


	






# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Global.current_state == Global.GameState.PLAYING:
		# if not nav.target_position: _set_new_target()
		
		
		
		
		# velocity = velocity.lerp(global_position.direction_to(next_position) * speed, 0.1)
		# rotation = velocity.angle()
		# move_and_slide()

		
				
		
		turn_number = turn_toward_target()




		apply_friction(delta)
		steering(delta)
		steer_direction = turn_number * deg_to_rad(steer_angle)
		
		velocity += power * delta
		power = transform.x * gas

		match current_mode:
			AIMode.FOLLOWPLAYER:
				follow_player()
				engine_power = 15000
				if (nav.target_position - position).length() < 500:
					if velocity.length() >= get_tree().get_first_node_in_group("Player").velocity.length():
						apply_brake()
				else:
					apply_throttle()
			AIMode.FOLLOWCHECKPOINTS:
				follow_waypoints()
				if (nav.target_position - position).length() < min_distance:
					check_angle_before_turning(400, 2000)
					
					if velocity.length() >= target_speed and not velocity.length() <= 300 :
						apply_brake()	
				else:
					apply_throttle()
					is_angle_calcd=false
			AIMode.FOLLOWMOUSEPOSITION:
				follow_mouse_position()
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				engine_power = 10000
				if (nav.target_position - position).length() < 500:
						apply_brake()
				else:
					apply_throttle()




		move_and_slide()
		#print("arabanin hizi: " + str(velocity.length()))
		#print(str(brake))
		#print((nav.target_position - position).length())
		#print(gas)

var cursor_instance
func follow_mouse_position():
	if cursor_instance == null:
		cursor_instance = cursor.instantiate()
		get_parent().add_child(cursor_instance)
	
	nav.target_position = get_global_mouse_position()
	cursor_instance.global_position = get_global_mouse_position()
	

func follow_player():
	if target_transform == null:
		target_transform = get_tree().get_first_node_in_group("Player")
		
	
	if target_transform != null:
		nav.target_position = target_transform.position



var distance_to_waypoint
func follow_waypoints():
	if current_waypoint == null:
		current_waypoint = get_tree().get_first_node_in_group("Waypoints")
	
	
	if current_waypoint != null:
		nav.target_position = current_waypoint.global_position
		
		distance_to_waypoint = (nav.target_position - global_position).length()
		if distance_to_waypoint <= current_waypoint.min_distance_to_reach_waypoint:
			current_waypoint = get_next_waypoint_node(current_waypoint)

var crash_possibility = 0.05
#gets next waypoint with bad choice probabilities
func get_next_waypoint_node(current_waypoint):
	var chosen_paths = []
	var chosen_path = null
	var is_crash = true if randf() <= crash_possibility else false

	if is_crash:
		
		for waypoint in current_waypoint.next_waypoint_node:
			if get_node(get_waypoint_node(waypoint)).is_crash:
				chosen_paths.append(waypoint)
				print("AI yanlış yola girdi!!!! Girdiği yol: " + str(get_node(get_waypoint_node(waypoint)).name))
		
		
	if chosen_paths.is_empty():
			for waypoint in current_waypoint.next_waypoint_node:
				if not get_node(get_waypoint_node(waypoint)).is_crash:
					chosen_paths.append(waypoint)

	chosen_path = chosen_paths[rng.randf_range(0, chosen_paths.size())]


	var node_path = get_waypoint_node(chosen_path)
	get_node(node_path).min_distance_to_reach_waypoint = rng.randf_range(225, 600)
	return get_node(node_path)


func get_waypoint_node(waypoint): #smh
	return "../AllPaths/" + str(waypoint).replace("../", "")

var closest_dist = INF
func find_closest_waypoint():
	var closest_waypoint
	for waypoint in all_waypoints:
		var dist = position.distance_to(waypoint.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_waypoint = waypoint
			


	return closest_waypoint


func turn_toward_target():
	var vectorToTarget = nav.target_position - position
	#var vectorToTarget = nav.get_next_path_position() - position
	vectorToTarget = vectorToTarget.normalized()

	var angle_to_target = transform.x.angle_to(vectorToTarget)

	var steer_amount = angle_to_target
	steer_amount = clamp(steer_amount, -1, 1)
	#print(rad_to_deg(angle_to_target))
	return steer_amount




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

	

	
	var d = car_heading.dot(velocity.normalized())
	if d > 0:	
		velocity = lerp(velocity, car_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -car_heading * min(velocity.length(), max_speed_reverse)

	rotation = car_heading.angle()

#returns the speed that need to be decreased to while turning, higher the angle the slower.
var is_angle_calcd = false
func check_angle_before_turning(min_speed, max_speed):
	if not is_angle_calcd:
		var target_direction = get_next_waypoint_node(current_waypoint).position - current_waypoint.position
		target_direction = target_direction.normalized()
		var car_dir = velocity.normalized() if velocity.length() > 0 else Vector2.ZERO
		var alignment = car_dir.dot(target_direction)
		var angle_radians = acos(alignment)
		var angle_degrees = rad_to_deg(angle_radians)
		
		is_angle_calcd = true
		var old_speed = velocity.length()
		target_speed = velocity.length() * (alignment + 2) / 2.0
		#print("Target Speed is: " + str(target_speed) + " Alignment is: " + str(alignment) + "While speed was: " + str(old_speed))
		target_speed = clampf(target_speed, min_speed, max_speed  )
		return target_speed
	

func apply_throttle():
	gas = lerpf(gas, engine_power, 0.01)
	steer_angle = 6

func apply_brake():
	#print("fren yapıyorum")
	gas = lerpf(gas, 0, 0.1)
	 #power = transform.x * brake
	steer_angle = 10
	

func apply_friction(delta):
	if power == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	power += friction_force + drag_force


func finish_lap():
	AudioManager.play_lap()
	Global.finished_laps["car2"] += 1
	Global.gui.update_players_info()

func collect_coin():
	Global.collected_coins["car2"] += 1
	Global.gui.update_players_info()

	AudioManager.play_coin()
