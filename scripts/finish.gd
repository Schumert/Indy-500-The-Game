extends Node

var race_manager
var player
# Called when the node enters the scene tree for the first time.
func _ready():
	race_manager = get_parent()



func _on_body_entered(body):
	if body.collision_layer & (1 << 1) != 0:
		player = "car1"
	
	if body.collision_layer & (1 << 4) != 0:
		player = "car2"
	
	race_manager.check_lap_completion(player)
