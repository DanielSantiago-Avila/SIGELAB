import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'laboratorio_model.dart';

class LaboratorioService {
  static const String _baseUrl =
      'http://18.119.123.181/api/Laboratorio';

  // Se amplía el tiempo de espera de 20 a 60 segundos.
  static const Duration _timeout = Duration(seconds: 60);

  // ============================================================
  // DECODIFICAR RESPUESTAS
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

  // ============================================================
  // OBTENER MENSAJES DE ERROR
  // ============================================================

  String _obtenerMensajeError(dynamic datos, String alternativo) {
    if (datos is Map) {
      const claves = [
        'mensaje',
        'Mensaje',
        'message',
        'Message',
        'detail',
        'Detail',
        'title',
        'Title',
      ];

      for (final clave in claves) {
        final valor = datos[clave];

        if (valor != null && valor.toString().trim().isNotEmpty) {
          return valor.toString();
        }
      }
    }

    if (datos is String && datos.trim().isNotEmpty) {
      return datos;
    }

    return alternativo;
  }

  // ============================================================
  // VALIDAR RESPUESTAS HTTP
  // ============================================================

  void _validarRespuesta(http.Response response) {
    final datos = _decodificarRespuesta(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        _obtenerMensajeError(
          datos,
          'Error HTTP ${response.statusCode}.',
        ),
      );
    }

