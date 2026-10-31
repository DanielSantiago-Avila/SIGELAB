
import 'dart:convert';

import 'package:http/http.dart' as http;

class DevolucionService {
  static const String _baseUrl =
      'http://18.119.123.181/api/Devolucion';

  Future<List<Map<String, dynamic>>> listarPendientes({
    int? idSolicitante,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/pendientes').replace(
        queryParameters: idSolicitante == null
            ? null
            : {'idSolicitante': idSolicitante.toString()},
      );

      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Error al consultar devoluciones '
          '(HTTP ${response.statusCode}).',
        );
      }

      final datos = jsonDecode(utf8.decode(response.bodyBytes));

      if (datos is! List) {
        throw const FormatException(
          'La API no devolvió una lista de devoluciones.',
        );
      }

      return datos.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException(
            'Se recibió una devolución con formato inválido.',
          );
        }
        return item;
      }).toList();
    } catch (e) {
      throw Exception('No fue posible consultar las devoluciones: $e');
    }
  }

  Future<Map<String, dynamic>> obtenerDetalle(
    int idDevolucion,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/$idDevolucion/detalle');

      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception(
          'Error al consultar el detalle '
          '(HTTP ${response.statusCode}).',
        );
      }

      final datos = jsonDecode(utf8.decode(response.bodyBytes));

      if (datos is! List || datos.length < 3) {
        throw const FormatException(
          'La API devolvió un formato de detalle inválido.',
        );
      }

      Map<String, dynamic> primerRegistro(dynamic valor) {
        if (valor is! List || valor.isEmpty) {
          throw const FormatException(
            'Falta información en el detalle de la devolución.',
          );
        }

        final registro = valor.first;

        if (registro is! Map<String, dynamic>) {
          throw const FormatException(
            'Se recibió un registro con formato inválido.',
          );
        }

        return registro;
      }

      if (datos[1] is! List) {
        throw const FormatException(
          'La API no devolvió una lista de equipos.',
        );
      }

      final equipos = (datos[1] as List).map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException(
            'Se recibió un equipo con formato inválido.',
          );
        }

        return item;
      }).toList();

      return {
        'informacion': primerRegistro(datos[0]),
        'equipos': equipos,
        'resumen': primerRegistro(datos[2]),
      };
    } catch (e) {
      throw Exception(
        'No fue posible consultar el detalle de la devolución: $e',
      );
    }
  }

  // POST /api/Devolucion/recepcion
  Future<Map<String, dynamic>> registrarRecepcion({
    required int idUsuario,
    required int idPrestamo,
    required List<Map<String, dynamic>> equipos,
    String observaciones = '',
  }) async {
    if (idUsuario <= 0 || idPrestamo <= 0) {
      throw ArgumentError('Usuario o préstamo inválido.');
    }

    if (equipos.isEmpty) {
      throw ArgumentError(
        'Debes seleccionar al menos un equipo para recibir.',
      );
    }

    final ids = <int>{};

    for (final equipo in equipos) {
      final id = equipo['idEquipo'];
      final condicion = equipo['condicion'];

      if (id is! int || id <= 0) {
        throw ArgumentError('Hay un equipo con ID inválido.');
      }

      if (!ids.add(id)) {
        throw ArgumentError('Hay equipos repetidos.');
      }

      if (condicion != 'BUENO' && condicion != 'DAÑADO') {
        throw ArgumentError(
          'La condición debe ser BUENO o DAÑADO.',
        );
      }
    }

    final cuerpo = {
      'usuarioAccionante': {
        'idUsuario': idUsuario,
      },
      'datos': {
        'idPrestamo': idPrestamo,
        'observaciones': observaciones.trim(),
        'equipos': equipos.map((equipo) {
          return {
            'idEquipo': equipo['idEquipo'],
            'condicion': equipo['condicion'],
            'observaciones':
                (equipo['observaciones'] ?? '').toString().trim(),
          };
        }).toList(),
      },
    };

    final uri = Uri.parse('$_baseUrl/recepcion');

    try {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(cuerpo),
          )
          .timeout(const Duration(seconds: 20));

      final contenido = utf8.decode(response.bodyBytes);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'Error HTTP ${response.statusCode}: $contenido',
        );
      }

      final datos = jsonDecode(contenido);

      final Map<String, dynamic> resultado;

      if (datos is Map<String, dynamic>) {
        resultado = datos;
      } else if (datos is List &&
          datos.isNotEmpty &&
          datos.first is Map<String, dynamic>) {
        resultado = datos.first as Map<String, dynamic>;
      } else {
        throw const FormatException(
          'El servidor devolvió un resultado inesperado.',
        );
      }

      if (resultado['exitoso'] != true &&
          resultado['exitoso'] != 1) {
        throw Exception(
          resultado['mensaje']?.toString() ??
              'La recepción no fue confirmada.',
        );
      }

      return resultado;
    } catch (e) {
      throw Exception('No fue posible registrar la recepción: $e');
    }
  }
}
