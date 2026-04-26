extends Node3D

@onready var player: CharacterBody3D = $Player
@export var death_plane: float
var home: Vector3

func _ready() -> void:
	home = player.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.position.y <= death_plane:
		player.velocity = Vector3.ZERO
		player.position = home
