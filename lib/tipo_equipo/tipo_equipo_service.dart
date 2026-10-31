import 'dart:convert';

import 'package:http/http.dart' as http;

import 'tipo_equipo_model.dart';

class TipoEquipoService {
  // 1. Listar todos los tipos de equipo

  Future<List<TipoEquipo>> listar() async {
    final url = Uri.parse(
      'https://sigelab-api.duckdns.org/api/TipoEquipo/listar',
    );

    final response = await http
        .get(url, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Error HTTP ${response.statusCode}');
    }

    final dynamic respuesta = jsonDecode(response.body);

    if (respuesta is! List) {
      throw const FormatException('Se esperaba una lista de tipos de equipo');
    }

    final List<dynamic> registros =
        respuesta.length == 1 && respuesta.first is List
        ? respuesta.first as List<dynamic>
        : respuesta;

    final List<TipoEquipo> equipos = [];

    for (final registro in registros) {
      if (registro is! Map) {
        throw const FormatException('Registro JSON invÃ¡lido');
      }

      equipos.add(TipoEquipo.fromJson(Map<String, dynamic>.from(registro)));
    }

    return equipos;
  }

  // 2. Obtener un tipo de equipo por su ID
  Future<TipoEquipo> obtenerPorId(int idTipoEquipo) async {
    final url = Uri.parse(
      'https://sigelab-api.duckdns.org/api/TipoEquipo/obtener/$idTipoEquipo',
    );

    final response = await http
        .get(url, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception('Error al obtener equipo: HTTP ${response.statusCode}');
    }

    final dynamic respuesta = jsonDecode(response.body);

    // El backend puede devolver [[{...}]].
    dynamic registro = respuesta;

    while (registro is List) {
      if (registro.isEmpty) {
        throw const FormatException('No se encontrÃ³ el tipo de equipo');
      }

      registro = registro.first;
    }

    if (registro is! Map) {
      throw const FormatException('Formato de equipo invÃ¡lido');
    }

    return TipoEquipo.fromJson(Map<String, dynamic>.from(registro));
  }

  // 3. Listar solamente los tipos activos desde AWS
  Future<List<TipoEquipo>> listarActivos() async {
    final url = Uri.parse(
      'https://sigelab-api.duckdns.org/api/TipoEquipo/listar-activos-combo',
    );

    final response = await http
        .get(url, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Error al listar tipos activos: '
        'HTTP ${response.statusCode}. ${response.body}',
      );
    }

    dynamic respuesta = jsonDecode(response.body);

    // El backend puede devolver listas anidadas.
    while (respuesta is List &&
        respuesta.length == 1 &&
        respuesta.first is List) {
      respuesta = respuesta.first;
    }

    if (respuesta is! List) {
      throw const FormatException('Se esperaba una lista de tipos activos.');
    }

    final List<TipoEquipo> equipos = [];

    for (final registro in respuesta) {
      if (registro is! Map) {
        throw const FormatException('Registro de tipo de equipo inválido.');
      }

      equipos.add(TipoEquipo.fromJson(Map<String, dynamic>.from(registro)));
    }

