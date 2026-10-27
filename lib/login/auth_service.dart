import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String _baseUrl = 'http://18.119.123.181/api/Auth';

  Future<Map<String, dynamic>> iniciarSesion(String usuario, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'usuario': usuario, 'password': password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'exito': false, 'mensaje': 'Error en el servidor (${response.statusCode})'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión con AWS: $e'};
    }
  }

  Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String apellido,
    required String codigoPersonal,
    required String correo,
    required String usuario,
    required String password,
    int idRol = 1,
    int idTipoSolicitante = 1,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'apellido': apellido,
          'codigoPersonal': codigoPersonal,
          'correo': correo,
          'usuario': usuario,
          'password': password,
          'idRol': idRol,
          'idTipoSolicitante': idTipoSolicitante,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'exito': false, 'mensaje': 'Error en el servidor (${response.statusCode})'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error de conexión con AWS: $e'};
    }
  }
}