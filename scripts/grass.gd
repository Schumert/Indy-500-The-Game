extends Node

var game_world_ref
var temp_engine_power
# var will_penalty_be_on := false
# Called when the node enters the scene tree for the first time.
func _ready():
	game_world_ref = get_parent().get_parent()


func on_offroad_enter(body):
	if body is CharacterBody2D:
		game_world_ref.friction = -300

		Global.player.engine_power = 2000
		Global.player.rpm /= 3
		Global.player.velocity /= 2
		# get_parent().get_node("PenaltyRequirement").start()
func on_offrad_exit(body):
	if body is CharacterBody2D:
		game_world_ref.friction = game_world_ref.temp_friction
		Global.player.engine_power = Global.player.temp_engine_power
		# get_parent().get_node("PenaltyRequirement").stop()
		
	# if will_penalty_be_on:
	# 	Global.player.is_penalty_on = not Global.player.is_penalty_on
	# 	print("Penalty is active!")
	# 	if Global.player.is_penalty_on:
	# 		get_parent().get_node("PenaltyTime").start()
	# 	will_penalty_be_on = false

# func on_time_out_penalty_on():
# 	will_penalty_be_on = true
	

# func on_time_out_get_normal():
# 	Global.player.is_penalty_on = false
# 	print("Penalty is over!")





