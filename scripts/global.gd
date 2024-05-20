
extends Node

enum GameState { START, PLAYING, PAUSED, GAMEOVER }
var current_state = GameState.START

enum GameModes { RACE, COLLECT, TAG, WAR}
var current_mode

@onready var maps = { GameModes.RACE : ["map1"], GameModes.COLLECT: ["map1", "map2"], GameModes.TAG: []}


var player = preload("res://car.tscn")
var gui
var start_pos:Vector2
var start_pos2:Vector2
var game_world
var active_map = "map1"


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