    if (datos is Map) {
      final exito = datos['exito'] ?? datos['Exito'];

      if (exito == false) {
        throw Exception(
          _obtenerMensajeError(
            datos,
            'La API no pudo completar la operación.',
          ),
        );
      }
    }
  }

  // ============================================================
  // EXTRAER LISTAS DE LAS RESPUESTAS
  // ============================================================

  List<dynamic> _extraerLista(dynamic datos) {
    dynamic contenido = datos;

    for (int intento = 0; intento < 6; intento++) {
      if (contenido is List) {
        return contenido;
      }

      if (contenido is String) {
        try {
          contenido = jsonDecode(contenido);
          continue;
        } on FormatException {
          break;
        }
      }

      if (contenido is Map) {
        final exito = contenido['exito'] ?? contenido['Exito'];

        if (exito == false) {
          throw Exception(
            _obtenerMensajeError(
              contenido,
              'No fue posible consultar los laboratorios.',
            ),
          );
        }

        const claves = [
          'value',
          'Value',
          'datos',
          'Datos',
          'data',
          'Data',
          'items',
          'Items',
          'resultado',
          'Resultado',
          'result',
          'Result',
        ];

        bool encontrado = false;

        for (final clave in claves) {
          if (contenido.containsKey(clave)) {
            contenido = contenido[clave];
            encontrado = true;
            break;
          }
        }

        if (encontrado) {
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
  // CONSULTAR LABORATORIOS
  // ============================================================

  Future<List<Laboratorio>> _consultarLista(String endpoint) async {
    final uri = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      _validarRespuesta(response);

      final datos = _decodificarRespuesta(response);
      final lista = _extraerLista(datos);

      return lista.map((item) {
        if (item is! Map) {
          throw const FormatException(
            'Un registro de laboratorio tiene un formato inválido.',
          );
        }

        return Laboratorio.fromJson(
          Map<String, dynamic>.from(item),
        );
      }).toList();
    } on TimeoutException {
      throw Exception(
        'La consulta de laboratorios superó los 60 segundos. '
        'Comprueba la conexión con el servidor.',
      );
    } on SocketException {
      throw Exception(
        'No fue posible conectar con el servidor de laboratorios.',
      );
    } catch (error) {
      throw Exception(
        'Error al consultar laboratorios: $error',
      );
    }
  }

  // ============================================================
  // GET: LISTAR TODOS LOS LABORATORIOS
  // GET /api/Laboratorio
  // ============================================================

  Future<List<Laboratorio>> obtenerLaboratorios() {
    return _consultarLista('');
  }

  // ============================================================
  // GET: LABORATORIOS ACTIVOS
  // GET /api/Laboratorio/activos-combo
  // ============================================================

  Future<List<Laboratorio>> obtenerLaboratoriosActivosCombo() {
    return _consultarLista('/activos-combo');
  }

  // ============================================================
  // GET: LABORATORIOS PARA EQUIPOS
  // GET /api/Laboratorio/equipos-combo
  // ============================================================

  Future<List<Laboratorio>> obtenerLaboratoriosEquiposCombo() {
    return _consultarLista('/equipos-combo');
  }

  // ============================================================
  // ENVIAR SOLICITUDES POST, PUT Y PATCH
  // ============================================================

  Future<void> _enviarSolicitud({
    required String metodo,
    required Uri uri,
    required Map<String, dynamic> body,
  }) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    final contenido = jsonEncode(body);

    try {
      late http.Response response;

      switch (metodo) {
        case 'POST':
          response = await http
              .post(
                uri,
                headers: headers,
                body: contenido,
              )
              .timeout(_timeout);
          break;

        case 'PUT':
          response = await http
              .put(
                uri,
                headers: headers,
                body: contenido,
              )
              .timeout(_timeout);
          break;

        case 'PATCH':
          response = await http
              .patch(
                uri,
                headers: headers,
                body: contenido,
              )
              .timeout(_timeout);
          break;

        default:
          throw ArgumentError(
            'Método HTTP no permitido: $metodo',
          );
      }

      _validarRespuesta(response);
    } on TimeoutException {
      throw Exception(
        'La solicitud $metodo superó los 60 segundos. '
        'No se pudo confirmar el resultado en el servidor. '
        'Comprueba el registro antes de volver a enviar la operación.',
      );
    } on SocketException {
      throw Exception(
        'No fue posible conectar con el servidor. '
        'Comprueba tu conexión a Internet.',
      );
    }
  }

  // ============================================================
  // POST: CREAR LABORATORIO
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
      throw Exception(
        'No se encontró un usuario autenticado válido.',
      );
    }

    final body = {
      'usuarioAccionante': {
        'idUsuario': idUsuarioAccionante,
      },
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
  // PUT: ACTUALIZAR LABORATORIO
  // PUT /api/Laboratorio
  // ============================================================

  Future<void> actualizarLaboratorio({
    required int idUsuarioAccionante,
    required int idLaboratorio,
    required String nombre,
    required String ubicacion,
    required int capacidad,
    String? codigo,
    String? descripcion,
  }) async {
    if (idUsuarioAccionante <= 0 || idLaboratorio <= 0) {
      throw Exception(
        'Los identificadores son inválidos.',
      );
    }

    final datos = <String, dynamic>{
      'id_laboratorio': idLaboratorio,
      'nombre': nombre,
      'ubicacion': ubicacion,
      'capacidad': capacidad,
    };

    if (codigo != null) {
      datos['codigo'] = codigo;
    }

    if (descripcion != null) {
      datos['descripcion'] = descripcion;
    }

    final body = {
      'usuarioAccionante': {
        'idUsuario': idUsuarioAccionante,
      },
      'datos': datos,
    };

    await _enviarSolicitud(
      metodo: 'PUT',
      uri: Uri.parse(_baseUrl),
      body: body,
    );
  }

  // ============================================================
  // PATCH: CAMBIAR ESTADO
  // PATCH /api/Laboratorio/{id}/estado
  // ============================================================

  Future<void> cambiarEstadoLaboratorio({
    required int idUsuarioAccionante,
    required int idLaboratorio,
    required bool nuevoEstado,
  }) async {
    if (idUsuarioAccionante <= 0 || idLaboratorio <= 0) {
      throw Exception(
        'Los identificadores son inválidos.',
      );
    }

    final body = {
      'usuarioAccionante': {
        'idUsuario': idUsuarioAccionante,
      },
      'datos': {
        'activo': nuevoEstado,
      },
    };

    await _enviarSolicitud(
      metodo: 'PATCH',
      uri: Uri.parse('$_baseUrl/$idLaboratorio/estado'),
      body: body,
    );
  }
}