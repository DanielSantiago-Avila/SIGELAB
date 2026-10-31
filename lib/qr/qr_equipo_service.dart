import 'dart:convert';

import 'package:http/http.dart' as http;

class QrEquipoService {
  static const String _baseUrl = 'https://sigelab-api.duckdns.org';

  Future<Map<String, dynamic>> obtenerEquipoPorQr(String codigoQr) async {
    final codigo = codigoQr.trim();

    if (codigo.isEmpty) {
      throw Exception('El código QR está vacío.');
    }

    final uri = Uri.parse(
      '$_baseUrl/api/Equipo/qr/${Uri.encodeComponent(codigo)}',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final datos = jsonDecode(utf8.decode(response.bodyBytes));

        if (datos is Map<String, dynamic>) {
          return datos;
        }

        throw Exception('El servidor devolvió un formato inesperado.');
      }

      if (response.statusCode == 404) {
        throw Exception(
          'No se encontró ningún equipo asociado '
          'al código $codigo.',
        );
      }

      throw Exception(
        'Error al consultar el equipo '
        '(HTTP ${response.statusCode}).',
      );
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('No fue posible consultar el equipo: $e');
    }
  }
}
