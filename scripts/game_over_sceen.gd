extends Node

var is_screen_updated:= false
var is_tie:= false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.visible == true:
		if not is_screen_updated:
			var who_wins
			if Global.current_mode == Global.GameModes.RACE:
				if Global.finished_laps["car1"] > Global.finished_laps["car2"]:
					who_wins = "Player 1"
				else:
					who_wins = "Player 2"
				$Panel/HBoxContainer2/VBoxContainer/Player1.text = "Player 1: %d / %d laps" % [Global.finished_laps["car1"], Global.max_lap] 
				$Panel/HBoxContainer2/VBoxContainer/Player2.text = "Player 2: %d / %d laps" % [Global.finished_laps["car2"], Global.max_lap]
			elif Global.current_mode == Global.GameModes.COLLECT:
				if Global.collected_coins["car1"] > Global.collected_coins["car2"]:
					who_wins = "Player 1"
				elif Global.collected_coins["car1"] < Global.collected_coins["car2"]:
					who_wins = "Player 2"
				else:
					who_wins = "TIE"
					is_tie = true
				$Panel/HBoxContainer2/VBoxContainer/Player1.text = "Player 1: %d coins" % Global.collected_coins["car1"]
				$Panel/HBoxContainer2/VBoxContainer/Player2.text = "Player 2: %d coins" % Global.collected_coins["car2"]
			if not is_tie:
				$Panel/HBoxContainer/VBoxContainer2/WhoWon.text = "%s wins!!" % who_wins
			else:
				$Panel/HBoxContainer/VBoxContainer2/WhoWon.text = "%s!!" % who_wins
			is_screen_updated = true
			
		


func _on_restart_button_down():
	get_tree().reload_current_scene()


func _on_menu_button_down():
	get_tree().change_scene_to_file("res://menu.tscn")
