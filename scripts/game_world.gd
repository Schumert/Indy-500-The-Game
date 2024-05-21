extends Node

var player
var player_instance

var player2
var player2_instance

var level_instance
var coin
var coin_instance

var rng
var coin_delay

signal game_over 

# Called when the node enters the scene tree for the first time.
func _ready():
	#call_deferred("remove_child", get_child(get_child_count() - 1))
	player = preload("res://car.tscn")
	player2 = preload("res://car2.tscn")
	
	coin = preload("res://coin.tscn")
	Global.game_world = self

	$Timer.wait_time = Global.timer_wait_time
	Global.timer_node = $Timer
	

	Global.change_state(Global.GameState.PLAYING)
	#Global.set_mode(Global.GameModes.COLLECT)
	#Global.set_opponent(Global.GameOpponents.ALONE)
	Global.gui.update_players_info()

	load_level(Global.active_map)
	
	rng = RandomNumberGenerator.new()

	if Global.current_mode == Global.GameModes.COLLECT:
		coin_instance = coin.instantiate()
		add_child(coin_instance)
		coin_instance.position = Vector2(1500, 500)
		$CoinTimer.start()
	
	if Global.current_mode == Global.GameModes.RACE:
		pass
	else:
		$Timer.start() #game life-time

	self.connect("game_over", _on_game_over)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match Global.current_state:
		Global.GameState.START:
			pass
		Global.GameState.PLAYING:
			pass
		Global.GameState.PAUSED:
			pass
		Global.GameState.GAMEOVER:
			pass
	
	match Global.current_mode:
		Global.GameModes.RACE:
			if Global.finished_laps["car1"] or Global.finished_laps["car2"] >= Global.max_lap:
				if Global.current_state != Global.GameState.GAMEOVER:
					Global.change_state(Global.GameState.GAMEOVER)
					game_over.emit()
		Global.GameModes.TAG:
			pass
		Global.GameModes.COLLECT:
			if not coin_instance:
				coin_instance = coin.instantiate()
				add_child(coin_instance)
			
		Global.GameModes.WAR:
			pass

	

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
		call_deferred("add_child", level_instance)
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
			pass
		
		
		
		
	


func _on_timer_finished_spawn_coin():
	coin_instance = coin.instantiate()
	add_child(coin_instance)

	#coin_delay = get_tree().create_timer(2)
	$CoinTimer.wait_time = rng.randf_range(2, 10)


func _on_timer_timeout(): #when the game time is over
	Global.change_state(Global.GameState.GAMEOVER)
	game_over.emit()


func _on_game_over():
	get_parent().get_node("CanvasLayer/GameOver").visible = true
