extends Node

var player
var player_instance

var player2
var player2_instance

var playerAI
var playerAI_instance


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.start_pos = $StartPos.global_position
	Global.start_pos2 = $StartPos2.global_position
	Global.start_rot2 = $StartPos2.rotation

	player = preload("res://car.tscn")
	player2 = preload("res://car2.tscn")
	playerAI = preload("res://carAI.tscn")

	if player_instance:
		remove_child(player_instance)
	player_instance = player.instantiate()
	call_deferred("add_child", player_instance)

	if Global.current_opponent == Global.GameOpponents.TWO_PLAYER:
		if player2_instance:
			remove_child(player2_instance)
		player2_instance = player2.instantiate()
		call_deferred("add_child", player2_instance)
	elif Global.current_opponent == Global.GameOpponents.AI:
		if playerAI_instance:
			remove_child(playerAI_instance)
		playerAI_instance = playerAI.instantiate()
		call_deferred("add_child", playerAI_instance)

	


# func get_path_direction(pos: Vector2):
# 	var offset = path.curve.get_closest_offset(pos)
# 	path_follow.progress = offset
	
# 	return path_follow.transform.x




