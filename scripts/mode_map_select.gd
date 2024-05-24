extends Control

var button
var button_instance
var maps
var main_menu
var counter = 1

@export var race_button:Button
@export var collect_button :Button
@export var tag_button :Button
@export var map_texture:TextureRect
@export var continue_button:Button
# Called when the node enters the scene tree for the first time.
func _ready():
	maps = Global.maps[Global.current_mode]

	
	button = preload("res://map_button.tscn")
	update_map_buttons()

	race_button.connect("button_down", _on_mode_button_pressed.bind(Global.GameModes.RACE) )
	collect_button.connect("button_down", _on_mode_button_pressed.bind(Global.GameModes.COLLECT) )
	tag_button.connect("button_down", _on_mode_button_pressed.bind(Global.GameModes.TAG) )


func update_map_buttons():
	var button_container = $PanelContainer/MarginContainer2/VBoxContainer
	clear_children(button_container)
	maps = Global.maps[Global.current_mode]
	
	for map_name in maps:
		button_instance = button.instantiate()
		button_instance.text = "%d. map" % counter
		
		button_instance.connect("button_down", _on_map_button_pressed.bind(map_name))
		get_node("PanelContainer/MarginContainer2/VBoxContainer").add_child(button_instance)
		if counter == 1:
			Global.set_map(map_name)
			map_texture.texture = load("res://assets/ss_for_maps/%s.png" % map_name)

		counter+=1
	if maps.size() == 0:
		continue_button.disabled = true
		$PanelContainer/GameMode.text = "GAME MODE: %s\nIS WORK IN PROGRESS!" % Global.GameModes.keys()[Global.current_mode]
	else:
		continue_button.disabled = false
		$PanelContainer/GameMode.text = "GAME MODE: %s" % Global.GameModes.keys()[Global.current_mode]
	counter = 1

	

func _on_map_button_pressed(map_name):
	print("Selected map:", map_name)
	
	Global.set_map(map_name)
	map_texture.texture = load("res://assets/ss_for_maps/%s.png" % map_name)

func _on_mode_button_pressed(button_name):
	Global.set_mode(button_name)
	if Global.current_mode == Global.GameModes.RACE:
		$TimeOption.visible = false
		$LapOption.visible = true
	else:
		$TimeOption.visible = true
		$LapOption.visible = false
	update_map_buttons()

func clear_children(container):
	# for child in children:  #This code works as well but gives an error at the same time, weird innit?
	# 	remove_child(child)
	# 	child.queue_free()
	for i in range(container.get_child_count() - 1, -1, -1):
		var child = container.get_child(i)
		container.remove_child(child)
		child.queue_free()



func _on_back_button_down():
	get_tree().change_scene_to_file("res://menu.tscn")
	


func _on_continue_button_down():
	#Global.change_state(Global.GameState.PLAYING)
	get_tree().change_scene_to_file("res://opponent_select.tscn")
	
	



func _on_option_button_item_selected(index):
	Global.timer_wait_time = $TimeOption.get_item_text(index).to_int()
	print("Timer set to: %s" % $TimeOption.get_item_text(index))


func _on_lap_option_item_selected(index):
	Global.max_lap = $LapOption.get_item_text(index).to_int()
	print("Max lap set to: %s" % $LapOption.get_item_text(index))
