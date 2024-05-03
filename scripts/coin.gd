extends Node


func _ready():
	pass
	


func _on_body_entered(body:Node2D):
	if body.collision_layer == 2:
		spawn_new_one()

func spawn_new_one():
	
	var x_pos:float
	var y_pos:float
	var rng = RandomNumberGenerator.new()
	x_pos = rng.randi_range(-1000, 1000)
	y_pos = rng.randi_range(-600, 600)

	self.position = Vector2(x_pos, y_pos)
