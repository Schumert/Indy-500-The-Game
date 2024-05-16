extends Node

var game_world_ref
# Called when the node enters the scene tree for the first time.
func _ready():
	game_world_ref = get_parent().get_parent()




func on_offroad_enter(body):
	if body is CharacterBody2D:
		game_world_ref.friction = -750
func on_offrad_exit(body):
	if body is CharacterBody2D:
		game_world_ref.friction = game_world_ref.temp_friction
