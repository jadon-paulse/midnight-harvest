extends Node

#game variables
const REAPER_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var score : int
const SCORE_MODIFIER : int = 10
var speed : float
const START_SPEED : float = 5.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 1000
var screen_size : Vector2i
var game_running : bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	new_game()
	

func new_game():
	score = 0
	show_score()
	game_running = false
	
	#reset the nodes
	$Reaper.position = REAPER_START_POS
	$Reaper.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0,552)
	
	#reset hud
	$HUD.get_node("Start Label").show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
			print(speed)
		print(speed)	
		#move Reaper and camera
		$Reaper.position.x += speed
		$Camera2D.position.x += speed
	
		#update score based on movement
		score += speed
		show_score()
	
	#update ground position (so it keeps repeating)
	if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
		$Ground.position.x += screen_size.x 
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("Start Label").hide()
		
func show_score():
	$HUD.get_node("Score Label").text = "SCORE: " + str(score / SCORE_MODIFIER)
