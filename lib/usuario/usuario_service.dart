
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'usuario_model.dart';

class UsuarioService {
  static const String _baseUrl =
      'http://18.119.123.181/api/Usuario';

  // Obtener todos los usuarios.
  Future<List<Usuario>> listar() async {
    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al listar usuarios: ${response.statusCode}',
      );
    }

    final dynamic datos = jsonDecode(response.body);

    if (datos is! List) {
      throw const FormatException(
        'La respuesta de usuarios no es una lista.',
      );
    }

    return datos.map((item) {
      return Usuario.fromJson(
        Map<String, dynamic>.from(item as Map),
      );
    }).toList();
  }

  // Obtener roles.
  Future<List<Map<String, dynamic>>> listarRoles() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/roles'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener roles: ${response.statusCode}',
      );
    }

    final dynamic datos = jsonDecode(response.body);

    if (datos is! List) {
      throw const FormatException(
        'La respuesta de roles no es una lista.',
      );
    }

    return datos.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }

  // Obtener tipos de solicitante.
  Future<List<Map<String, dynamic>>>
      listarTiposSolicitante() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tipos-solicitante'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener tipos de solicitante: '
        '${response.statusCode}',
      );
    }

    final dynamic datos = jsonDecode(response.body);

    if (datos is! List) {
      throw const FormatException(
        'La respuesta de tipos de solicitante '
        'no es una lista.',
      );
    }

    return datos.map((item) {
      return Map<String, dynamic>.from(item as Map);
    }).toList();
  }
  
Future<Map<String, dynamic>> crear({
  required int idUsuarioAccionante,
  required int idRol,
  int? idTipoSolicitante,
  required String nombre,
  required String apellido,
  required String codigoPersonal,
  required String correo,
  required String usuario,
  required String passwordHash,
}) async {
  final response = await http.post(
    Uri.parse(_baseUrl),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'usuarioAccionante': {
        'idUsuario': idUsuarioAccionante,
      },
      'datos': {
        'idRol': idRol,
        'idTipoSolicitante': idTipoSolicitante,
        'nombre': nombre.trim(),
        'apellido': apellido.trim(),
        'codigoPersonal': codigoPersonal.trim(),
        'correo': correo.trim(),
        'usuario': usuario.trim(),
        'passwordHash': passwordHash,
      },
    }),
  );

  if (response.statusCode < 200 ||
      response.statusCode >= 300) {
    throw Exception(
      'Error al crear usuario: ${response.statusCode}',
    );
  }

if (response.body.trim().isEmpty) {
  return {'exito': true};
}

final dynamic resultado = jsonDecode(response.body);

if (resultado is! Map) {
  throw const FormatException(
    'La respuesta de creación no es un objeto JSON.',
  );
}

final datos = Map<String, dynamic>.from(resultado);

if (datos['exito'] == false) {
  throw Exception(
    datos['mensaje'] ?? 'No se pudo crear el usuario.',
  );
}

return datos;
  }
  
Future<Map<String, dynamic>> probarConexionCrear({
  required int idUsuarioAccionante,
}) async {
  final response = await http.post(
    Uri.parse(_baseUrl),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'usuarioAccionante': {
        'idUsuario': idUsuarioAccionante,
      },
      'datos': {
        'idRol': 3,
        'idTipoSolicitante': 1,
        'nombre': 'Prueba',
        'apellido': 'Conexion',
        'codigoPersonal': 'PRUEBA-CONEXION',
        'correo': 'prueba@example.invalid',
        'usuario': 'prueba_conexion',
        // No enviamos contraseña en esta prueba.
      },
    }),
  );

  return {
    'statusCode': response.statusCode,
    'respuesta': response.body,
  };
}

  
  // ACTUALIZAR USUARIO EN AWS
  Future<Map<String, dynamic>> actualizar({
    required int idUsuarioAccionante,
    required int idUsuario,
    required int idRol,
    int? idTipoSolicitante,
    required String nombre,
    required String apellido,
    required String codigoPersonal,
    required String correo,
    required String usuario,
    String? passwordHash,
  }) async {

    // Preparar los datos del usuario.
    final datosActualizados = <String, dynamic>{
      'idUsuario': idUsuario,
      'idRol': idRol,
      'idTipoSolicitante': idTipoSolicitante,
      'nombre': nombre.trim(),
      'apellido': apellido.trim(),
      'codigoPersonal': codigoPersonal.trim(),
      'correo': correo.trim(),
      'usuario': usuario.trim(),
    };

    // Solo incluir un hash cuando exista.
    if (passwordHash != null && passwordHash.isNotEmpty) {
      datosActualizados['passwordHash'] = passwordHash;
    }

    // Preparar el JSON completo.
    final body = {
      'usuarioAccionante': {
        'idUsuario': idUsuarioAccionante,
      },
      'datos': datosActualizados,
    };

    // Enviar actualización al backend.
    final response = await http.put(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );

    // Validar respuesta HTTP.
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Error al actualizar usuario: '
        '${response.statusCode} - ${response.body}',
      );
    }

    // Si el backend no devuelve contenido.
    if (response.body.trim().isEmpty) {
      return {'exito': true};
    }

    // Convertir respuesta a JSON.
    final dynamic resultado = jsonDecode(response.body);

    if (resultado is! Map) {
      throw const FormatException(
        'La respuesta de actualización no es un objeto JSON.',
      );
    }

    final datos = Map<String, dynamic>.from(resultado);

    // Validar resultado del backend.
    if (datos['exito'] == false) {
      throw Exception(
        datos['mensaje'] ?? 'No se pudo actualizar el usuario.',
      );
    }

    return datos;
  }



  // ACTIVAR O DESACTIVAR USUARIO EN AWS
  Future<Map<String, dynamic>> cambiarEstado({
    required int idUsuario,
    required int idUsuarioAccionante,
  }) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/$idUsuario/estado'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'usuarioAccionante': {
          'idUsuario': idUsuarioAccionante,
        },
      }),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Error al cambiar estado: '
        '${response.statusCode} - ${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      return {'exito': true};
    }

    final dynamic resultado = jsonDecode(response.body);

    if (resultado is! Map) {
      throw const FormatException(
        'La respuesta del servidor no es un objeto JSON.',
      );
    }

    final datos = Map<String, dynamic>.from(resultado);

    if (datos['exito'] == false) {
      throw Exception(
        datos['mensaje'] ?? 'No se pudo cambiar el estado.',
      );
    }

    return datos;
  }

}