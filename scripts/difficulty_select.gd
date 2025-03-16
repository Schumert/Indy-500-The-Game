extends Node

@export var easy_button:Button
@export var normal_button:Button
@export var hard_button:Button


# Called when the node enters the scene tree for the first time.
func _ready():
	easy_button.connect("button_down", _on_difficulty_button_down.bind(Global.Difficulty.EASY))
	normal_button.connect("button_down", _on_difficulty_button_down.bind(Global.Difficulty.NORMAL))
	hard_button.connect("button_down", _on_difficulty_button_down.bind(Global.Difficulty.HARD))

	if Global.current_mode == Global.GameModes.COLLECT:
		Global.set_difficulty(Global.Difficulty.NORMAL)
	if Global.current_mode == Global.GameModes.RACE:
		Global.set_difficulty(Global.Difficulty.NORMAL)
	
	update_text(Global.current_difficulty)



func _on_difficulty_button_down(difficulty):
	Global.set_difficulty(difficulty)
	update_text(difficulty)
	AudioManager.play_click()
	if difficulty == Global.Difficulty.HARD:
		AudioManager.play_max()
	elif difficulty == Global.Difficulty.EASY:
		AudioManager.stop_max()
		AudioManager.play_easy()
		
	else:
		AudioManager.stop_max()


func update_text(difficulty):
	var unwanted_chars = ["." , ",","'", "_", "-", ":"]
	var difficulty_name = Global.Difficulty.keys()[difficulty]
	for c in unwanted_chars:
		difficulty_name = difficulty_name.replace(c, " ")
	$CanvasLayer/Difficulty.text = "SELECTED: %s" % difficulty_name
	

func _on_back_button_down():
	get_tree().change_scene_to_file("res://opponent_select.tscn")
	AudioManager.play_click()
	AudioManager.stop_max()


func _on_continue_button_down():
	get_tree().change_scene_to_file("res://main.tscn")
	AudioManager.play_click()
	AudioManager.stop_max()
	

#get_tree().change_scene_to_file("res://difficulty_select.tscn")

