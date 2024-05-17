extends Node

var game_world_ref
var will_penalty_be_on := false
# Called when the node enters the scene tree for the first time.
func _ready():
	game_world_ref = get_parent().get_parent()


func on_offroad_enter(body):
	if body is CharacterBody2D:
		#game_world_ref.friction = -750

		#Global.player.engine_power = 2000
		#Global.player.rpm /= 2
		#Global.player.velocity /= 2
		get_parent().get_node("PenaltyRequirement").start()
func on_offrad_exit(body):
	if body is CharacterBody2D:
		game_world_ref.friction = game_world_ref.temp_friction
		Global.player.engine_power = 15000
		get_parent().get_node("PenaltyRequirement").stop()
	if will_penalty_be_on:
		Global.player.is_penalty_on = not Global.player.is_penalty_on
		print("Penalty is active!")
		if Global.player.is_penalty_on:
			get_parent().get_node("PenaltyTime").start()
		will_penalty_be_on = false

func on_time_out_penalty_on():
	will_penalty_be_on = false
	

func on_time_out_get_normal():
	Global.player.is_penalty_on = false
	print("Penalty is over!")





