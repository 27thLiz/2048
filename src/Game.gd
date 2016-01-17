
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

const DRAGTIME = 0.2

const MAX_UNDO_STEPS = 4
var TileClass = preload("res://tile.xml")

var grid = {}
var TileGrid = {}
var undoList = []
var GridNode
var global
var score = 0 setget setScore
var HighScore = 0 setget setHighScore
var dragUp = false
var dragDown = false
var dragLeft = false
var dragRight = false
var leftCounter = 0
var rightCounter = 0
var upCounter = 0
var downCounter = 0
var dontMove = false
var ScoreFile
var HighscoreNode

func initGrid():
	for x in range(4):
		for y in range(4):
			grid[Vector2(x,y)] = EMPTY
			TileGrid[Vector2(x,y)] = null

func addToUndoList():
	var newState = {}
	for key in grid.keys():
		if grid[key] != EMPTY:
			newState[key] = TileGrid[key].value
	undoList.push_back(newState)
	if (undoList.size() > MAX_UNDO_STEPS):
		undoList.remove(0)

func reconstructGamestate():
	if (undoList.size() > 1):
		for x in GridNode.get_children():
			x.queue_free()
		initGrid()
		var c = undoList.size()-2
		if (c > -1):
			for x in undoList[c].keys():
				spawnTile(false, x.x, x.y, undoList[c][x])
			undoList.remove(c)
			undoList.remove(c+1)

func setScore(val):
	get_node("HBoxContainer/ScoreVal").set_text(str(val))

func setHighScore(val):
	HighscoreNode.set_text(str(val))

func getRandomGridPos():
	var spawnX = int(rand_range(0,3.9))
	var spawnY = int(rand_range(0,3.9))
	return Vector2(spawnX, spawnY)


func spawnTile(var random = true, var x = 0, var y = 0, val = 2):
	var pos = Vector2()
	var value = 2
	var rnd = rand_range(0.0, 1.0)
	if (rnd > 0.9):
		value = 4
	var searchingPos = true
	if (random):
		while (searchingPos):
			randomize()
			pos = getRandomGridPos()
			if (grid[pos] == 0):
				searchingPos = false
	else:
		pos = Vector2(x, y)
		value = val
		
	var newTile = TileClass.instance()
	GridNode.add_child(newTile)
	newTile.pos = pos
	newTile.value = value
	newTile.get_node("anim").play("spawn")
	grid[pos] = TAKEN
	TileGrid[pos] = newTile

func move(direction):
	if (not dontMove):
		var offx = 1
		var offy = 1
		var startx = 0
		var starty = 0
		var endx = 4
		var endy = 4

		if (direction == RIGHT):
			startx = 3
			endx = -1
			offx = -1
		elif (direction == DOWN):
			starty = 3
			endy = -1
			offy = -1
		var didMove = false
		for x in range(startx, endx, offx):
			for y in range(starty, endy, offy):
				var checkPos = Vector2(x,y)
				print(checkPos)
				if (grid[checkPos] == TAKEN):
					TileGrid[checkPos].justUpdated = false
					if ( TileGrid[checkPos].checkMove(direction)):
						didMove = true
		if (didMove):
			spawnTile()
		addToUndoList()
		dontMove = true

func _input(event):
	dragDown = false
	dragLeft = false
	dragRight = false
	dragUp = false
	if (event.type == InputEvent.SCREEN_DRAG):
		if (abs(event.relative_x) > abs(event.relative_y)):
			if (event.relative_x > 0):
				dragRight = true
			elif (event.relative_x < 0):
				dragLeft = true
		elif (abs(event.relative_y) > abs(event.relative_x)):
			if (event.relative_y > 0):
				dragDown = true
			elif (event.relative_y < 0):
				dragUp = true
	elif ((event.type == InputEvent.SCREEN_TOUCH and not event.pressed) or (event.type == InputEvent.KEY and not event.pressed)):
		dontMove = false
	if (event.is_action("spawnTile") and not event.is_pressed()):
		spawnTile()
	elif (event.is_action("ui_left") and not event.is_pressed()):
		move(LEFT)
	elif (event.is_action("ui_right") and not event.is_pressed()):
		move(RIGHT)
	elif (event.is_action("ui_up") and not event.is_pressed()):
		move(UP)
	elif (event.is_action("ui_down") and not event.is_pressed()):
		move(DOWN)

func _process(delta):
	if (dragDown):
		downCounter += delta
	elif (dragUp):
		upCounter += delta
	elif (dragLeft):
		leftCounter += delta
	elif (dragRight):
		rightCounter += delta
	
	if (downCounter > DRAGTIME):
		move(DOWN)
		downCounter = 0
	elif (upCounter > DRAGTIME):
		move(UP)
		upCounter = 0
	elif (rightCounter > DRAGTIME):
		move(RIGHT)
		rightCounter = 0
	elif (leftCounter > DRAGTIME):
		move(LEFT)
		leftCounter = 0
	
	if (score > HighScore):
		HighScore = score
		setHighScore(HighScore)
		
	
func joy(index, connected):
	print("connection changed")

func _ready():
	# Initialization here
	set_process(true)
	set_process_input(true)
	GridNode = get_node("Grid/Tiles")
	HighscoreNode = get_node("HBoxContainer/HighscoreVal")
	initGrid()
	rand_seed(OS.get_time().hash())
	global = get_node("/root/global")
	ScoreFile = File.new()
	if (ScoreFile.file_exists("user://score")):
		print("exist")
		ScoreFile.open("user://score", ScoreFile.READ)
		HighScore = ScoreFile.get_64()
		print(HighScore)
		setHighScore(HighScore)
		ScoreFile.close()
	Input.connect("joy_connection_changed", self, "joy")
	
	print(ScoreFile.open("user://score", ScoreFile.WRITE))
	spawnTile()
	
func _exit_tree():
	ScoreFile.seek(0)
	ScoreFile.store_64(HighScore)
	ScoreFile.close()

func _on_Restart_released():
	get_tree().change_scene("res://Game.xml")

func _on_Undo_released():
	reconstructGamestate()


