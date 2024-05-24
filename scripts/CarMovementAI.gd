extends CharacterBody2D

var max_speed = 700
var max_speed_start
var min_speed
var steer_force = 0.1
var look_ahead = 500
var num_rays = 100

#context array
var ray_directions = []
var interest = []
var danger = []

var chosen_dir = Vector2.ZERO
var acceleration =  Vector2.ZERO





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

		
	if Global.active_map == Global.maps[0][1]:
		max_speed = 400
		steer_force /= 2
	if Global.active_map.contains("icy"):
		max_speed = 300
		steer_force /= 2

	if Global.get_mode() == Global.GameModes.COLLECT:
		look_ahead = 350
		max_speed = 600
		steer_force = 0.01
		position = Vector2(229, 197)
	
	max_speed_start = max_speed + 100
	min_speed = max_speed

	
		
	
	max_speed -= 300
	await get_tree().create_timer(2).timeout
	max_speed += 100
	await get_tree().create_timer(1).timeout
	max_speed += 100
	await get_tree().create_timer(1).timeout
	max_speed += 100
	



func _process(delta):
	#Populate context arrays
	if Global.current_state == Global.GameState.PLAYING:
		set_interest()
		set_danger()
		choose_direction()
		#Movement
		var desired_velocity = chosen_dir.rotated(rotation) * max_speed
		velocity = velocity.lerp(desired_velocity, steer_force)
		rotation = velocity.angle()
		move_and_collide(velocity * delta)

func choose_direction():
	for i in num_rays:
		if danger[i] > 0.0:
			interest[i] = 0.0
	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += interest[i] * ray_directions[i]
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

func finish_lap():
	Global.finished_laps["car2"] += 1
	Global.gui.update_players_info()

	if Global.finished_laps["car2"] <= Global.finished_laps["car1"]:
		max_speed += 50
		if max_speed > max_speed_start:
			max_speed = max_speed_start 
	elif Global.finished_laps["car2"] > Global.finished_laps["car1"]:
		max_speed -= 50
		if max_speed < min_speed:
			max_speed = min_speed
	
	print("Botun hızı: %d" % max_speed)

func collect_coin():
	Global.collected_coins["car2"] += 1
	Global.gui.update_players_info()


