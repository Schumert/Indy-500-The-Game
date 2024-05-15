
extends Node

enum GameState { START, PLAYING, PAUSED, GAMEOVER }
var current_state = GameState.START

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
