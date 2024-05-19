
extends Node

enum GameState { START, PLAYING, PAUSED, GAMEOVER }
var current_state = GameState.START

enum GameModes { RACE, TAG, COLLECT, WAR}
var current_mode

@onready var maps = { GameModes.RACE : ["map1"], GameModes.COLLECT: ["map1", "test_map"], GameModes.TAG: ["map1"]}


var player = preload("res://car.tscn")
var player_instance
var gui
var start_pos = Vector2(976, 702)
var game_world
var level_instance
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



func  unload_level():
	if(is_instance_valid(level_instance)):
		level_instance.queue_free()
	level_instance = null

func load_level(level_name : String):
	unload_level()
	var level_path = "res://Levels/%s.tscn" % level_name
	var level_resource = load(level_path)
	if(level_resource):
		level_instance = level_resource.instantiate()
		game_world.call_deferred("add_child", level_instance)
		if player_instance:
			game_world.remove_child(player_instance)
			
		player_instance = player.instantiate()
		game_world.call_deferred("add_child", player_instance)

		if player_instance:
			player_instance.position = start_pos
