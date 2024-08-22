extends Node2D


# The time interval in seconds between spawns
@export var spawn_interval: float = 2.0
@export var move_speed: float = 100.0
# The scene to instantiate
@export var moving_object_types: Array[MovingObjects]

@onready var environment = $Environment
@onready var end_game_ui = $EndGame
@onready var Player = $Player

var spawn_timer: Timer
var viewport_size: Vector2
var endgame: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize the spawn timer
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.one_shot = false
	spawn_timer.autostart = true
	spawn_timer.connect("timeout", _on_spawn_timer_timeout)
	add_child(spawn_timer)
	
	# Get viewport size
	viewport_size = get_viewport().size

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
			break

func _process(delta: float) -> void:
	if not endgame:
		# Iterate through all child nodes to move and check their positions
		for child in environment.get_children():
			if child is Node2D:
				child.position.y += move_speed * delta
				# Remove the object if it moves off the bottom of the screen
				if child.position.y > viewport_size.y:
					child.queue_free()
					
		if(Player.position.y > viewport_size.y):
			_end_game()

func _end_game() -> void:
	print("EndGame")
	endgame = true
	end_game_ui.visible = true

func _on_start_again_pressed() -> void:
	get_tree().reload_current_scene()
