extends CharacterBody2D

var speed = 600
var min_distance = 400  # hedefe bu kadar yaklaşınca dur veya hız kes
var wheel_base = 70
var friction = -55
var steer_angle = 4
var steer_direction
var traction = 3
var max_speed_reverse = 200
var power = Vector2.ZERO
var drag = -0.06
var target_transform = null

var gas = 0.0
var engine_power = 20000.0
var brake = -250
@export var turn_number = 0
var new_turn_number

enum AIMode { FOLLOWPLAYER, FOLLOWCHECKPOINTS}
var current_mode = AIMode.FOLLOWCHECKPOINTS

var current_waypoint: Object
var all_waypoints = []




@export var nav: NavigationAgent2D
var current_direction: Vector2 = Vector2.ZERO
var checkpointIndex = 0

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





func _process(delta):
	# new_turn_number = clamp(turn_number, -1, 1)
	#print(velocity.length())
	pass
	






# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Global.current_state == Global.GameState.PLAYING:
		# if not nav.target_position: _set_new_target()
		
		
		
		
		# velocity = velocity.lerp(global_position.direction_to(next_position) * speed, 0.1)
		# rotation = velocity.angle()
		# move_and_slide()

		match current_mode:
			AIMode.FOLLOWPLAYER:
				follow_player()
			AIMode.FOLLOWCHECKPOINTS:
				follow_waypoints()
				
		
		turn_number = turn_toward_target()




		apply_friction(delta)
		steering(delta)
		
		velocity += power * delta
		
		if (nav.target_position - position).length() > min_distance:
			gas = lerpf(gas, engine_power, 0.005)
			actions(turn_number, gas)
			steer_angle = 4
		else:
			actions(turn_number, brake)
			gas = lerpf(gas, 0, 0.1)
			steer_angle = 6

		move_and_slide()
	
		

func follow_player():
	if target_transform == null:
		target_transform = get_tree().get_first_node_in_group("Player")
		
	
	if target_transform != null:
		nav.target_position = target_transform.position



var distance_to_waypoint
func follow_waypoints():
	if current_waypoint == null:
		current_waypoint = find_closest_waypoint()
	
	if current_waypoint != null:
		nav.target_position = current_waypoint.global_position

		distance_to_waypoint = (nav.target_position - global_position).length()
		if distance_to_waypoint <= current_waypoint.min_distance_to_reach_waypoint:
			var node_path = "../AllPaths/" + str(current_waypoint.next_waypoint_node[0]).replace("../", "")
			current_waypoint = get_node(node_path)
		print(distance_to_waypoint)

			


var closest_dist = INF
func find_closest_waypoint():
	var closest_waypoint
	for waypoint in all_waypoints:
		var dist = position.distance_to(waypoint.position)
		if dist < closest_dist:
			closest_dist = dist
			closest_waypoint = waypoint

	return closest_waypoint

var waypoints_index = 0
# func _set_new_waypoint():
# 	if all_waypoints.size() == waypoints_index:
# 		nav.target_position = all_waypoints[0]
# 		checkpointIndex = 0
# 	else:
# 		nav.target_position = all_waypoints[waypoints_index].global_position
# 		checkpointIndex+=1






func turn_toward_target():
	var vectorToTarget = nav.target_position - position
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

func actions(turn, gas):

	steer_direction = turn * deg_to_rad(steer_angle)
	power = transform.x * gas


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
