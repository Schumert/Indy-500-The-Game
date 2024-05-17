extends Node

var player
var player_instance
var friction = -10
var temp_friction = friction
var level_instance
var coin
var coin_instance


# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("remove_child", get_child(get_child_count() - 1))
	player = preload("res://car.tscn")
	coin = preload("res://coin.tscn")

	Global.change_state(Global.GameState.PLAYING)
	Global.set_mode(Global.GameModes.COLLECT)

	load_level("map1")


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
			pass
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
		
	
		if level_name == "test_map":
			if(is_instance_valid(player_instance)):
				player_instance.get_node("Camera2D").enabled = true
				get_parent().get_node("Camera2D").enabled = false
		else:
			if(is_instance_valid(player_instance)):
				player_instance.get_node("Camera2D").enabled = false
				get_parent().get_node("Camera2D").enabled = true
	if player_instance:
		player_instance.position = $StartPoint.position


func next_level(body):
	if body.name == "Car":
		load_level("map1")



