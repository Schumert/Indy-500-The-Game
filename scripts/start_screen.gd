extends Node

var all_red = preload("res://assets/2d_race_cars/misc/sem_all_red.png")
var two_red = preload("res://assets/2d_race_cars/misc/sem_2_red.png")
var one_red = preload("res://assets/2d_race_cars/misc/sem_1_red.png")
var all_green = preload("res://assets/2d_race_cars/misc/sem_all_green.png")

@export var texture_rect:Sprite2D
func _ready():
	await get_tree().create_timer(1).timeout
	
	texture_rect.texture = two_red
	AudioManager.play_start_red()

	await get_tree().create_timer(1).timeout
	
	texture_rect.texture = one_red
	AudioManager.play_start_red()

	await get_tree().create_timer(1).timeout
	
	texture_rect.texture = all_green
	AudioManager.play_start_green()

	await get_tree().create_timer(0.5).timeout

	self.visible = false
	Global.change_state(Global.GameState.PLAYING)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
