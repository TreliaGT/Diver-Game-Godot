extends Node2D
# The time interval in seconds between spawns
@export var spawn_interval: float = 2.0
@export var move_speed: float = 100.0
# The scene to instantiate
@export var moving_object_types: Array[MovingObjects]

@onready var environment = $Environment
@onready var end_game_ui = $EndGame
@onready var paused_game_ui = %Pause
@onready var start_game_ui = %Start
@onready var Player = $Player
@onready var coinlabel = %CoinLabel
@onready var tankSprite = %Tank
@onready var timerLabel = %TimerLabel
@onready var endstatus = %Status

var spawn_timer: Timer
var tank_timer : Timer
var tank : int = 10
var viewport_size: Vector2
var endgame: bool = false
var pausedgame: bool = true
var coins :int = 0
var elapsed_time: float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize the spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	tank_timer = Timer.new()
	
	# Configure Timer properties
	tank_timer.wait_time = 10.0
	tank_timer.one_shot = false
	
	# Connect the Timer's timeout signal to a function
	tank_timer.connect("timeout", _tank_on_timer_timeout)
	# Add Timer to the scene tree
	add_child(tank_timer)
	
	# Get viewport size
	viewport_size = get_viewport().size
	
	# Initialize label
	timerLabel.text = "0:00"

func _on_spawn_timer_timeout() -> void:
	# Spawn a new object
	var total_chance: float = 0.0
	for obj in moving_object_types:
		total_chance += obj.spawn_chance
	
	var random_chance: float = randf_range(0, total_chance)
	var accumulated_chance: float = 0.0
	for obj in moving_object_types:
		accumulated_chance += obj.spawn_chance
		if random_chance <= accumulated_chance:
			var moving_object = obj.scene.instantiate()
			environment.add_child(moving_object)
			if moving_object.has_signal("endgame"):
				moving_object.connect("endgame", _end_game)
			if moving_object.has_signal("coin"):
				moving_object.connect("coin", _get_coin)
			if moving_object.has_signal("bubble"):
				moving_object.connect("bubble", _get_bubble)
			break

func _process(delta: float) -> void:
	if not endgame && not pausedgame:
		#Timer
		elapsed_time += delta
		var minutes = int(elapsed_time / 60)
		var seconds = int(elapsed_time) % 60
		timerLabel.text = "%02d:%02d" % [minutes, seconds]
		# Iterate through all child nodes to move and check their positions
		for child in environment.get_children():
			if child is Node2D:
				child.position.y += move_speed * delta
				# Remove the object if it moves off the bottom of the screen
				if child.position.y > viewport_size.y:
					child.queue_free()
					
		if(Player.position.y > viewport_size.y):
			_end_game()

#Lets the tank run out of oxygen
func _tank_on_timer_timeout():
	tank -= 1
	tankSprite.frame = tank
	if(tank == 0):
		_end_game()

#fills the tank once player obtains a bubble
func _get_bubble() ->void:
	if(tank != 10):
		tank += 1
		tankSprite.frame = tank

#end the game
func _end_game() -> void:
	endgame = true
	spawn_timer.stop()
	tank_timer.stop()
	endstatus.text = "Time: %s \nCoins: %s" %  [timerLabel.text, str(coins)]
	end_game_ui.visible = true

#collects coins
func _get_coin() -> void:
	coins += 1
	coinlabel.text = "Coins: %s" % coins
	
#start again
func _on_start_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_resume_pressed() -> void:
	pausedgame = false
	spawn_timer.start()
	tank_timer.start()
	paused_game_ui.visible = false


func _on_paused_pressed() -> void:
	pausedgame = true
	spawn_timer.stop()
	tank_timer.stop()
	paused_game_ui.visible = true


func _on_start_pressed() -> void:
	pausedgame = false
	spawn_timer.start()
	tank_timer.start()
	start_game_ui.visible = false
