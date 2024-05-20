extends Node



func on_offroad_enter(body):
	if body is CharacterBody2D:
		if self.is_in_group("grass"):
			body.friction = -700
			body.rpm /= 3
		else:
			body.friction = -200
			body.rpm /= 1.2

		body.engine_power = 2000
		
func on_offrad_exit(body):
	if body is CharacterBody2D:
		body.friction = body.temp_friction
		body.engine_power = body.temp_engine_power





