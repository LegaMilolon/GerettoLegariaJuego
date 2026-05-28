extends Node2D

var velocidad_zoom = 0.12
var zoom_max = Vector2(4.0, 4.0)

var esta_arrastrando = false
var mouse_anterior = Vector2.ZERO

var ancho_imagen = 5652.0
var alto_imagen  = 3682.0

@onready var camara = $Camara
@onready var sprite_mapa = $Mapa


func _ready():
	var tam_vp = get_viewport().get_visible_rect().size
	var zoom_fit_x = tam_vp.x / ancho_imagen
	var zoom_fit_y = tam_vp.y / alto_imagen
	var zoom_base  = min(zoom_fit_x, zoom_fit_y)
	camara.zoom = Vector2(zoom_base, zoom_base)
	camara.position = Vector2(ancho_imagen / 2.0, alto_imagen / 2.0)


func _input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_WHEEL_UP and ev.pressed:
			var nuevo = camara.zoom + Vector2(velocidad_zoom, velocidad_zoom)
			camara.zoom = nuevo.clamp(Vector2(0.01, 0.01), zoom_max)
			_limitar()

		elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN and ev.pressed:
			var tam_vp = get_viewport().get_visible_rect().size
			var zoom_min_x = tam_vp.x / ancho_imagen
			var zoom_min_y = tam_vp.y / alto_imagen
			var zoom_min   = Vector2(min(zoom_min_x, zoom_min_y), min(zoom_min_x, zoom_min_y))
			var nuevo = camara.zoom - Vector2(velocidad_zoom, velocidad_zoom)
			camara.zoom = nuevo.clamp(zoom_min, zoom_max)
			_limitar()

		elif ev.button_index == MOUSE_BUTTON_LEFT:
			esta_arrastrando = ev.pressed
			mouse_anterior   = ev.position

	if ev is InputEventMouseMotion and esta_arrastrando:
		var delta_mouse = ev.position - mouse_anterior
		camara.position -= delta_mouse / camara.zoom
		mouse_anterior = ev.position
		_limitar()


func _limitar():
	var tam_vp   = get_viewport().get_visible_rect().size
	var mitad_vp = tam_vp / 2.0 / camara.zoom

	var x_min = mitad_vp.x
	var x_max = ancho_imagen - mitad_vp.x
	var y_min = mitad_vp.y
	var y_max = alto_imagen - mitad_vp.y

	if x_min >= x_max:
		camara.position.x = ancho_imagen / 2.0
	else:
		camara.position.x = clamp(camara.position.x, x_min, x_max)

	if y_min >= y_max:
		camara.position.y = alto_imagen / 2.0
	else:
		camara.position.y = clamp(camara.position.y, y_min, y_max)
