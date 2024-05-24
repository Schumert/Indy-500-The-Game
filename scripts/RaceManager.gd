extends Node

var checkpoints = []

var total_checkpoints:= 3


func check_lap_completion(player):
	if Global.has_passed_all_checkpoints(player, total_checkpoints):
		print(player + "has completed a lap!")
		Global.player.finish_lap(player)
		Global.player_checkpoints[player] = []

func check_lap_completion_ai():
	if Global.has_passed_all_checkpoints("car2", total_checkpoints):
		Global.player_ai.finish_lap()
		Global.player_checkpoints["car2"] = []
	
	




		
