package com.proyectoN.rokolaBackend.establecimiento

import java.time.OffsetDateTime

/**
 * Datos de un establecimiento que la API entrega a los clientes.
 * Es distinto de la entidad para que cambiar la base de datos no cambie la API sin querer.
 */
data class EstablecimientoResponse(
	val id: Long,
	val nombre: String,
	val slug: String,
	val direccion: String?,
	val zonaHoraria: String,
	val activo: Boolean,
	val fechaCreacion: OffsetDateTime,
)

fun Establecimiento.toResponse() = EstablecimientoResponse(
	id = requireNotNull(id) { "Un establecimiento leído de la base de datos siempre tiene id" },
	nombre = nombre,
	slug = slug,
	direccion = direccion,
	zonaHoraria = zonaHoraria,
	activo = activo,
	fechaCreacion = fechaCreacion,
)
