extends Node2D

var velocidad_zoom = 0.12
var zoom_max = Vector2(3.0, 3.0)
var zoom_min_val = Vector2(0.3, 0.3)

var esta_arrastrando = false
var mouse_anterior = Vector2.ZERO

var ancho_imagen = 5652.0
var alto_imagen  = 3682.0

var norte_propagacion_interna = 40.0
var norte_propagacion_externa = 0.03
var norte_poblacion = 4000000
var norte_exportacion = 0.02

var islas_hierro_propagacion_interna = 35.0
var islas_hierro_propagacion_externa = 0.03
var islas_hierro_poblacion = 500000
var islas_hierro_exportacion = 0.02

var tierras_rios_propagacion_interna = 28.0
var tierras_rios_propagacion_externa = 0.04
var tierras_rios_poblacion = 4000000

var valle_propagacion_interna = 32.0
var valle_propagacion_externa = 0.03
var valle_poblacion = 3000000
var valle_exportacion = 0.02

var tierras_oeste_propagacion_interna = 28.0
var tierras_oeste_propagacion_externa = 0.04
var tierras_oeste_poblacion = 4000000
var tierras_oeste_exportacion = 0.03

var tierras_corona_propagacion_interna = 25.0
var tierras_corona_propagacion_externa = 0.05
var tierras_corona_poblacion = 3500000
var tierras_corona_exportacion = 0.04

var dominio_propagacion_interna = 35.0
var dominio_propagacion_externa = 0.04
var dominio_poblacion = 12000000
var dominio_exportacion = 0.03

var tierras_tormenta_propagacion_interna = 30.0
var tierras_tormenta_propagacion_externa = 0.04
var tierras_tormenta_poblacion = 3000000
var tierras_tormenta_exportacion = 0.03

var dorne_propagacion_interna = 25.0
var dorne_propagacion_externa = 0.05
var dorne_poblacion = 2000000
var dorne_exportacion = 0.04

var mas_alla_muro_propagacion_interna = 45.0
var mas_alla_muro_propagacion_externa = 0.02
var mas_alla_muro_poblacion = 500000

var braavos_propagacion_interna = 30.0
var braavos_propagacion_externa = 0.04
var braavos_poblacion = 800000
var braavos_exportacion = 0.03

var pentos_propagacion_interna = 28.0
var pentos_propagacion_externa = 0.04
var pentos_poblacion = 600000
var pentos_exportacion = 0.03

var volantis_propagacion_interna = 30.0
var volantis_propagacion_externa = 0.04
var volantis_poblacion = 1000000
var volantis_exportacion = 0.03

var bahia_esclavos_propagacion_interna = 25.0
var bahia_esclavos_propagacion_externa = 0.05
var bahia_esclavos_poblacion = 2000000
var bahia_esclavos_exportacion = 0.04

var qarth_propagacion_interna = 40.0
var qarth_propagacion_externa = 0.02
var qarth_poblacion = 700000
var qarth_exportacion = 0.02

var mar_dothraki_propagacion_interna = 40.0
var mar_dothraki_propagacion_externa = 0.02
var mar_dothraki_poblacion = 2000000

var infectados = {}
var acumulador = {}
var acumulador_externo = {}
var zona_activa = {}
var tiempo_acumulado = 0.0
var intervalo_tiempo = 0.5
var juego_iniciado = false
var color_hover = Color(1, 1, 1, 0.25)
var color_nada = Color(0, 0, 0, 0)
var color_pendiente = Color(1, 1, 1, 0.5)
var zona_pendiente = {}

var habilidad_frio = false
var habilidad_calor = false
var habilidad_mutacion = false
var puntos_infeccion = 0
var infectados_contados = 0
var costo_habilidad = 15000000

var zonas_frias = ["mas_alla_muro", "norte", "islas_hierro", "braavos", "valle"]
var zonas_calientes = ["dorne", "bahia_esclavos", "volantis", "qarth", "mar_dothraki"]

