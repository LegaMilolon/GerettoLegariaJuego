extends Control


func _ready():
	$Boton.pressed.connect(_on_boton_jugar)


func _on_boton_jugar():
	get_tree().change_scene_to_file("res://escenas/Mapa.tscn")