    return equipos;
  }

  // 4. Crear un nuevo tipo de equipo

  Future<TipoEquipo> crear(
    TipoEquipo nuevo, {
    required int idUsuarioAccionante,
  }) async {
    final codigo = nuevo.codigo.trim();
    final nombre = nuevo.nombre.trim();

    if (codigo.isEmpty || nombre.isEmpty) {
      throw Exception('El cÃ³digo y nombre son obligatorios.');
    }

    final url = Uri.parse(
      'https://sigelab-api.duckdns.org/api/TipoEquipo/crear',
    );

    final datos = {
      'usuarioAccionante': {'idUsuario': idUsuarioAccionante},
      'datos': {
        'codigo': codigo,
        'nombre': nombre,
        'marca': nuevo.marca,
        'modelo': nuevo.modelo,
        'descripcion': nuevo.descripcion,
      },
    };

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(datos),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al crear equipo: HTTP ${response.statusCode}. '
        '${response.body}',
      );
    }

    final dynamic respuesta = jsonDecode(response.body);

    // La API puede devolver arreglos anidados.
    dynamic resultado = respuesta;

    while (resultado is List) {
      if (resultado.isEmpty) {
        throw const FormatException('La API devolviÃ³ una respuesta vacÃ­a.');
      }
      resultado = resultado.first;
    }

    if (resultado is! Map) {
      throw const FormatException('Respuesta de creaciÃ³n invÃ¡lida.');
    }

    final registro = Map<String, dynamic>.from(resultado);

    if (registro['exitoso'] != true && registro['exitoso'] != 1) {
      throw Exception(registro['mensaje'] ?? 'No se pudo crear el equipo.');
    }

    final idCreado = int.tryParse('${registro['idTipoEquipo']}');

    if (idCreado == null) {
      throw const FormatException(
        'La API no devolviÃ³ el ID del equipo creado.',
      );
    }

    return nuevo.copyWith(idTipoEquipo: idCreado, activo: true);
  }

  // 5. Actualizar un tipo de equipo en AWS
  Future<TipoEquipo> actualizar(
    TipoEquipo actualizado, {
    required int idUsuarioAccionante,
  }) async {
    final codigo = actualizado.codigo.trim();
    final nombre = actualizado.nombre.trim();

    if (codigo.isEmpty || nombre.isEmpty) {
      throw Exception('El cÃ³digo y nombre son obligatorios.');
    }

    final url = Uri.parse(
      'https://sigelab-api.duckdns.org/api/TipoEquipo/actualizar',
    );

    final datos = {
      'usuarioAccionante': {'idUsuario': idUsuarioAccionante},
      'datos': {
        'idTipoEquipo': actualizado.idTipoEquipo,
        'codigo': codigo,
        'nombre': nombre,
        'marca': actualizado.marca,
        'modelo': actualizado.modelo,
        'descripcion': actualizado.descripcion,
      },
    };

    final response = await http
        .put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(datos),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al actualizar: HTTP ${response.statusCode}. '
        '${response.body}',
      );
    }

    dynamic resultado = jsonDecode(response.body);

    while (resultado is List) {
      if (resultado.isEmpty) {
        throw const FormatException('La API devolviÃ³ una respuesta vacÃ­a.');
      }
      resultado = resultado.first;
    }

    if (resultado is! Map) {
      throw const FormatException('Respuesta de actualizaciÃ³n invÃ¡lida.');
    }

    final registro = Map<String, dynamic>.from(resultado);

    if (registro['exitoso'] != true && registro['exitoso'] != 1) {
      throw Exception(
        registro['mensaje'] ?? 'No se pudo actualizar el tipo de equipo.',
      );
    }

    return actualizado.copyWith(codigo: codigo, nombre: nombre);
  }

  // 6. Desactivar un tipo de equipo en AWS
  Future<void> desactivar(
    int idTipoEquipo, {
    required int idUsuarioAccionante,
  }) async {
    final url = Uri.parse(
      'https://sigelab-api.duckdns.org/api/TipoEquipo/desactivar',
    );

    final datos = {
      'usuarioAccionante': {'idUsuario': idUsuarioAccionante},
      'datos': {'idTipoEquipo': idTipoEquipo},
    };

    final response = await http
        .put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(datos),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al desactivar: HTTP ${response.statusCode}. '
        '${response.body}',
      );
    }

    dynamic resultado = jsonDecode(response.body);

    while (resultado is List) {
      if (resultado.isEmpty) {
        throw const FormatException('Respuesta vacÃ­a del servidor.');
      }
      resultado = resultado.first;
    }

    if (resultado is! Map) {
      throw const FormatException('Respuesta de desactivaciÃ³n invÃ¡lida.');
    }

    final registro = Map<String, dynamic>.from(resultado);

    if (registro['exitoso'] != true && registro['exitoso'] != 1) {
      throw Exception('${registro['mensaje'] ?? 'No se pudo desactivar.'}');
    }
  }

  // 7. Activar un tipo de equipo en AWS
  Future<void> activar(
    int idTipoEquipo, {
    required int idUsuarioAccionante,
  }) async {
    final url = Uri.parse(
      'https://sigelab-api.duckdns.org/api/TipoEquipo/activar',
    );

    final datos = {
      'usuarioAccionante': {'idUsuario': idUsuarioAccionante},
      'datos': {'idTipoEquipo': idTipoEquipo},
    };

    final response = await http
        .put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(datos),
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Error al activar: HTTP ${response.statusCode}. '
        '${response.body}',
      );
    }

    dynamic resultado = jsonDecode(response.body);

    while (resultado is List) {
      if (resultado.isEmpty) {
        throw const FormatException('Respuesta vacÃ­a del servidor.');
      }
      resultado = resultado.first;
    }

    if (resultado is! Map) {
      throw const FormatException('Respuesta de activaciÃ³n invÃ¡lida.');
    }

    final registro = Map<String, dynamic>.from(resultado);

    if (registro['exitoso'] != true && registro['exitoso'] != 1) {
      throw Exception('${registro['mensaje'] ?? 'No se pudo activar.'}');
    }
  }
}