var vecinos = {
	"mas_alla_muro": ["norte"],
	"norte": ["mas_alla_muro", "tierras_rios", "islas_hierro"],
	"islas_hierro": ["norte", "tierras_rios", "tierras_oeste"],
	"tierras_rios": ["norte", "islas_hierro", "valle", "tierras_oeste", "tierras_corona"],
	"valle": ["tierras_rios", "tierras_corona"],
	"tierras_oeste": ["islas_hierro", "tierras_rios", "tierras_corona", "dominio"],
	"tierras_corona": ["tierras_rios", "valle", "tierras_oeste", "dominio", "tierras_tormenta", "braavos"],
	"dominio": ["tierras_oeste", "tierras_corona", "tierras_tormenta", "dorne"],
	"tierras_tormenta": ["tierras_corona", "dominio", "dorne"],
	"dorne": ["dominio", "tierras_tormenta", "pentos"],
	"braavos": ["tierras_corona", "pentos", "mar_dothraki"],
	"pentos": ["dorne", "braavos", "mar_dothraki", "volantis"],
	"mar_dothraki": ["braavos", "pentos", "volantis", "bahia_esclavos"],
	"volantis": ["pentos", "mar_dothraki", "bahia_esclavos"],
	"bahia_esclavos": ["mar_dothraki", "volantis", "qarth"],
	"qarth": ["bahia_esclavos"]
}

@onready var camara = $Camara
@onready var sprite_mapa = $Mapa
@onready var contador = $UI/Contador
@onready var notificacion = $UI/Notificacion
@onready var label_timer = $UI/Timer

var timer_notificacion = 0.0
var tiempo_restante = 300.0
var pulso = 0.0


func _ready():
	get_viewport().physics_object_picking = true
	var tam_vp = get_viewport().get_visible_rect().size
	var zoom_fit_x = tam_vp.x / ancho_imagen
	var zoom_fit_y = tam_vp.y / alto_imagen
	var zoom_base  = max(zoom_fit_x, zoom_fit_y)
	zoom_min_val = Vector2(zoom_base, zoom_base)
	camara.zoom = zoom_min_val
	camara.position = Vector2(ancho_imagen / 2.0, alto_imagen / 2.0)
	$UI/PanelHabilidades/VBox/BotonFrio.pressed.connect(_on_boton_frio)
	$UI/PanelHabilidades/VBox/BotonCalor.pressed.connect(_on_boton_calor)
	$UI/PanelHabilidades/VBox/BotonMutacion.pressed.connect(_on_boton_mutacion)
	$UI/PanelHabilidades/VBox/BotonFrio.disabled = true
	$UI/PanelHabilidades/VBox/BotonCalor.disabled = true
	$UI/PanelHabilidades/VBox/BotonMutacion.disabled = true
	for zona in $Zonas.get_children():
		infectados[zona.name] = 0
		acumulador[zona.name] = 0.0
		acumulador_externo[zona.name] = 0.0
		zona_activa[zona.name] = false
		zona_pendiente[zona.name] = false
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
		var borde = Line2D.new()
		borde.name = "Borde"
		var puntos = poligono_col.polygon
		var puntos_cerrado = PackedVector2Array()
		for p in puntos:
			puntos_cerrado.append(p)
		puntos_cerrado.append(puntos[0])
		borde.points = puntos_cerrado
		borde.position = poligono_col.position
		borde.scale = poligono_col.scale
		borde.width = 6.0
		borde.default_color = Color(0, 0, 0, 0)
		borde.antialiased = true
		zona.add_child(borde)


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
	if timer_notificacion > 0.0:
		timer_notificacion -= _delta
		if timer_notificacion <= 0.0:
			notificacion.text = ""
		else:
			notificacion.modulate.a = clamp(timer_notificacion / 2.0, 0.0, 1.0)
	if juego_iniciado == true:
		tiempo_restante -= _delta
		var minutos = int(tiempo_restante) / 60
		var segundos = int(tiempo_restante) % 60
		label_timer.text = str(minutos) + ":" + str(segundos).pad_zeros(2)
		if tiempo_restante <= 30.0:
			label_timer.add_theme_color_override("font_color", Color(1, 0.2, 0.2, 1))
		else:
			label_timer.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		if tiempo_restante <= 0.0:
			get_tree().change_scene_to_file("res://escenas/Derrota.tscn")
			return
	pulso += _delta * 3.0
	for nombre in zona_activa.keys():
		if zona_activa[nombre] == false:
			continue
		var poblacion_vis = _obtener_poblacion(nombre)
		var porcentaje_vis = float(infectados[nombre]) / float(poblacion_vis)
		var zona_v = $Zonas.get_node(NodePath(nombre))
		var vis = zona_v.get_node("Visual")
		var brillo = 0.6 + sin(pulso) * 0.1
		vis.color = Color(brillo, 0, 0, porcentaje_vis * 0.7)
		var borde = zona_v.get_node("Borde")
		var brillo_borde = 0.8 + sin(pulso * 1.5) * 0.2
		borde.default_color = Color(brillo_borde, 0.1, 0.1, porcentaje_vis * 0.9)
		borde.width = 4.0 + porcentaje_vis * 4.0
	tiempo_acumulado += _delta
	if tiempo_acumulado < intervalo_tiempo:
		return
	tiempo_acumulado = 0.0
	for nombre in zona_activa.keys():
		if zona_activa[nombre] == false:
			continue
		if infectados[nombre] <= 0:
			continue
		var prop = _obtener_propagacion(nombre)
		var poblacion = _obtener_poblacion(nombre)
		if infectados[nombre] < poblacion:
			var mult_mut = 1.0
			if habilidad_mutacion:
				mult_mut = 1.5
			var ticks_para_llenar = prop / intervalo_tiempo / mult_mut
			var nuevos = int(poblacion / ticks_para_llenar)
			if nuevos < 1:
				nuevos = 1
			infectados[nombre] += nuevos
			if infectados[nombre] > poblacion:
				infectados[nombre] = poblacion
		var prop_ext = _obtener_propagacion_externa(nombre)
		var porcentaje_actual = float(infectados[nombre]) / float(poblacion)
		if porcentaje_actual < 0.2:
			continue
		var chance = (porcentaje_actual - 0.2) / 0.8 * prop_ext
		if porcentaje_actual >= 0.8:
			chance = prop_ext * 3.0
		var mult_ext = 1.0
		if nombre in zonas_frias and habilidad_frio:
			mult_ext = 3.0
		if nombre in zonas_calientes and habilidad_calor:
			mult_ext = 3.0
		if habilidad_mutacion:
			mult_ext *= 2.0
		chance *= mult_ext
		for vecino in vecinos[nombre]:
			if zona_activa[vecino] == true:
				continue
			if zona_pendiente[vecino] == true:
				continue
			if vecino in zonas_frias and not habilidad_frio:
				continue
			if vecino in zonas_calientes and not habilidad_calor:
				continue
			var mult_vecino = 1.0
			if vecino in zonas_frias and habilidad_frio:
				mult_vecino = 3.0
			if vecino in zonas_calientes and habilidad_calor:
				mult_vecino = 3.0
			var chance_final = chance * mult_vecino
			if randf() < chance_final:
				zona_pendiente[vecino] = true
				infectados[vecino] = 1
				var zona_vis = $Zonas.get_node(NodePath(vecino))
				zona_vis.get_node("Visual").color = color_pendiente
				_mostrar_notificacion(vecino)
	var total_infectados = 0
	var total_poblacion = 0
	for nombre in infectados.keys():
		total_infectados += infectados[nombre]
		total_poblacion += _obtener_poblacion(nombre)
	var nuevos_puntos = total_infectados - infectados_contados
	if nuevos_puntos > 0:
		puntos_infeccion += nuevos_puntos
		infectados_contados = total_infectados
	contador.text = "Infectados: " + str(total_infectados) + " / " + str(total_poblacion) + "  |  Puntos: " + str(puntos_infeccion)
	_actualizar_botones()
	if total_infectados >= total_poblacion:
		get_tree().change_scene_to_file("res://escenas/Victoria.tscn")


