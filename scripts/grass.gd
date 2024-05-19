extends Node



func on_offroad_enter(body):
	if body is CharacterBody2D:
		body.friction = -300

		body.engine_power = 2000
		body.rpm /= 1.5
func on_offrad_exit(body):
	if body is CharacterBody2D:
		body.friction = body.temp_friction
		body.engine_power = body.temp_engine_power





