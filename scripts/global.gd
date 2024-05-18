
extends Node

enum GameState { START, PLAYING, PAUSED, GAMEOVER }
var current_state = GameState.START

enum GameModes { RACE, TAG, COLLECT, WAR}
var current_mode

var player
var gui
var start_pos = Vector2(976, 702)


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