func _on_zona_click(_viewport, evento, _shape_idx, nombre):
	if evento is InputEventMouseButton and evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
		if zona_pendiente[nombre] == true:
			zona_pendiente[nombre] = false
			zona_activa[nombre] = true
			var zona = $Zonas.get_node(NodePath(nombre))
			zona.get_node("Visual").color = Color(0.7, 0, 0, 0.01)
			return
		if juego_iniciado == true:
			return
		if zona_activa[nombre] == false:
			juego_iniciado = true
			zona_activa[nombre] = true
			infectados[nombre] = 1
			var zona = $Zonas.get_node(NodePath(nombre))
			zona.get_node("Visual").color = Color(0.7, 0, 0, 0.01)


func _on_zona_hover(nombre):
	if juego_iniciado == true:
		if zona_activa[nombre] == true:
			var poblacion = _obtener_poblacion(nombre)
			var porcentaje = float(infectados[nombre]) / float(poblacion) * 100.0
			var bonito = nombres_bonitos[nombre]
			$UI/Tooltip.text = bonito + ": " + str(int(porcentaje)) + "%"
			$UI/Tooltip.visible = true
		return
	var zona = $Zonas.get_node(NodePath(nombre))
	if zona_activa[nombre] == true:
		return
	zona.get_node("Visual").color = color_hover


