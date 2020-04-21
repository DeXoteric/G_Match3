extends Control


func _ready():
	$MainMenuPanel.slide_in()

func _on_MainMenuPanel_settings_pressed():
	$MainMenuPanel.slide_out()
	$SettingsPanel.slide_in()

func _on_SettingsPanel_back_button():
	$MainMenuPanel.slide_in()
	$SettingsPanel.slide_out()

func _on_MainMenuPanel_play_pressed():
	get_tree().change_scene("res://scenes/levels/Level1.tscn")
