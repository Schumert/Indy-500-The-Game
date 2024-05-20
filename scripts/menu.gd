extends Node


@onready var play_button = $MarginContainer2/VBoxContainer/PlayButton as Button
@onready var settings_button = $MarginContainer2/VBoxContainer/SettingsButton as Button
@onready var quit_button = $MarginContainer2/VBoxContainer/QuitButton as Button

var game_select = preload("res://mode_map_select.tscn")
var game_select_instance

# Called when the node enters the scene tree for the first time.
func _ready():
	play_button.button_down.connect(on_play_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	Global.set_mode(Global.GameModes.RACE)
	#Global.change_state(Global.GameState.PAUSED)

	


func on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_map_select.tscn")
func on_quit_pressed() -> void:
	get_tree().quit()

