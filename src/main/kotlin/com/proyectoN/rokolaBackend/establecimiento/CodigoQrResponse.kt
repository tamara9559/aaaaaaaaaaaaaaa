package com.proyectoN.rokolaBackend.establecimiento

import java.time.OffsetDateTime

/**
 * Datos públicos de un código QR. No incluye `tokenHash` a propósito:
 * con la huella, alguien podría intentar adivinar el token por fuerza bruta.
 */
data class CodigoQrResponse(
	val id: Long,
	val fechaCreacion: OffsetDateTime,
	val fechaRevocacion: OffsetDateTime?,
	val activo: Boolean,
)

fun CodigoQr.toResponse() = CodigoQrResponse(
	id = requireNotNull(id) { "Un código QR leído de la base de datos siempre tiene id" },
	fechaCreacion = fechaCreacion,
	fechaRevocacion = fechaRevocacion,
	activo = activo,
)
