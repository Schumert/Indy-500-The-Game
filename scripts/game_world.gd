extends Node

var player
@export var map = preload("res://test_map.tscn")
var friction = -10
var temp_friction = friction
var grass
# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("remove_child", get_child(get_child_count() - 1))
	player = preload("res://car.tscn")
	
	var inst_player = player.instantiate()
	add_child(inst_player)
	inst_player.position = $StartPoint.position


	add_child(map.instantiate())

	Global.change_state(Global.GameState.PLAYING)
	Global.set_mode(Global.GameModes.RACE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match Global.current_state:
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
			pass
		Global.GameModes.WAR:
			pass

func next_level(body):
	if body.name == "Car":
		print("bir sonraki levela geçme zamanı")
		var next_scene = preload("res://map1.tscn").instantiate()
		body.queue_free()
		var inst_player = player.instantiate()
		call_deferred("add_child", inst_player)
		inst_player.position = $StartPoint.position

		call_deferred("remove_child", get_child(get_child_count() - 1))
		call_deferred("add_child", next_scene)


