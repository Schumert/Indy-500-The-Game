extends Node

var checkpoints = []
var finish_line

var is_checkpoints_finished = {"car1": false, "car2": false}
var total_checkpoints:= 3


func check_lap_completion(player):
	if Global.has_passed_all_checkpoints(player, total_checkpoints):
		print(player + "has completed a lap!")
		Global.player.finish_lap(player)
		Global.player_checkpoints[player] = []

	
	




		
