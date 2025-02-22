extends CharacterBody2D

var current_speed = 0.0
var max_speed = 500.0
var steer_force = 0.1
var look_ahead = 500.0
var num_rays = 100.0
var acceleration = 100
var brake = 5
var wheel_base = 70
var steer_direction
var max_steer = 3
var traction = 3

#context array
var ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector2.ZERO
#var acceleration =  Vector2.ZERO





func _ready():
	Global.player_ai = self
	position = Global.start_pos2

	Global.collected_coins["car2"] = 0
	Global.finished_laps["car2"] = 0
	Global.player_checkpoints["car2"] = []
	Global.gui.update_players_info()

	interest.resize(num_rays)
	danger.resize(num_rays)
	ray_directions.resize(num_rays)

	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
	
		
	#if Global.active_map == Global.maps[0][1]:
	#	max_speed = 400.0
	#	steer_force /= 1.5
	#if Global.active_map.contains("icy"):
	#	max_speed = 300.0
	#	steer_force /= 2
	#if Global.get_mode() == Global.GameModes.COLLECT:
	#	look_ahead = 350
	#	max_speed = 300.0
	#	steer_force = 0.01
	#	position = Vector2(229, 197)
	#
	#if Global.get_mode() == Global.GameModes.COLLECT and Global.active_map.contains("icy") :
	#	look_ahead = 300
	#	max_speed = 150.0
	#	steer_force = 0.01
	#	position = Vector2(229, 197)




func _physics_process(delta):
	#Populate context arrays
	if Global.current_state == Global.GameState.PLAYING:
		if $Motor.is_playing() == false:
			$Motor.play()

		
		set_interest()
		set_danger()
		choose_direction()
		
		#Movement
		if is_in_danger():
			current_speed = lerp(current_speed, 20.0, brake * delta)
			if current_speed <= 100:
				max_steer = lerp(3, 20, delta)
		else:
			current_speed = lerp(current_speed, max_speed, acceleration * delta)
			max_steer = lerp(20, 3, delta)
			
		
		
		# Dönüşü yumuşak yap:
		var desired_angle = chosen_dir.angle()
		var angle_diff = desired_angle - rotation
		print(rotation)
		var max_turn = deg_to_rad(max_steer)
		steer_direction = desired_angle * max_turn
		steering(delta)
		
		#harket
		velocity = Vector2(current_speed, 0).rotated(rotation)
		move_and_collide(velocity * delta)

func is_in_danger():
	var space_state = get_world_2d().direct_space_state
	
	var from = position
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	
	var ray_length = 350
	var to = from + forward_direction * ray_length
	
	var query = PhysicsRayQueryParameters2D.new()
	query.from = from
	query.to = to
	query.exclude = [self, Global.player]
	
	var result = space_state.intersect_ray(query)
	if result:
		#print("Önünde bir engele çarptım:", result.collider)
		return true
	else:
		return false


func choose_direction():
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += interest[i] * ray_directions[i]
	# Eğer seçilen yön sıfırsa, aracın mevcut yönünü kullan
	if chosen_dir.length() == 0:
		chosen_dir = transform.x
	else:
		chosen_dir = chosen_dir.normalized()

func set_interest():
	if get_parent() and get_parent().has_method("get_closest_coin_direction") and Global.get_mode() == Global.GameModes.COLLECT:
		var path_direction = get_parent().get_closest_coin_direction(position)
		path_direction = transform.x if null else path_direction
		for i in num_rays:
			var d = ray_directions[i].rotated(rotation).dot(path_direction)
			interest[i] = max(0, d)
	else:
		set_default_interest()
	# elif get_parent() and get_parent().has_method("get_path_direction") and Global.get_mode() == Global.GameModes.RACE:
	# 	var path_direction = get_parent().get_path_direction(global_position)
	# 	for i in num_rays:
	# 		var d = ray_directions[i].rotated(rotation).dot(path_direction)
	# 		interest[i] = max(0, d)
	

func set_default_interest():
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(transform.x)
		interest[i] = max(0 , d)

func set_danger():
	var space_state = get_world_2d().direct_space_state
	
	for i in num_rays:
		var from = position
		var to = position + ray_directions[i].rotated(rotation) * look_ahead
		var query = PhysicsRayQueryParameters2D.new()
		query.from = from
		query.to = to
		query.exclude = [self, Global.player]

		var result = space_state.intersect_ray(query)

		danger[i] = 1.0 if result else 0.0
		


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
		velocity = -car_heading * min(velocity.length(), 20)

	rotation = car_heading.angle()

func finish_lap():
	AudioManager.play_lap()
	Global.finished_laps["car2"] += 1
	Global.gui.update_players_info()
	
	print("Botun hızı: %d" % max_speed)

func collect_coin():
	Global.collected_coins["car2"] += 1
	Global.gui.update_players_info()

	AudioManager.play_coin()


