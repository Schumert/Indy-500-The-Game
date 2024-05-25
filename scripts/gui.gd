extends Node

@export var player1:Label
@export var player2:Label
@export var timer:Label
@export var info:Label
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.gui = self
	update_players_info()
	if Global.current_mode != Global.GameModes.RACE or (Global.get_mode() == Global.GameModes.RACE and Global.current_opponent == Global.GameOpponents.ALONE) :
		timer.text = "Time: %d" % Global.timer_wait_time
	else:
		timer.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.get_mode() != Global.GameModes.RACE:
		timer.text = "Time: %d" % Global.timer_node.time_left
	elif Global.get_mode() == Global.GameModes.RACE and Global.current_opponent == Global.GameOpponents.ALONE:
		timer.text = "Time: %d" % Global.elapsed_time
	



func update_players_info():
	if Global.current_mode == Global.GameModes.COLLECT:
		info.text = "COLLECT"
		player1.text = "You collected %d godots" % Global.collected_coins["car1"]
		if Global.current_opponent == Global.GameOpponents.TWO_PLAYER:
			player1.text = "Player 1: %d godots" % Global.collected_coins["car1"]
			player2.text = "Player 2: %d godots" % Global.collected_coins["car2"]
		elif Global.current_opponent == Global.GameOpponents.AI:
			player1.text = "Player 1: %d godots" % Global.collected_coins["car1"]
			player2.text = "AI         : %d godots" % Global.collected_coins["car2"]
	elif Global.current_mode == Global.GameModes.RACE:
		info.text = "RACE"
		player1.text = "Player 1: %d lap / %d" % [Global.finished_laps["car1"], Global.max_lap ]
		if Global.current_opponent == Global.GameOpponents.TWO_PLAYER:
			player2.text = "Player 2: %d lap / %d" % [Global.finished_laps["car2"], Global.max_lap ]
		elif Global.current_opponent ==  Global.GameOpponents.AI:
			player2.text = "AI         : %d lap / %d" % [Global.finished_laps["car2"], Global.max_lap ]
		
