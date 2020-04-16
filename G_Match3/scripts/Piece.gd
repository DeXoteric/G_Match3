extends Node2D

export var color: String

var matched := false

onready var move_tween = $MoveTween


func move(target):
	move_tween.interpolate_property(self, "position", position, target, 0.3, Tween.TRANS_SINE, Tween.EASE_OUT)
	move_tween.start()


func dim():
	var sprite = get_node("Sprite")
	sprite.modulate = Color(1, 1, 1, 0.5)



