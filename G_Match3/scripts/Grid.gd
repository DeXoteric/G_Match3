extends Node2D

export var width: int
export var height: int
export var x_start: int
export var y_start: int
export var offset: int

var possible_pieces = [
preload("res://scenes/BluePiece.tscn"),
preload("res://scenes/GreenPiece.tscn"),
preload("res://scenes/LightGreenPiece.tscn"),
preload("res://scenes/OrangePiece.tscn"),
preload("res://scenes/PinkPiece.tscn"),
preload("res://scenes/YellowPiece.tscn")
]
var all_pieces := []


func _ready():
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func spawn_pieces():
	for i in width:
		for j in height:
			var rand = floor(rand_range(0, possible_pieces.size()))
			var piece = possible_pieces[rand].instance()
			var loops = 0
			while(match_at(i, j, piece.color) && loops < 100):
				rand = floor(rand_range(0, possible_pieces.size()))
				loops += 1
				piece = possible_pieces[rand].instance()
			add_child(piece)
			piece.position = grid_to_pixel(i, j)
			all_pieces[i][j] = piece


func match_at(i, j, color):
	if i > 1:
		if all_pieces[i - 1][j] != null && all_pieces[i - 2][j] != null:
			if all_pieces[i - 1][j].color == color && all_pieces[i - 2][j].color == color:
				return true
	if j > 1:
			if all_pieces[i][j - 1] != null && all_pieces[i][j - 2] != null:
				if all_pieces[i][j - 1].color == color && all_pieces[i][j - 2].color == color:
					return true


func grid_to_pixel(column, row):
	var new_x = x_start + offset * column
	var new_y = y_start - offset * row
	return Vector2(new_x, new_y)




