extends RigidBody2D
class_name RageFace

signal rage_collision(rage_name:String, position:Vector2)
signal normal_collision

@export var ragename : String

var from_top : bool = false
var collided : bool = false
var normal_collided : bool = false


func _on_body_entered(body):
	if normal_collided == false and from_top == true:
		normal_collided = true
		emit_signal('normal_collision')
	#if body.is_in_group('jar'):
	#	emit_signal('normal_collision')
	if body.is_in_group(ragename):
		if collided == false:
			body.collided = true
			var new_point:Vector2
			new_point = Vector2((float(global_position.x + body.global_position.x) / 2), (float(global_position.y + body.global_position.y) / 2))
			#new_point.x = (float(global_position.x + body.global_position.x) / 2)
			#new_point.y = (float(global_position.y + body.global_position.y) / 2)
			body.queue_free()
			queue_free()
			emit_signal('rage_collision', ragename, new_point)
