
extends Node2D

# member variables here, example:
# var a=2
# var b="textvar"
const EMPTY = 0
const TAKEN = 1

const LEFT  = 0
const RIGHT = 1
const UP    = 2
const DOWN  = 3
const TILEOFFSET = 70


var values = {}
var undoList = []
var firstPos = Vector2(0,0)
var game
var grid
var tileGrid
var justUpdated = false
var value = 2 setget setValue
var pos = Vector2(0,0) setget setPos

var colors = {}


func setValue(val):
	get_node("Label").set_text(str(val))
	if colors.has(value):
		get_node("Sprite").set_modulate(colors[value])

func setPos(val):
	print("new Value: ", val)
	if (not val == null):
		set_pos(Vector2(firstPos.x + val.x * TILEOFFSET, firstPos.y + val.y * TILEOFFSET))
		var oi = values
		oi["test"] = 27
		print("values: ", values)
func checkMove(direction):
	var offset_x = 0
	var offset_y = 0
	if (direction == LEFT):
		offset_x = - 1
		if (pos.x == 0):
			return
	elif (direction == RIGHT):
		offset_x = 1
		if (pos.x == 3):
			return
	elif (direction == UP):
		offset_y = - 1
		if (pos.y == 0):
			return
	elif (direction == DOWN):
		offset_y = 1
		if (pos.y == 3):
			return
	var newPos = checkEmpty(pos, direction, offset_x, offset_y)
	var nextPos = Vector2(newPos.x + offset_x, newPos.y + offset_y)
	var didMove = false
	if (grid[newPos] == EMPTY):
		grid[pos] = EMPTY
		tileGrid[pos] = null
		pos = newPos
		setPos(newPos)
		grid[newPos] = TAKEN
		tileGrid[newPos] = self 
		didMove = true
	if not (nextPos.x < 0 or nextPos.x > 3 or nextPos.y < 0 or nextPos.y > 3) and grid[nextPos] != EMPTY:
		var nextTile = tileGrid[nextPos]
		if (nextTile.value == value and not nextTile.justUpdated):
			nextTile.value = value * 2
			nextTile.justUpdated = true
			nextTile.get_node("anim").play("changeValue")
			game.score += value * 2
			grid[pos] = EMPTY
			tileGrid[pos] = null
			queue_free()
			didMove = true
	if (didMove):
		return true
	else:
		return false

func isEmpty(pos):
	if (grid[pos] == EMPTY):
		return true
	else:
		return false

func checkEmpty(pos,direction, offsetx, offsety):
	var currentPos = pos
	var lastPos = pos
	var searching = true
	while (searching):
		var currentPos = Vector2(lastPos.x + offsetx, lastPos.y + offsety)
		if (currentPos.x < 0 or currentPos.x > 3 or currentPos.y < 0 or currentPos.y > 3 or grid[currentPos] != EMPTY):
			return lastPos
		#elif (grid[currentPos] != EMPTY):
			#return lastPos
		lastPos = currentPos

func _ready():
	# Initialization here 
	var root = get_tree().get_root()
	game = root.get_child(root.get_child_count() -1)
	grid = game.grid
	tileGrid = game.TileGrid
	firstPos = game.get_node("Grid").get_node("startpos").get_pos()
	colors[2] = Color(1,1,0.75)
	colors[4] = Color(1,1,0.5)
	colors[8] = Color(1, 189.0/255, 74.0/255)
	colors[16] = Color(250.0/255.0, 117.0/255, 22.0/255)
	colors[32] = Color(1, 56/255, 69/255)
	colors[64] = Color(1,0,0)
	colors[128] = Color(0, 0.35, 0)
	colors[256] = Color(0, 0.75, 0)