func _on_zona_salir(nombre):
	if juego_iniciado == true:
		$UI/Tooltip.visible = false
		return
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


func _obtener_propagacion_externa(nombre):
	match nombre:
		"mas_alla_muro": return mas_alla_muro_propagacion_externa
		"norte": return norte_propagacion_externa
		"islas_hierro": return islas_hierro_propagacion_externa
		"tierras_rios": return tierras_rios_propagacion_externa
		"valle": return valle_propagacion_externa
		"tierras_oeste": return tierras_oeste_propagacion_externa
		"tierras_corona": return tierras_corona_propagacion_externa
		"dominio": return dominio_propagacion_externa
		"tierras_tormenta": return tierras_tormenta_propagacion_externa
		"dorne": return dorne_propagacion_externa
		"braavos": return braavos_propagacion_externa
		"pentos": return pentos_propagacion_externa
		"mar_dothraki": return mar_dothraki_propagacion_externa
		"volantis": return volantis_propagacion_externa
		"bahia_esclavos": return bahia_esclavos_propagacion_externa
		"qarth": return qarth_propagacion_externa
	return 0.0


func _obtener_exportacion(nombre):
	match nombre:
		"norte": return norte_exportacion
		"islas_hierro": return islas_hierro_exportacion
		"valle": return valle_exportacion
		"tierras_oeste": return tierras_oeste_exportacion
		"tierras_corona": return tierras_corona_exportacion
		"dominio": return dominio_exportacion
		"tierras_tormenta": return tierras_tormenta_exportacion
		"dorne": return dorne_exportacion
		"braavos": return braavos_exportacion
		"pentos": return pentos_exportacion
		"volantis": return volantis_exportacion
		"bahia_esclavos": return bahia_esclavos_exportacion
		"qarth": return qarth_exportacion
	return 0.0


var nombres_bonitos = {
	"mas_alla_muro": "Mas alla del Muro",
	"norte": "El Norte",
	"islas_hierro": "Islas del Hierro",
	"tierras_rios": "Tierras de los Rios",
	"valle": "El Valle",
	"tierras_oeste": "Tierras del Oeste",
	"tierras_corona": "Tierras de la Corona",
	"dominio": "El Dominio",
	"tierras_tormenta": "Tierras de la Tormenta",
	"dorne": "Dorne",
	"braavos": "Braavos",
	"pentos": "Pentos",
	"mar_dothraki": "Mar Dothraki",
	"volantis": "Volantis",
	"bahia_esclavos": "Bahia de los Esclavos",
	"qarth": "Qarth"
}


func _mostrar_notificacion(nombre):
	var bonito = nombres_bonitos[nombre]
	notificacion.text = bonito + " ha sido infectada!"
	notificacion.modulate.a = 1.0
	timer_notificacion = 3.0


func _on_boton_frio():
	if puntos_infeccion < costo_habilidad:
		return
	puntos_infeccion -= costo_habilidad
	habilidad_frio = true
	$UI/PanelHabilidades/VBox/BotonFrio.disabled = true
	$UI/PanelHabilidades/VBox/BotonFrio.text = "Frio [ACTIVO]"


func _on_boton_calor():
	if puntos_infeccion < costo_habilidad:
		return
	puntos_infeccion -= costo_habilidad
	habilidad_calor = true
	$UI/PanelHabilidades/VBox/BotonCalor.disabled = true
	$UI/PanelHabilidades/VBox/BotonCalor.text = "Calor [ACTIVO]"


func _on_boton_mutacion():
	if puntos_infeccion < costo_habilidad:
		return
	puntos_infeccion -= costo_habilidad
	habilidad_mutacion = true
	$UI/PanelHabilidades/VBox/BotonMutacion.disabled = true
	$UI/PanelHabilidades/VBox/BotonMutacion.text = "Mutacion [ACTIVO]"


func _actualizar_botones():
	$UI/PanelHabilidades/VBox/LabelPuntos.text = "Puntos: " + str(puntos_infeccion)
	if not habilidad_frio:
		$UI/PanelHabilidades/VBox/BotonFrio.disabled = puntos_infeccion < costo_habilidad
	if not habilidad_calor:
		$UI/PanelHabilidades/VBox/BotonCalor.disabled = puntos_infeccion < costo_habilidad
	if not habilidad_mutacion:
		$UI/PanelHabilidades/VBox/BotonMutacion.disabled = puntos_infeccion < costo_habilidad
