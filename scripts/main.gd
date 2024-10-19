extends Node

#game variables
const REAPER_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var score : int
var speed : float
const START_SPEED : float = 2.0
const MAX_SPEED : int = 25
var screen_size : Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	new_game()

func new_game():
	score = 0
	$Reaper.position = REAPER_START_POS
	$Reaper.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0,552)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	speed = START_SPEED
	
	#move Reaper and camera
	$Reaper.position.x += speed
	$Camera2D.position.x += speed
	
	#update score based on movement
	score += speed
	print(score)
	#update ground position (so it keeps repeating)
	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x 
