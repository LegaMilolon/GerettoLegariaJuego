extends Control


func _ready():
	$BotonReintentar.pressed.connect(_on_reintentar)
	$BotonSalir.pressed.connect(_on_salir)


func _on_reintentar():
	get_tree().change_scene_to_file("res://escenas/Mapa.tscn")


func _on_salir():
	get_tree().quit()
