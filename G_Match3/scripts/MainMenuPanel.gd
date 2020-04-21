extends "res://scripts/BaseMenuPanel.gd"

signal play_pressed
signal settings_pressed


func _on_ButtonOne_pressed():
	emit_signal("play_pressed")

func _on_ButtonTwo_pressed():
	emit_signal("settings_pressed")
