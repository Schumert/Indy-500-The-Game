
extends Node

enum GameState { START, PLAYING, PAUSED, GAMEOVER }
var current_state = GameState.START

enum GameModes { RACE, COLLECT, TAG, WAR}
var current_mode

enum GameOpponents { ALONE, TWO_PLAYER, AI}
var current_opponent

@onready var maps = { GameModes.RACE : ["map1", "map3","map1_icy", "map3_icy"], GameModes.COLLECT: ["map2","map5", "map4","empty_icy", "map4_icy"], GameModes.TAG: []}


var player

var gui
var start_pos:Vector2
var start_pos2:Vector2
var start_rot2
var game_world
var active_map = "map1"
var timer_wait_time:int

var player_cross_checkpoint

var collected_coins = {"car1" : 0, "car2": 0}
var finished_laps = {"car1" : 0, "car2": 0}

func change_state(new_state):
	current_state = new_state
	match current_state:
		GameState.START:
			print("Game State: START")
		GameState.PLAYING:
			print("Game State: PLAYING")
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



