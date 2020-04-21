extends "res://scripts/BaseMenuPanel.gd"

signal sound_change
signal back_button


func _on_ButtonOne_pressed():
	emit_signal("sound_change")

func _on_ButtonTwo_pressed():
	emit_signal("back_button")
