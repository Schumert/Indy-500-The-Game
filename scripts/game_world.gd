extends Node

var player
# Called when the node enters the scene tree for the first time.
func _ready():
	player = preload("res://car.tscn")

	add_child(player.instantiate())

	Global.change_state(Global.GameState.PLAYING)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match Global.current_state:
		Global.GameState.PLAYING:
			pass
		Global.GameState.PAUSED:
			pass
		Global.GameState.GAMEOVER:
			pass

func next_level(body):
	if body.name == "Car":
		print("bir sonraki levela geçme zamanı")
		var next_scene = preload("res://level1.tscn").instantiate()
		call_deferred("remove_child", get_child(0))
		add_child(next_scene)
		#add_child(player.instantiate())
