extends Area2D

var speed = 800
var angular_Speed = PI / 1.5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation += angular_Speed * delta
	var velocity = speed * Vector2.UP.rotated(rotation)
	position += velocity * delta
