
extends Node

enum GameState { START, PLAYING, PAUSED, GAMEOVER }
var current_state = GameState.START

enum GameModes { RACE, COLLECT, TAG, WAR}
var current_mode

enum GameOpponents { ALONE, TWO_PLAYER, AI}
var current_opponent

@onready var maps = { GameModes.RACE : ["map1", "map3","map1_icy", "map3_icy"], GameModes.COLLECT: ["map2","map5", "map4","empty_icy", "map4_icy"], GameModes.TAG: []}


var player
var player_ai

var gui
var start_pos:Vector2
var start_pos2:Vector2
var start_rot2
var game_world
var active_map = "map1"
var timer_wait_time:=60
var max_lap:=20
var timer_node:Timer
var game_over_screen:Control

var player1
var player2

var collected_coins = {"car1" : 0, "car2": 0}
var finished_laps = {"car1" : 0, "car2": 0}
var player_checkpoints = {"car1" : [], "car2": []}

var coins := []

#time vars for counting time when the player is alone
var start_time
var elapsed_time = 0
var timer

var is_muted := false

func _input(event):
	if event.is_action_pressed("mute"):
		if not is_muted:
			AudioServer.set_bus_volume_db(0, -80)
			is_muted = true
		else:
			AudioServer.set_bus_volume_db(0, 0)
			is_muted = false
	

func change_state(new_state):
	current_state = new_state
	match current_state:
		GameState.START:
			print("Game State: START")
		GameState.PLAYING:
			print("Game State: PLAYING")
			if Global.get_mode() != Global.GameModes.RACE:
				timer.start()
		GameState.PAUSED:
			print("Game State: PAUSED")
		GameState.GAMEOVER:
			print("Game State: GAMEOVER")

func set_mode(mode):
	current_mode = mode
	match current_mode:
		GameModes.RACE:
			print("Game mode is racing.")
		GameModes.TAG:
			print("Game mode is tag.")
		GameModes.COLLECT:
			print("Game mode is collecting coin.")	
		GameModes.WAR:
			print("Game mode is war.")	

func get_mode():
	return current_mode

func set_map(map):
	active_map = map

func set_opponent(opponent):
	current_opponent = opponent
	match current_opponent:
		GameOpponents.ALONE:
			print("Current opponent is only yourself.")
		GameOpponents.TWO_PLAYER:
			print("Current opponent is a real person.")
		GameOpponents.AI:
			print("Current opponent is an AI.")


func add_checkpoint(player, checkpoint_id):
	if player_checkpoints.has(player):
		player_checkpoints[player].append(checkpoint_id)

func has_passed_all_checkpoints(player, total_checkpoints):
	if player_checkpoints.has(player):
		return player_checkpoints[player].size() == total_checkpoints
	return false

func is_checkpoint_in_order(player, checkpoint_id):
	var last_checkpoint = player_checkpoints[player].size()
	return checkpoint_id == last_checkpoint + 1



