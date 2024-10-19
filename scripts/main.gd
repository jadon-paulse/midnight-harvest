extends Node

#preload obstacles
var barrel_scene = preload("res://scenes/obstacles/barrel.tscn")
var rock_scene = preload("res://scenes/obstacles/rock.tscn")
var stump_scene = preload("res://scenes/obstacles/stump.tscn")
var flying_demon_scene = preload("res://scenes/characters_enemies/flying_demon.tscn")
var obstacle_types := [stump_scene, barrel_scene, rock_scene]
var obstacles : Array
var flying_demon_spawn_height := [200, 390]

#game variables
const REAPER_START_POS := Vector2i(150, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 2 
var score : int
const SCORE_MODIFIER : int = 10
var speed : float
const START_SPEED : float = 7.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 5000
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	#manual because ground is a tilemaplayer
	ground_height = 65
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()
	

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	
	#delete all obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#reset the nodes
	$Reaper.position = REAPER_START_POS
	$Reaper.velocity = Vector2i(0,0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0,552)
	
	#reset hud and game over screen
	$HUD.get_node("Start Label").show()
	$GameOver.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
			
		#generate obstacles
		generate_obs()
	
		#move Reaper and camera
		$Reaper.position.x += speed
		$Camera2D.position.x += speed
	
		#update score based on movement
		score += speed
		show_score()
	 
		#update ground position (so it keeps repeating)
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x 
		
		#clean up obs from memory
		for obs in obstacles: 
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)

	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("Start Label").hide()

func generate_obs():
	#generate ground obs
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y/2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		#spawn bird
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = flying_demon_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = flying_demon_spawn_height[randi() % flying_demon_spawn_height.size()]
				add_obs(obs, obs_x, obs_y)
				

		
func add_obs(obs, x,  y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect((hit_obs))
	add_child(obs)
	obstacles.append(obs)
	
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func hit_obs(body):
	print(body)
	if body.name == "Reaper":
		game_over()
	
func show_score():
	$HUD.get_node("Score Label").text = "SCORE: " + str(score / SCORE_MODIFIER)
	
func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
		
func game_over():
	get_tree().paused = true
	game_running = false
	$GameOver.show()
