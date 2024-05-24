extends Area2D
var x_pos:float
var y_pos:float
var overlapping_areas:Array[Area2D] = []

func _ready():
	visible = false
	set_its_location()
	
 

func _on_body_entered(body:Node2D):
	if body.collision_layer & (1 << 1) != 0 or body.collision_layer & (1<<4) != 0 or body.collision_layer & (1 << 7) != 0:
		body.collect_coin()
	Global.coins.erase(self)
	queue_free()

	



func set_its_location():
	var rng = RandomNumberGenerator.new()
	x_pos = rng.randi_range(300, 1660) #300, 1660 / 600, 1300 - left is normal, right is test
	y_pos = rng.randi_range(100, 1000) #100, 1000 / 400, 600 - left is normal, right is test
	position = Vector2(x_pos, y_pos)

	await get_tree().create_timer(0.05).timeout
	overlapping_areas = get_overlapping_areas()
	
	if overlapping_areas.size() != 0:
		queue_free()
	else:
		visible = true
