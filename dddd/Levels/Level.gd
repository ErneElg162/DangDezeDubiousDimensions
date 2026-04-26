extends Node3D

@onready var player: CharacterBody3D = $Player
@export var death_plane: float
@export var next_level: String
var home: Vector3

func _ready() -> void:
	home = player.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player.position.y <= death_plane:
		player.velocity = Vector3.ZERO
		player.position = home


func _on_end_entered(body: Node3D) -> void:
	get_tree().change_scene_to_file(next_level)
