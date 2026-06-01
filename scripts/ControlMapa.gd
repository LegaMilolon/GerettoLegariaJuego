extends Node2D

var velocidad_zoom = 0.12
var zoom_max = Vector2(4.0, 4.0)

var esta_arrastrando = false
var mouse_anterior = Vector2.ZERO

var ancho_imagen = 5652.0
var alto_imagen  = 3682.0

var norte_propagacion_interna = 0.05
var norte_propagacion_externa = 0.04
var norte_poblacion = 4000000
var norte_exportacion = 0.04

var islas_hierro_propagacion_interna = 0.09
var islas_hierro_propagacion_externa = 0.05
var islas_hierro_poblacion = 500000
var islas_hierro_exportacion = 0.07

var tierras_rios_propagacion_interna = 0.11
var tierras_rios_propagacion_externa = 0.17
var tierras_rios_poblacion = 4000000

var valle_propagacion_interna = 0.06
var valle_propagacion_externa = 0.03
var valle_poblacion = 3000000
var valle_exportacion = 0.05

var tierras_oeste_propagacion_interna = 0.13
var tierras_oeste_propagacion_externa = 0.11
var tierras_oeste_poblacion = 4000000
var tierras_oeste_exportacion = 0.10

var tierras_corona_propagacion_interna = 0.22
var tierras_corona_propagacion_externa = 0.19
var tierras_corona_poblacion = 3500000
var tierras_corona_exportacion = 0.16

var dominio_propagacion_interna = 0.16
var dominio_propagacion_externa = 0.14
var dominio_poblacion = 12000000
var dominio_exportacion = 0.14

var tierras_tormenta_propagacion_interna = 0.08
var tierras_tormenta_propagacion_externa = 0.08
var tierras_tormenta_poblacion = 3000000
var tierras_tormenta_exportacion = 0.05

var dorne_propagacion_interna = 0.07
var dorne_propagacion_externa = 0.05
var dorne_poblacion = 2000000
var dorne_exportacion = 0.06

var mas_alla_muro_propagacion_interna = 0.03
var mas_alla_muro_propagacion_externa = 0.02
var mas_alla_muro_poblacion = 500000

var braavos_propagacion_interna = 0.19
var braavos_propagacion_externa = 0.09
var braavos_poblacion = 800000
var braavos_exportacion = 0.20

var pentos_propagacion_interna = 0.15
var pentos_propagacion_externa = 0.12
var pentos_poblacion = 600000
var pentos_exportacion = 0.12

var volantis_propagacion_interna = 0.21
var volantis_propagacion_externa = 0.15
var volantis_poblacion = 1000000
var volantis_exportacion = 0.15

var bahia_esclavos_propagacion_interna = 0.18
var bahia_esclavos_propagacion_externa = 0.10
var bahia_esclavos_poblacion = 2000000
var bahia_esclavos_exportacion = 0.11

var qarth_propagacion_interna = 0.14
var qarth_propagacion_externa = 0.06
var qarth_poblacion = 700000
var qarth_exportacion = 0.17

var mar_dothraki_propagacion_interna = 0.04
var mar_dothraki_propagacion_externa = 0.08
var mar_dothraki_poblacion = 2000000

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
