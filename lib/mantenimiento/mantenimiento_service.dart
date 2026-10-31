import 'dart:convert';

import 'package:http/http.dart' as http;

import 'mantenimiento_model.dart';

class MantenimientoService {
  static const String _baseUrl = 'https://sigelab-api.duckdns.org';

  static const Duration _tiempoEspera = Duration(seconds: 20);

  Future<List<dynamic>> _obtenerLista(
    String ruta, {
    Map<String, String>? parametros,
  }) async {
    final uri = Uri.parse('$_baseUrl$ruta')
        .replace(queryParameters: parametros);

    final http.Response respuesta;

    try {
      respuesta = await http.get(uri).timeout(_tiempoEspera);
    } catch (error) {
      throw Exception('No se pudo conectar con la API: $error');
    }

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error HTTP ${respuesta.statusCode}: '
        '${utf8.decode(respuesta.bodyBytes)}',
      );
    }

    final dynamic respuestaJson;

    try {
      respuestaJson = jsonDecode(utf8.decode(respuesta.bodyBytes));
    } on FormatException {
      throw const FormatException(
        'La API devolvió una respuesta JSON inválida.',
      );
    }

    dynamic lista;

    if (respuestaJson is List) {
      lista = respuestaJson;
    } else if (respuestaJson is Map) {
      lista =
          respuestaJson['value'] ??
          respuestaJson['Value'] ??
          respuestaJson['datos'] ??
          respuestaJson['data'];
    }

    if (lista is! List) {
      throw const FormatException('La API no devolvió una lista válida.');
    }

    return lista;
  }

  Future<List<Mantenimiento>> obtenerMantenimientos({String? estado}) async {
    final parametros = <String, String>{};

    if (estado != null && estado.trim().isNotEmpty) {
      parametros['estado'] = estado.trim();
    }

    final datos = await _obtenerLista(
      '/api/Mantenimiento',
      parametros: parametros.isEmpty ? null : parametros,
    );

    return datos.map((item) {
      if (item is! Map) {
        throw const FormatException('Registro de mantenimiento inválido.');
      }

      return Mantenimiento.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<List<EquipoMantenimiento>> obtenerEquiposParaMantenimiento({
    String? busqueda,
  }) async {
    final parametros = <String, String>{};

    if (busqueda != null && busqueda.trim().isNotEmpty) {
      parametros['busqueda'] = busqueda.trim();
    }

    final datos = await _obtenerLista(
      '/api/Mantenimiento/equipos',
      parametros: parametros.isEmpty ? null : parametros,
    );

    return datos.map((item) {
      if (item is! Map) {
        throw const FormatException('Registro de equipo inválido.');
      }

      return EquipoMantenimiento.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<List<Mantenimiento>> obtenerHistorialEquipo(int idEquipo) async {
    final datos = await _obtenerLista(
      '/api/Mantenimiento/equipos/$idEquipo/historial',
    );

    return datos.map((item) {
      if (item is! Map) {
        throw const FormatException('Registro del historial inválido.');
      }

      return Mantenimiento.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  Future<void> iniciarMantenimiento({
    required int idUsuario,
    required int idEquipo,
    required String tipo,
    required String descripcion,
    String observaciones = '',
  }) async {
    if (idUsuario <= 0) {
      throw ArgumentError('El usuario responsable no es válido.');
    }

    if (idEquipo <= 0) {
      throw ArgumentError('El equipo seleccionado no es válido.');
    }

    final datos = {
      'usuarioAccionante': {'idUsuario': idUsuario},
      'datos': {
        'idEquipo': idEquipo,
        'tipo': tipo,
        'descripcion': descripcion,
        'observaciones': observaciones,
      },
    };

    await _enviar(
      metodo: 'POST',
      ruta: '/api/Mantenimiento/iniciar',
      datos: datos,
    );
  }

  Future<void> finalizarMantenimiento({
    required int idUsuario,
    required int idMantenimiento,
    required String resultado,
    String observaciones = '',
  }) async {
    if (idUsuario <= 0) {
      throw ArgumentError('El usuario responsable no es válido.');
    }

    if (idMantenimiento <= 0) {
      throw ArgumentError('El mantenimiento seleccionado no es válido.');
    }

    final datos = {
      'usuarioAccionante': {'idUsuario': idUsuario},
      'datos': {'resultado': resultado, 'observaciones': observaciones},
    };

    await _enviar(
      metodo: 'PATCH',
      ruta: '/api/Mantenimiento/$idMantenimiento/finalizar',
      datos: datos,
    );
  }

  Future<void> _enviar({
    required String metodo,
    required String ruta,
    required Map<String, dynamic> datos,
  }) async {
    final uri = Uri.parse('$_baseUrl$ruta');

    final body = jsonEncode(datos);

    final http.Response respuesta;

    try {
      if (metodo == 'POST') {
        respuesta = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(_tiempoEspera);
      } else if (metodo == 'PATCH') {
        respuesta = await http
            .patch(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(_tiempoEspera);
      } else {
        throw ArgumentError('Método HTTP no permitido.');
      }
    } catch (error) {
      if (error is ArgumentError) rethrow;

      throw Exception('No se pudo conectar con la API: $error');
    }

    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw Exception(
        'Error HTTP ${respuesta.statusCode}: '
        '${utf8.decode(respuesta.bodyBytes)}',
      );
    }
  }
}
