#
#  board.gd
#  XadrezNaval
#
#  Created by Vitor Venturin on 16/10/2026.
#  Copyright © 2026 Budget Thuis. All rights reserved.
#

class_name Board
extends Control

## Emitted when a square is clicked. `coord` is (file, rank), both 0..7,
## with (0, 0) = a1 at the bottom-left.
signal square_clicked(coord: Vector2i)

const SIZE := 8
const TILE := 32
const FILES := "ABCDEFGH"

## Top-left of the frame's 256x256 opening, in frame pixels.
const GRID_ORIGIN := Vector2(34, 39)

@export var light_texture: Texture2D
@export var dark_texture: Texture2D
@export var label_color := Color("f3dfa2")

@onready var _squares: Control = $Squares
@onready var _labels: Control = $Labels


func _ready() -> void:
	_squares.position = GRID_ORIGIN
	_squares.size = Vector2(SIZE * TILE, SIZE * TILE)
	_build_squares()
	_build_labels()


## Name of a square in chess notation, e.g. Vector2i(0, 0) -> "A1".
static func square_name(coord: Vector2i) -> String:
	return "%s%d" % [FILES[coord.x], coord.y + 1]


## Top-left of a square in this node's local space.
func square_position(coord: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2(coord.x, SIZE - 1 - coord.y) * TILE


func _build_squares() -> void:
	for rank in SIZE:
		for file in SIZE:
			var coord := Vector2i(file, rank)
			var square := TextureRect.new()
			square.name = square_name(coord)
			square.texture = light_texture if (file + rank) % 2 == 1 else dark_texture
			square.position = square_position(coord) - GRID_ORIGIN
			square.size = Vector2(TILE, TILE)
			square.gui_input.connect(_on_square_input.bind(coord))
			_squares.add_child(square)


func _build_labels() -> void:
	var bottom := GRID_ORIGIN.y + SIZE * TILE
	for i in SIZE:
		# Files A-H below the grid.
		_add_label(FILES[i], Rect2(GRID_ORIGIN.x + i * TILE, bottom, TILE, size.y - bottom))
		# Ranks 1-8 left of the grid, 1 at the bottom.
		_add_label(str(i + 1), Rect2(0, square_position(Vector2i(0, i)).y, GRID_ORIGIN.x, TILE))


func _add_label(text: String, rect: Rect2) -> void:
	var label := Label.new()
	label.text = text
	label.position = rect.position
	label.size = rect.size
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", label_color)
	label.add_theme_color_override("font_outline_color", Color("1b1419"))
	label.add_theme_constant_override("outline_size", 4)
	label.add_theme_font_size_override("font_size", 12)
	_labels.add_child(label)


func _on_square_input(event: InputEvent, coord: Vector2i) -> void:
	var click := event as InputEventMouseButton
	if click and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		square_clicked.emit(coord)
