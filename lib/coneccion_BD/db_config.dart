
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

class DBConfig {
  static Future<Map<String, dynamic>> obtenerCredenciales() async {
    try {
      // 1. Leer el archivo
      String contenido =
          await rootBundle.loadString('assets/Conectividad_BD.txt');

      contenido = contenido.trim();

      // 2. Decodificar Base64
      String jsonString;

      try {
        jsonString = utf8.decode(base64.decode(contenido));
        debugPrint('Base64 decodificado correctamente.');
      } catch (e) {
        throw FormatException(
          'El archivo no contiene Base64 válido: $e',
        );
      }

      // 3. Verificar el JSON
      try {
        final resultado = jsonDecode(jsonString);

        if (resultado is! Map<String, dynamic>) {
          throw const FormatException(
            'El JSON debe contener un objeto.',
          );
        }

        return resultado;
      } on FormatException catch (e) {
        debugPrint('JSON decodificado: $jsonString');
        throw FormatException('El contenido Base64 no produce JSON válido: $e');
      }
    } catch (e) {
      debugPrint('Error al leer credenciales: $e');
      rethrow;
    }
  }
}
