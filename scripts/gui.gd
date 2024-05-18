extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	Global.gui = self
	update_players_info()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$PanelContainer/MarginContainer/GridContainer/VelocityLength.text = "Velocity Length: %4.1f" % Global.player.velocity.length()
	pass



func update_players_info():
	if Global.current_mode == Global.GameModes.COLLECT:
		$PanelContainer/MarginContainer/GridContainer/INFO.text = "COLLECT"
		$PanelContainer/MarginContainer/GridContainer/Player1.text = "Player 1: %d coin" % Global.collected_coins["car1"]
		$PanelContainer/MarginContainer/GridContainer/Player2.text = "Player 2: %d coin" % Global.collected_coins["car2"]
	elif Global.current_mode == Global.GameModes.RACE:
		$PanelContainer/MarginContainer/GridContainer/INFO.text = "RACE"
		$PanelContainer/MarginContainer/GridContainer/Player1.text = "Player 1: %d lap" % Global.finished_laps["car1"]
		$PanelContainer/MarginContainer/GridContainer/Player2.text = "Player 2: %d lap" % Global.finished_laps["car2"]



