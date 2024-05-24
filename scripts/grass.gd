extends Node



func on_offroad_enter(body):
	if body is CharacterBody2D and (body.collision_layer & (1 << 1) != 0 or body.collision_layer & (1 << 4) != 0 ) :
		if self.is_in_group("grass"):
			body.friction = -700
			body.power /= 3
		else:
			body.friction = -200
			body.power /= 1.2

		body.engine_power = 2000
		
func on_offrad_exit(body):
	if body is CharacterBody2D and (body.collision_layer & (1 << 1) != 0 or body.collision_layer & (1 << 4) != 0 ):
		body.friction = body.temp_friction
		body.engine_power = body.temp_engine_power





