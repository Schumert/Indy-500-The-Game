extends Node

var player
var player_instance

var player2
var player2_instance

var playerAI
var playerAI_instance

var path:Path2D
var path_follow:PathFollow2D


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

	# path = $Path2D
	# path_follow = $Path2D/PathFollow2D

	AudioManager.play_crowd_music()

# func get_path_direction(pos):
# 	var offset = path.curve.get_closest_offset(pos)
# 	path_follow.global_position = path.curve.sample_baked(offset)
# 	return path_follow.global_transform.x

func get_closest_coin_direction(pos: Vector2):
	if Global.coins.is_empty():
		return Vector2.ZERO

	var closest_coin
	var closest_distance

	for coin in Global.coins:
		if coin != null:
			var coin_position = coin.position
			var distance := pos.distance_to(coin_position)

			if closest_distance != null:
				if distance < closest_distance:
					closest_distance = distance
					closest_coin = coin
			else:
				closest_distance = distance
				closest_coin = coin
	if closest_coin != null:
		var direction = (closest_coin.position - pos).normalized()
		return direction
	else:
		return Vector2.ZERO
		







