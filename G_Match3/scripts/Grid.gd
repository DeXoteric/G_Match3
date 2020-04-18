extends Node2D

enum {WAIT, MOVE}
var state

export var width: int
export var height: int
export var x_start: int
export var y_start: int
export var offset: int
export var y_offset: int
export var empty_spaces: PoolVector2Array
export var ice_spaces: PoolVector2Array
export var lock_spaces: PoolVector2Array

var possible_pieces = [
preload("res://scenes/BluePiece.tscn"),
preload("res://scenes/GreenPiece.tscn"),
preload("res://scenes/LightGreenPiece.tscn"),
preload("res://scenes/OrangePiece.tscn"),
preload("res://scenes/PinkPiece.tscn"),
preload("res://scenes/YellowPiece.tscn")
]
var all_pieces := []
var first_touch: Vector2
var final_touch: Vector2
var controlling := false
var piece_one = null
var piece_two = null
var last_place := Vector2.ZERO
var last_direction := Vector2.ZERO
var move_checked = false

signal make_ice
signal damage_ice
signal make_lock
signal damage_lock


func _ready():
	state = MOVE
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()
	spawn_ice()
	spawn_locks()


func _process(delta):
	if state == MOVE:
		touch_input()


func restricted_fill(place):
	if is_in_array(empty_spaces, place):
		return true
	return false


func restricted_move(place):
	if is_in_array(lock_spaces, place):
		return true
	return false


func is_in_array(array, item):
	for i in array.size():
		if array[i] == item:
			return true
	return false


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
			if !restricted_fill(Vector2(i, j)):
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


func spawn_ice():
	for i in ice_spaces.size():
		emit_signal("make_ice", ice_spaces[i])


func spawn_locks():
	for i in lock_spaces.size():
		emit_signal("make_lock", lock_spaces[i])


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


func pixel_to_grid(pixel_x, pixel_y):
	var new_x = round((pixel_x - x_start) / offset)
	var new_y = round((pixel_y - y_start) / -offset)
	return Vector2(new_x, new_y)


func is_in_grid(grid_position):
	if grid_position.x >= 0 && grid_position.x < width:
		if grid_position.y >= 0 && grid_position.y < height:
			return true
	return false


func touch_input():
	if Input.is_action_just_pressed("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)):
			controlling = true
			first_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
	if Input.is_action_just_released("ui_touch"):
		if is_in_grid(pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)) && controlling:
			controlling = false
			final_touch = pixel_to_grid(get_global_mouse_position().x, get_global_mouse_position().y)
			touch_difference(first_touch, final_touch)


func swap_pieces(column, row, direction):
	var first_piece = all_pieces[column][row]
	var other_piece = all_pieces[column + direction.x][row + direction.y]
	if first_piece != null && other_piece != null:
		if !restricted_move(Vector2(column, row)) && !restricted_move(Vector2(column, row) + direction):
			store_info(first_piece, other_piece, Vector2(column, row), direction)
			state = WAIT
			all_pieces[column][row] = other_piece
			all_pieces[column + direction.x][row + direction.y] = first_piece
			first_piece.move(grid_to_pixel(column + direction.x, row + direction.y))
			other_piece.move(grid_to_pixel(column, row))
			if !move_checked:
				find_matches()


func store_info(first_piece, other_piece, place, direction):
	piece_one = first_piece
	piece_two = other_piece
	last_place = place
	last_direction = direction


func swap_back():
	if piece_one != null && piece_two != null:
		swap_pieces(last_place.x, last_place.y, last_direction)
	state = MOVE
	move_checked = false


func touch_difference(grid_1, grid_2):
	var difference = grid_2 - grid_1
	if abs(difference.x) > abs(difference.y):
		if difference.x > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2.RIGHT)
		elif difference.x < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2.LEFT)
	elif abs(difference.x) < abs(difference.y):
		if difference.y > 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2.DOWN)
		elif difference.y < 0:
			swap_pieces(grid_1.x, grid_1.y, Vector2.UP)


func find_matches():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				var current_color = all_pieces[i][j].color
				if i > 0 && i < width - 1:
					if !is_piece_null(i - 1, j) && !is_piece_null(i + 1, j):
						if all_pieces[i - 1][j].color == current_color && all_pieces[i + 1][j].color == current_color:
							match_and_dim(all_pieces[i - 1][j])
							match_and_dim(all_pieces[i][j])
							match_and_dim(all_pieces[i + 1][j])
				if j > 0 && j < height - 1:
					if !is_piece_null(i, j - 1) && !is_piece_null(i, j + 1):
						if all_pieces[i][j - 1].color == current_color && all_pieces[i][j + 1].color == current_color:
							match_and_dim(all_pieces[i][j - 1])
							match_and_dim(all_pieces[i][j])
							match_and_dim(all_pieces[i][j + 1])
	get_parent().get_node("DestroyTimer").start()


func is_piece_null(column, row):
	if all_pieces[column][row] == null:
		return true
	return false


func match_and_dim(item):
	item.matched = true
	item.dim()


func destroy_matched():
	var was_matched = false
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					damage_special(i, j)
					was_matched = true
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
	move_checked = true
	if was_matched:
		get_parent().get_node("CollapseTimer").start()
	else:
		swap_back()


func damage_special(column, row):
	emit_signal("damage_ice", Vector2(column, row))
	emit_signal("damage_lock", Vector2(column, row))


func collapse_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restricted_fill(Vector2(i, j)):
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j))
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	get_parent().get_node("RefillTimer").start()


func refill_columns():
	for i in width:
		for j in height:
			if all_pieces[i][j] == null && !restricted_fill(Vector2(i, j)):
				var rand = floor(rand_range(0, possible_pieces.size()))
				var piece = possible_pieces[rand].instance()
				var loops = 0
				while(match_at(i, j, piece.color) && loops < 100):
					rand = floor(rand_range(0, possible_pieces.size()))
					loops += 1
					piece = possible_pieces[rand].instance()
				add_child(piece)
				piece.position = grid_to_pixel(i, j + y_offset)
				piece.move(grid_to_pixel(i, j))
				all_pieces[i][j] = piece
	after_refill()


func after_refill():
	for i in width:
		for j in height:
			if all_pieces[i][j] != null:
				if match_at(i, j, all_pieces[i][j].color):
					find_matches()
					return
	state = MOVE
	move_checked = false


func _on_DestroyTimer_timeout():
	destroy_matched()


func _on_CollapseTimer_timeout():
	collapse_columns()


func _on_RefillTimer_timeout():
	refill_columns()


func _on_LockHolder_remove_lock(place):
	for i in range(lock_spaces.size() - 1, -1, -1):
		if lock_spaces[i] == place:
			lock_spaces.remove(i)

