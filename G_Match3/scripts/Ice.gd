extends Node2D

export var health: int


func take_damage(damage):
	health -= damage
