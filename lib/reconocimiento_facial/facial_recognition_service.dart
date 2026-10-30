import 'dart:convert';
import 'package:http/http.dart' as http;

class FacialRecognitionService {
  final String baseUrl;
  final bool usarSimulacion; // Permite alternar entre pruebas y backend real

  FacialRecognitionService({
    this.baseUrl = 'http://18.119.123.181',
    this.usarSimulacion = false, // Puesto en true para pruebas locales
  });

  /// Registra la biometría del usuario por primera vez
  Future<bool> registrarRostro({
    required int idUsuario,
    required String imagenBase64,
  }) async {
    if (usarSimulacion) {
      // Simula el tiempo de respuesta del servidor (2 segundos)
      await Future.delayed(const Duration(seconds: 2));
      return true; // Simula registro exitoso en BIOMETRIA_USUARIO
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/biometria/registrar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': idUsuario,
          'imagen_capturada': imagenBase64,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error al registrar biometría: $e');
      return false;
    }
  }

  /// Valida la foto capturada en tiempo real contra la guardada
  Future<bool> validarRostro({
    required int idUsuario,
    required String imagenBase64,
  }) async {
    if (usarSimulacion) {
      await Future.delayed(const Duration(seconds: 2));
      return true; // Simula validación exitosa
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/biometria/validar'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_usuario': idUsuario,
          'imagen_capturada': imagenBase64,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['es_valido'] == true;
      }
      return false;
    } catch (e) {
      print('Error al validar biometría: $e');
      return false;
    }
  }
}