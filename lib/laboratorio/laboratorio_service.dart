import 'dart:convert';

import 'package:http/http.dart' as http;

import 'laboratorio_model.dart';

class LaboratorioService {
  static const String _baseUrl = 'http://18.119.123.181/api/Laboratorio';

  static const Duration _timeout = Duration(seconds: 20);

  // ============================================================
  // MÉTODO: INTERPRETAR RESPUESTAS
  // ============================================================

  dynamic _decodificarRespuesta(http.Response response) {
    final contenido = utf8.decode(response.bodyBytes).trim();

    if (contenido.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(contenido);
    } on FormatException {
      return contenido;
    }
  }

  String _obtenerMensajeError(dynamic datos, String alternativo) {
    if (datos is Map) {
      return datos['mensaje']?.toString() ??
          datos['message']?.toString() ??
          alternativo;
    }

    if (datos is String && datos.isNotEmpty) {
      return datos;
    }

    return alternativo;
  }

  void _validarRespuesta(http.Response response) {
    final datos = _decodificarRespuesta(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _obtenerMensajeError(
          datos,
          'Error HTTP ${response.statusCode} al comunicarse con Laboratorios.',
        ),
      );
    }

    if (datos is Map && datos['exito'] == false) {
      throw Exception(
        _obtenerMensajeError(datos, 'La API no pudo completar la operación.'),
      );
    }
  }

  // ============================================================
  // MÉTODO: EXTRAER LISTA DE LABORATORIOS
  // ============================================================

  List<dynamic> _extraerLista(dynamic datos) {
    dynamic contenido = datos;

    // Permite recibir tanto una lista directa como una lista
    // dentro de un objeto de respuesta.
    for (int intento = 0; intento < 4; intento++) {
      if (contenido is List) {
        return contenido;
      }

      if (contenido is Map) {
        if (contenido['exito'] == false) {
          throw Exception(
            _obtenerMensajeError(
              contenido,
              'No fue posible consultar los laboratorios.',
            ),
          );
        }

        if (contenido.containsKey('value')) {
          contenido = contenido['value'];
          continue;
        }

        if (contenido.containsKey('Value')) {
          contenido = contenido['Value'];
          continue;
        }

        if (contenido.containsKey('datos')) {
          contenido = contenido['datos'];
          continue;
        }

        if (contenido.containsKey('data')) {
          contenido = contenido['data'];
          continue;
        }

        if (contenido.containsKey('items')) {
          contenido = contenido['items'];
          continue;
        }
      }

      break;
    }

    throw const FormatException(
      'La API no devolvió una lista válida de laboratorios.',
    );
  }

  // ============================================================
  // MÉTODO: CONSULTAR LABORATORIOS
  // GET /api/Laboratorio
  // ============================================================

  Future<List<Laboratorio>> obtenerLaboratorios() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl)).timeout(_timeout);

      _validarRespuesta(response);

      final datos = _decodificarRespuesta(response);
      final lista = _extraerLista(datos);

      return lista.map((item) {
        if (item is! Map) {
          throw const FormatException(
            'Un registro de laboratorio tiene un formato inválido.',
          );
        }

        return Laboratorio.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception('Error al consultar laboratorios: $error');
    }
  }

  // ============================================================
  // MÉTODO: ENVIAR SOLICITUDES POST, PUT Y PATCH
  // ============================================================

  Future<void> _enviarSolicitud({
    required String metodo,
    required Uri uri,
    required Map<String, dynamic> body,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      };

      final contenido = jsonEncode(body);

      late http.Response response;

      switch (metodo) {
        case 'POST':
          response = await http
              .post(uri, headers: headers, body: contenido)
              .timeout(_timeout);
          break;

        case 'PUT':
          response = await http
              .put(uri, headers: headers, body: contenido)
              .timeout(_timeout);
          break;

        case 'PATCH':
          response = await http
              .patch(uri, headers: headers, body: contenido)
              .timeout(_timeout);
          break;

        default:
          throw ArgumentError('Método HTTP no permitido: $metodo');
      }

      _validarRespuesta(response);
    } on Exception {
      rethrow;
    } catch (error) {
      throw Exception('Error al enviar la solicitud a Laboratorios: $error');
    }
  }

  // ============================================================
  // MÉTODO: CREAR LABORATORIO
  // POST /api/Laboratorio
  // ============================================================

  Future<void> crearLaboratorio({
    required int idUsuarioAccionante,
    required String codigo,
    required String nombre,
    required String ubicacion,
    required String descripcion,
    required int capacidad,
  }) async {
    if (idUsuarioAccionante <= 0) {
      throw Exception('No se encontró un usuario autenticado válido.');
    }

    final body = {
      'usuarioAccionante': {'idUsuario': idUsuarioAccionante},
      'datos': {
        'codigo': codigo,
        'nombre': nombre,
        'ubicacion': ubicacion,
        'descripcion': descripcion,
        'capacidad': capacidad,
      },
    };

    await _enviarSolicitud(
      metodo: 'POST',
      uri: Uri.parse(_baseUrl),
      body: body,
    );
  }

  // ============================================================
  // MÉTODO: ACTUALIZAR LABORATORIO
  // PUT /api/Laboratorio
  // ============================================================

  Future<void> actualizarLaboratorio({
    required int idUsuarioAccionante,
    required int idLaboratorio,
    required String nombre,
    required String ubicacion,
    required int capacidad,
  }) async {
    if (idUsuarioAccionante <= 0 || idLaboratorio <= 0) {
      throw Exception(
        'Los identificadores del usuario o laboratorio son inválidos.',
      );
    }

    final body = {
      'usuarioAccionante': {'idUsuario': idUsuarioAccionante},
      'datos': {
        'idLaboratorio': idLaboratorio,
        'nombre': nombre,
        'ubicacion': ubicacion,
        'capacidad': capacidad,
      },
    };

    await _enviarSolicitud(metodo: 'PUT', uri: Uri.parse(_baseUrl), body: body);
  }

  // ============================================================
  // MÉTODO: CAMBIAR ESTADO DEL LABORATORIO
  // PATCH /api/Laboratorio/{id}/estado
  // ============================================================

  Future<void> cambiarEstadoLaboratorio({
    required int idLaboratorio,
    required bool nuevoEstado,
  }) async {
    if (idLaboratorio <= 0) {
      throw Exception('El ID del laboratorio no es válido.');
    }

    final body = {'activo': nuevoEstado};

    await _enviarSolicitud(
      metodo: 'PATCH',
      uri: Uri.parse('$_baseUrl/$idLaboratorio/estado'),
      body: body,
    );
  }
}
