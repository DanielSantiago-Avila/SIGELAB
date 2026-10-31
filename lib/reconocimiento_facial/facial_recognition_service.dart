import 'dart:convert';
import 'package:http/http.dart' as http;

class FacialRecognitionService {
  final String baseUrl;
  final bool usarSimulacion;

  FacialRecognitionService({
    this.baseUrl = 'http://18.119.123.181',
    this.usarSimulacion = false,
  });

  /// Registra la biometría del usuario por primera vez
  Future<bool> registrarRostro({
    required int idUsuario,
    required String imagenBase64,
  }) async {
    if (usarSimulacion) {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/Usuario/biometria/registrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_usuario': idUsuario,
        'imagen_capturada': imagenBase64,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
      'El servidor rechazó el registro biométrico (HTTP ${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.isEmpty) return true;
    final data = jsonDecode(response.body);
    if (data is Map && data.containsKey('exito')) {
      return data['exito'] == true;
    }
    return true;
  }

  Future<bool> tieneBiometria(int idUsuario) async {
    if (usarSimulacion) return false;
    final response = await http.get(
      Uri.parse('$baseUrl/api/Usuario/$idUsuario/biometria/estado'),
    );
    if (response.statusCode != 200) {
      throw Exception('No se pudo consultar la biometría (HTTP ${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(response.body);
    return data is Map && data['tiene_biometria'] == true;
  }

  /// Valida la foto capturada en tiempo real contra la guardada
  Future<bool> validarRostro({
    required int idUsuario,
    required String imagenBase64,
  }) async {
    if (usarSimulacion) {
      await Future.delayed(const Duration(seconds: 2));
      return true;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/Usuario/biometria/validar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_usuario': idUsuario,
        'imagen_capturada': imagenBase64,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
      'El servidor rechazó la validación facial (HTTP ${response.statusCode}): ${response.body}',
    );
    }

    final data = jsonDecode(response.body);
    if (data is! Map) {
      throw const FormatException(
        'La respuesta de validación facial no tiene el formato esperado.',
      );
    }
    return data['es_valido'] == true || data['exito'] == true;
  }
}