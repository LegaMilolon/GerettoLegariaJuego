extends Node2D

var velocidad_zoom = 0.12
var zoom_max = Vector2(3.0, 3.0)
var zoom_min_val = Vector2(0.3, 0.3)

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

var infectados = {}
var acumulador = {}
var zona_activa = {}
var fotogramas = 0
var intervalo = 30
var color_hover = Color(1, 1, 1, 0.25)
var color_infectada = Color(0.7, 0, 0, 0.3)
var color_nada = Color(0, 0, 0, 0)

@onready var camara = $Camara
@onready var sprite_mapa = $Mapa


func _ready():
	get_viewport().physics_object_picking = true
	var tam_vp = get_viewport().get_visible_rect().size
	var zoom_fit_x = tam_vp.x / ancho_imagen
	var zoom_fit_y = tam_vp.y / alto_imagen
	var zoom_base  = max(zoom_fit_x, zoom_fit_y)
	zoom_min_val = Vector2(zoom_base, zoom_base)
	camara.zoom = zoom_min_val
	camara.position = Vector2(ancho_imagen / 2.0, alto_imagen / 2.0)
	for zona in $Zonas.get_children():
		infectados[zona.name] = 0
		acumulador[zona.name] = 0.0
		zona_activa[zona.name] = false
		zona.input_event.connect(_on_zona_click.bind(zona.name))
		zona.mouse_entered.connect(_on_zona_hover.bind(zona.name))
		zona.mouse_exited.connect(_on_zona_salir.bind(zona.name))
		var poligono_col = zona.get_node("Poligono")
		var poligono_vis = Polygon2D.new()
		poligono_vis.name = "Visual"
		poligono_vis.polygon = poligono_col.polygon
		poligono_vis.position = poligono_col.position
		poligono_vis.scale = poligono_col.scale
		poligono_vis.color = color_nada
		zona.add_child(poligono_vis)


func _input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == MOUSE_BUTTON_WHEEL_UP and ev.pressed:
			var nuevo = camara.zoom + Vector2(velocidad_zoom, velocidad_zoom)
			camara.zoom = nuevo.clamp(zoom_min_val, zoom_max)
			_limitar()

		elif ev.button_index == MOUSE_BUTTON_WHEEL_DOWN and ev.pressed:
			var nuevo = camara.zoom - Vector2(velocidad_zoom, velocidad_zoom)
			camara.zoom = nuevo.clamp(zoom_min_val, zoom_max)
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


func _process(_delta):
	fotogramas += 1
	if fotogramas < intervalo:
		return
	fotogramas = 0
	for nombre in zona_activa.keys():
		if zona_activa[nombre] == false:
			continue
		if infectados[nombre] <= 0:
			continue
		var prop = _obtener_propagacion(nombre)
		var poblacion = _obtener_poblacion(nombre)
		if infectados[nombre] >= poblacion:
			continue
		acumulador[nombre] += infectados[nombre] * prop * 100.0
		if acumulador[nombre] >= 100.0:
			var nuevos = int(acumulador[nombre] / 100.0)
			acumulador[nombre] -= nuevos * 100.0
			infectados[nombre] += nuevos
			if infectados[nombre] > poblacion:
				infectados[nombre] = poblacion


func _on_zona_click(_viewport, evento, _shape_idx, nombre):
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		if zona_activa[nombre] == false:
			zona_activa[nombre] = true
			infectados[nombre] = 1
			var zona = $Zonas.get_node(NodePath(nombre))
			zona.get_node("Visual").color = color_infectada


func _on_zona_hover(nombre):
	var zona = $Zonas.get_node(NodePath(nombre))
	if zona_activa[nombre] == true:
		return
	zona.get_node("Visual").color = color_hover


func _on_zona_salir(nombre):
	var zona = $Zonas.get_node(NodePath(nombre))
	if zona_activa[nombre] == true:
		return
	zona.get_node("Visual").color = color_nada


func _obtener_propagacion(nombre):
	match nombre:
		"mas_alla_muro": return mas_alla_muro_propagacion_interna
		"norte": return norte_propagacion_interna
		"islas_hierro": return islas_hierro_propagacion_interna
		"tierras_rios": return tierras_rios_propagacion_interna
		"valle": return valle_propagacion_interna
		"tierras_oeste": return tierras_oeste_propagacion_interna
		"tierras_corona": return tierras_corona_propagacion_interna
		"dominio": return dominio_propagacion_interna
		"tierras_tormenta": return tierras_tormenta_propagacion_interna
		"dorne": return dorne_propagacion_interna
		"braavos": return braavos_propagacion_interna
		"pentos": return pentos_propagacion_interna
		"mar_dothraki": return mar_dothraki_propagacion_interna
		"volantis": return volantis_propagacion_interna
		"bahia_esclavos": return bahia_esclavos_propagacion_interna
		"qarth": return qarth_propagacion_interna
	return 0.0


func _obtener_poblacion(nombre):
	match nombre:
		"mas_alla_muro": return mas_alla_muro_poblacion
		"norte": return norte_poblacion
		"islas_hierro": return islas_hierro_poblacion
		"tierras_rios": return tierras_rios_poblacion
		"valle": return valle_poblacion
		"tierras_oeste": return tierras_oeste_poblacion
		"tierras_corona": return tierras_corona_poblacion
		"dominio": return dominio_poblacion
		"tierras_tormenta": return tierras_tormenta_poblacion
		"dorne": return dorne_poblacion
		"braavos": return braavos_poblacion
		"pentos": return pentos_poblacion
		"mar_dothraki": return mar_dothraki_poblacion
		"volantis": return volantis_poblacion
		"bahia_esclavos": return bahia_esclavos_poblacion
		"qarth": return qarth_poblacion
	return 1
