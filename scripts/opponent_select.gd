extends Node

@export var alone_button:Button
@export var two_player_button:Button
@export var ai_button:Button
# Called when the node enters the scene tree for the first time.
func _ready():
	alone_button.connect("button_down", _on_opponent_button_down.bind(Global.GameOpponents.ALONE))
	two_player_button.connect("button_down", _on_opponent_button_down.bind(Global.GameOpponents.TWO_PLAYER))
	ai_button.connect("button_down", _on_opponent_button_down.bind(Global.GameOpponents.AI))

	if Global.current_mode == Global.GameModes.COLLECT:
		ai_button.disabled = true
		Global.set_opponent(Global.GameOpponents.ALONE)
	if Global.current_mode == Global.GameModes.RACE:
		alone_button.disabled = true
		Global.set_opponent(Global.GameOpponents.TWO_PLAYER)
	
	update_text(Global.current_opponent)

	

	



func _on_back_button_down():
	get_tree().change_scene_to_file("res://mode_map_select.tscn")


func _on_continue_button_down():
	get_tree().change_scene_to_file("res://main.tscn")

func _on_opponent_button_down(opponent):
	Global.set_opponent(opponent)
	update_text(opponent)
	

func update_text(opponent):
	var unwanted_chars = ["." , ",","'", "_", "-", ":"]
	var opponent_name = Global.GameOpponents.keys()[opponent]
	for c in unwanted_chars:
		opponent_name = opponent_name.replace(c, " ")
	$PanelContainer2/Opponent.text = "SELECTED: %s" % opponent_name

