import 'dart:convert';

import 'package:http/http.dart' as http;

class PrestamoService {
  static const String _baseUrl = 'http://18.119.123.181';

  Future<dynamic> _consultar(Uri uri) async {
    final http.Response respuesta;

    try {
      respuesta = await http.get(uri).timeout(const Duration(seconds: 15));
    } catch (error) {
      throw Exception('No se pudo conectar con la API: $error');
    }

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error HTTP ${respuesta.statusCode}: '
        '${utf8.decode(respuesta.bodyBytes)}',
      );
    }

    try {
      return jsonDecode(utf8.decode(respuesta.bodyBytes));
    } on FormatException {
      throw const FormatException(
        'La API devolvió una respuesta JSON inválida.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> obtenerSolicitantes() async {
    final uri = Uri.parse('$_baseUrl/api/Prestamo/solicitantes');
    final datos = await _consultar(uri);

    if (datos is! List) {
      throw const FormatException('Se esperaba una lista de solicitantes.');
    }

    return datos.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Un solicitante tiene un formato inválido.',
        );
      }
      return item;
    }).toList();
  }

  Future<bool> validarPermiso({
    required int idSolicitante,
    required int idTipoEquipo,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/Prestamo/validar-permiso').replace(
      queryParameters: {
        'idSolicitante': '$idSolicitante',
        'idTipoEquipo': '$idTipoEquipo',
      },
    );

    final datos = await _consultar(uri);

    // La API devuelve: [{"permitido": false}]
    if (datos is List && datos.isNotEmpty) {
      final primero = datos.first;

      if (primero is Map && primero['permitido'] is bool) {
        return primero['permitido'] as bool;
      }
    }

    throw const FormatException(
      'La API no devolvió una validación de permiso válida.',
    );
  }

  Future<Map<String, dynamic>> consultarEquipoParaPrestamo({
    required String codigoQr,
    required int idSolicitante,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/Prestamo/equipos/qr/'
      '${Uri.encodeComponent(codigoQr)}',
    ).replace(queryParameters: {'idSolicitante': '$idSolicitante'});

    final datos = await _consultar(uri);

    // La API devuelve una lista con el equipo consultado.
    if (datos is List && datos.isNotEmpty) {
      final primero = datos.first;

      if (primero is Map<String, dynamic>) {
        return primero;
      }
    }

    throw const FormatException(
      'No se encontró un equipo válido para el préstamo.',
    );
  }

  Future<Map<String, dynamic>> registrarPrestamo({
    required int idUsuario,
    required int idSolicitante,
    required DateTime fechaDevolucionEsperada,
    required List<int> idsEquipos,
    String observaciones = '',
  }) async {
    if (idsEquipos.isEmpty) {
      throw ArgumentError('Debes seleccionar al menos un equipo.');
    }

    final datos = {
      'usuarioAccionante': {'idUsuario': idUsuario},
      'datos': {
        'idSolicitante': idSolicitante,
        'fechaDevolucionEsperada': fechaDevolucionEsperada.toIso8601String(),
        'observaciones': observaciones,
        'equipos': idsEquipos
            .map((idEquipo) => {'idEquipo': idEquipo})
            .toList(),
      },
    };

    // Pendiente: confirmar la ruta POST exacta con el backend.
    // No enviar la solicitud hasta configurar ese endpoint.
    const String rutaRegistro = '';

    if (rutaRegistro.isEmpty) {
      throw StateError(
        'Falta configurar el endpoint POST para registrar préstamos.',
      );
    }

    final uri = Uri.parse('$_baseUrl$rutaRegistro');

    final http.Response respuesta;

    try {
      respuesta = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(datos),
          )
          .timeout(const Duration(seconds: 15));
    } catch (error) {
      throw Exception('No se pudo conectar con la API: $error');
    }

    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw Exception(
        'Error al registrar el préstamo '
        '(HTTP ${respuesta.statusCode}): '
        '${utf8.decode(respuesta.bodyBytes)}',
      );
    }

    final contenido = utf8.decode(respuesta.bodyBytes);

    if (contenido.trim().isEmpty) {
      return {'exito': true};
    }

    final resultado = jsonDecode(contenido);

    if (resultado is Map<String, dynamic>) {
      return resultado;
    }

    return {'exito': true, 'resultado': resultado};
  }
}
