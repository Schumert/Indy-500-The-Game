extends Node





var level_instance
var coin
var coin_instance

var rng
var coin_delay

signal game_over 

# Called when the node enters the scene tree for the first time.
func _ready():
	#call_deferred("remove_child", get_child(get_child_count() - 1))
	
	coin = preload("res://coin.tscn")
	Global.game_world = self

	$Timer.wait_time = Global.timer_wait_time
	Global.timer_node = $Timer
	

	Global.change_state(Global.GameState.START)
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
	
	Global.timer = $Timer

	self.connect("game_over", _on_game_over)


	#!!!!!!!!!(its in start_screen.gd now)
	# await get_tree().create_timer(1).timeout
	# Global.change_state(Global.GameState.PLAYING)

	Global.start_time = Time.get_unix_time_from_system()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match Global.current_state:
		Global.GameState.START:
			AudioServer.set_bus_volume_db(1, 0) #set back the motor volume to its old value
		Global.GameState.PLAYING:
			Global.elapsed_time = get_elapsed_time()
		Global.GameState.PAUSED:
			pass
		Global.GameState.GAMEOVER:
			pass
	
	match Global.current_mode:
		Global.GameModes.RACE:
			if Global.finished_laps["car1"] >= Global.max_lap or Global.finished_laps["car2"] >= Global.max_lap:
				if Global.current_state != Global.GameState.GAMEOVER:
					Global.change_state(Global.GameState.GAMEOVER)
					game_over.emit()
		Global.GameModes.TAG:
			pass
		Global.GameModes.COLLECT:
			if not coin_instance:
				coin_instance = coin.instantiate()
				add_child(coin_instance)
				Global.coins.append(coin_instance)
			
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

		
		
		
		
	


func _on_timer_finished_spawn_coin():
	coin_instance = coin.instantiate()
	add_child(coin_instance)

	#coin_delay = get_tree().create_timer(2)
	$CoinTimer.wait_time = rng.randf_range(2, 10)
	Global.coins.append(coin_instance)


func _on_timer_timeout(): #when the game time is over
	Global.change_state(Global.GameState.GAMEOVER)
	game_over.emit()


func _on_game_over():
	get_parent().get_node("CanvasLayer/GameOver").visible = true
	AudioServer.set_bus_volume_db(1, -80)

func get_elapsed_time() -> int:
	# Güncel zamanı al
	var current_time = Time.get_unix_time_from_system() - 4 #4 is start wait time
	# Geçen zamanı hesapla
	var elapsed_time = current_time - Global.start_time
	return elapsed_time