extends CharacterBody2D


@export var car_id : String
@export var min_speed_before_turning = 700
var min_distance = 500  # hedefe bu kadar yaklaşınca dur veya hız kes (waypoint)
@export var min_distance_coin = 250
var wheel_base = 70
var friction = -55
var temp_friction = friction
var steer_angle = 4
var steer_direction
var traction = 3
var max_speed_reverse = 200
var power = Vector2.ZERO
var drag = -0.06
var target_transform = null
var target_speed = 500
var max_min_distance_to_waypoint = 600


var gas = 0.0
var engine_power = 30000.0
var temp_engine_power = engine_power
var brake = -1000
var is_going_back = false
@export var turn_number = 0
var is_car_broken = false

enum AIMode { FOLLOWPLAYER, FOLLOWCHECKPOINTS, FOLLOWMOUSEPOSITION, FOLLOWCOINS}
var current_mode = AIMode.FOLLOWCOINS

var current_waypoint: Object
var chosen_waypoint : Object
var all_waypoints = []

enum AIState { PURSUIT, OBSTACLE_AVOIDANCE, RECOVERY }
var current_state = AIState.PURSUIT




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
	$Motor.play()

	if Global.active_map.contains("icy"):
		friction = -20
		temp_friction = friction
		traction = 1
		engine_power = 15000
		temp_engine_power = engine_power
	
	if Global.get_mode() == Global.GameModes.COLLECT:
		position = Vector2(229, 197)
		current_mode = AIMode.FOLLOWCOINS
	elif Global.get_mode() == Global.GameModes.RACE:
		current_mode = AIMode.FOLLOWCHECKPOINTS

	




func _process(delta):
	if Global.current_state == Global.GameState.PLAYING:
		repair_car_from_penalty(delta);
		if is_car_broken == true:
			if $Motor.is_playing():
				$Motor.stop();
				$BrokenMotor.play();
		else:
			if $BrokenMotor.is_playing():
				$Motor.play();
				$BrokenMotor.stop();

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
		if not is_going_back:
			power = transform.x * gas
		else:
			power = transform.x * brake

		match current_mode:
			AIMode.FOLLOWPLAYER:
				match current_state:
					AIState.PURSUIT:
						if obstacle_detected():
							current_state = AIState.OBSTACLE_AVOIDANCE
						elif target_is_behind():
							current_state = AIState.RECOVERY
						else:
							follow_player()
							if (nav.target_position - position).length() < 500:
								if velocity.length() >= get_tree().get_first_node_in_group("Player").velocity.length():
									apply_brake()
							else:
								apply_throttle()
					AIState.OBSTACLE_AVOIDANCE:
						if not obstacle_detected():
							current_state = AIState.PURSUIT
						else:
							avoid_obstacle(delta)
					AIState.RECOVERY:
						if is_aligned_with_target():
							current_state = AIState.PURSUIT
							print("car is aligned")
							is_going_back = false
						else:
							is_going_back = true


						
				engine_power = 15000
				
			AIMode.FOLLOWCHECKPOINTS:
				match current_state:
					AIState.PURSUIT:
						if obstacle_detected():
							current_state = AIState.OBSTACLE_AVOIDANCE
						elif target_is_behind():
							current_state = AIState.RECOVERY
						else:
							follow_waypoints()
							if (nav.target_position - position).length() < 500:
								if velocity.length() >= target_speed and velocity.length() >= 300:
									apply_brake()
							else:
								apply_throttle()
					AIState.OBSTACLE_AVOIDANCE:
						if not obstacle_detected():
							current_state = AIState.PURSUIT
						else:
							avoid_obstacle(delta)
					AIState.RECOVERY:
						if is_aligned_with_target():
							current_state = AIState.PURSUIT
							is_going_back = false
						else:
							is_going_back = true


			AIMode.FOLLOWMOUSEPOSITION:
				follow_mouse_position()
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				engine_power = 10000
				if (nav.target_position - position).length() < 500:
						apply_brake()
				else:
					apply_throttle()
			AIMode.FOLLOWCOINS:
				engine_power = 20000
				follow_coins()
				match current_state:
					AIState.PURSUIT:
						if obstacle_detected():
							current_state = AIState.OBSTACLE_AVOIDANCE
							print("AISTATE is OBSTACLE AVIODANCE")
						elif is_stuck_turning() or target_is_behind():
							current_state = AIState.RECOVERY
						elif is_stuck():
							pass
						else:
							
							if (nav.target_position - position).length() < 500:
								if gas >= 5000:
									apply_brake()
								else:
									apply_throttle()
							else:
								apply_throttle()
					AIState.OBSTACLE_AVOIDANCE:
						if not obstacle_detected():
							current_state = AIState.PURSUIT
							print("AISTATE is PURSUIT")
						else:
							avoid_obstacle(delta)
					AIState.RECOVERY:
						if is_aligned_with_target():
							print("AISTATE is PURSUIT")
							is_going_back = false
							print("car is aligned")
							current_state = AIState.PURSUIT
						elif velocity.length() >= 100:
							apply_brake()	
						else:
							is_going_back = true




		move_and_slide()
		#print("arabanin hizi: " + str(velocity.length()))
		#print(str(brake))
		#print((nav.target_position - position).length())
		#print(gas)



