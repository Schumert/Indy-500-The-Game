extends Area2D
var x_pos:float
var y_pos:float
var overlapping_areas:Array[Area2D] = []

func _ready():
	visible = false
	set_its_location()
	
 

func _on_body_entered(body:Node2D):
	#if body.collision_layer & (1 << 1) != 0:
	#	set_its_location()
	queue_free()
	

func _on_area_entered(area:Node2D):
	if area.collision_layer == 1:
		#queue_free()
		pass



func set_its_location():
	var rng = RandomNumberGenerator.new()
	x_pos = rng.randi_range(-500, 500)
	y_pos = rng.randi_range(-500, 500)
	position = Vector2(x_pos, -y_pos)

	await get_tree().create_timer(0.05).timeout
	overlapping_areas = get_overlapping_areas()
	
	if overlapping_areas.size() != 0:
		queue_free()
	else:
		visible = true