#KENDIME NOT: BU FONKSIYONLARI SONRA GÜZEL BİR YERE TAŞI
func obstacle_detected():
	return false


var previous_angle: float = 0.0
var cumulative_angle: float = 0.0
var tracking_started: bool = false
func is_stuck_turning():
	var current_angle = (global_position - nav.target_position).angle()
	
	if not tracking_started:
		previous_angle = current_angle
		tracking_started = true

	var angle_diff = current_angle - previous_angle

	if angle_diff > PI:
		angle_diff -= TAU
	elif angle_diff < -PI:
		angle_diff += TAU

	cumulative_angle += angle_diff
	previous_angle = current_angle

	if abs(cumulative_angle) >= TAU:
		print("360 derece dönme algılandı!")
		cumulative_angle = 0.0
		tracking_started = false
		return true
	else:
		return false


func is_stuck():
	return false
	



func target_is_behind():
	return false

func avoid_obstacle(delta):
	pass

func is_aligned_with_target(threshold: float = 0.4):
	var car_dir = Vector2(cos(rotation), sin(rotation)).normalized()
	var target_direction = (nav.target_position- global_position).normalized()

	var angle_diff = car_dir.angle_to(target_direction)

	#print("Align degeri bu: " + str(angle_diff))

	return abs(angle_diff) < threshold

	






func follow_coins():
	nav.target_position = get_parent().get_closest_coin(position).position




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
			get_next_waypoint_node(current_waypoint)
			current_waypoint = chosen_waypoint

var crash_possibility = 0.05
#gets next waypoint with bad choice probabilities
func get_next_waypoint_node(current_waypoint):
	var chosen_paths = []
	var chosen_path = null
	chosen_waypoint = null  #actually, chosen_path and chosen_waypoint is the same 
	var is_crash = true if randf() <= crash_possibility else false #there is a bad road choice with a probability of crash_possiblity


	#find the bad waypoint and add it to the chosen paths
	if is_crash:
		
		for waypoint in current_waypoint.next_waypoint_node:
			if get_node(get_waypoint_node(waypoint)).is_crash:
				chosen_paths.append(waypoint)
				print("AI yanlış yola girdi!!!! Girdiği yol: " + str(get_node(get_waypoint_node(waypoint)).name))
		
	#If no road found anyhow, do the same thing again but for the good waypoints.
	if chosen_paths.is_empty():
			for waypoint in current_waypoint.next_waypoint_node:
				if not get_node(get_waypoint_node(waypoint)).is_crash:
					chosen_paths.append(waypoint)

	#take a path amongst paths randomly.
	chosen_path = chosen_paths[rng.randf_range(0, chosen_paths.size())]



	var node_path = get_waypoint_node(chosen_path)
	var node = get_node(node_path)
	#set the min distance to reach waypoint randomly between given numbers. That increases AI car's variation of road progress
	if node.is_random_min_distance_allowed:
		node.min_distance_to_reach_waypoint = rng.randf_range(225, 
		node.random_max_limit_min_distace_to_reach_waypoint 
		if node.random_max_limit_min_distace_to_reach_waypoint != 0 else max_min_distance_to_waypoint)

	print("AI'ın waypoint'e ulaşma mesafesi: " + str(node.min_distance_to_reach_waypoint))
	print("Waypoint: " + str(node.name))
	chosen_waypoint = node


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
	var vectorToTarget
	vectorToTarget = (nav.target_position - position).normalized()
	#var vectorToTarget = nav.get_next_path_position() - position
	var angle_to_target = transform.x.angle_to(vectorToTarget)
	var steer_amount = angle_to_target
	
	if not is_going_back:
		steer_amount = clamp(steer_amount, -1, 1)
		#print(rad_to_deg(angle_to_target))
	else:
		steer_amount = -1 * clamp(steer_amount, -1, 1)
		
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
	#car is going backwards
	if d < 0:
		velocity = -car_heading * min(velocity.length(), max_speed_reverse)

	rotation = car_heading.angle()

#returns the speed that need to be decreased to while turning, higher the angle the slower.
var is_angle_calcd = false
func check_angle_before_turning(min_speed, max_speed):
	if not is_angle_calcd and chosen_waypoint != null:
		# var target_direction = get_next_waypoint_node(current_waypoint).position - current_waypoint.position
		var target_direction = chosen_waypoint.position - current_waypoint.position
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
	else:
		return 1000
	

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

#duration of recovery time, -1 penalty point every given second-
var duration = 15.0
var elapsed_time = 0.0
func repair_car_from_penalty(delta):
	if Global.game_world.penalty_points.has(self.car_id):
		if Global.game_world.penalty_points[self.car_id] > 0:
			elapsed_time += delta
			if elapsed_time >= duration:
				Global.game_world.penalty_points[self.car_id] -= 1
				Global.gui.update_penalty_info(true, "PENALTY PENALTY POINT: %d" % Global.game_world.penalty_points[self.car_id]);
				elapsed_time = 0.0
		else:
			elapsed_time = 0.0
