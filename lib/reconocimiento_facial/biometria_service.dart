import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BiometriaService {
  final String baseUrl = 'https://sigelab-api.duckdns.org/api/Biometria';

  Future<Map<String, dynamic>> registrarBiometria({
    required File imagenFile,
    required int idUsuario,
  }) async {
    return _enviarBiometria(
      operacion: 'registrar',
      imagenFile: imagenFile,
      idUsuario: idUsuario,
    );
  }

  Future<Map<String, dynamic>> validarBiometria({
    required File imagenFile,
    required int idUsuario,
  }) async {
    return _enviarBiometria(
      operacion: 'validar',
      imagenFile: imagenFile,
      idUsuario: idUsuario,
    );
  }

  Future<Map<String, dynamic>> _enviarBiometria({
    required String operacion,
    required File imagenFile,
    required int idUsuario,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$operacion'),
      );

      final extension = imagenFile.path.split('.').last.toLowerCase();
      final mediaType = extension == 'png'
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          imagenFile.path,
          contentType: mediaType,
        ),
      );

      request.fields['idUsuario'] = idUsuario.toString();
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final body = response.body.trim();
      final decoded = body.isEmpty ? null : jsonDecode(body);
      if (decoded != null && decoded is! Map) {
        throw const FormatException(
          'El servidor devolvió una respuesta biométrica con formato inválido.',
        );
      }
      final data = decoded == null
          ? <String, dynamic>{}
          : Map<String, dynamic>.from(decoded as Map);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return {
          ...data,
          'exito': false,
          'statusCode': response.statusCode,
          'mensaje':
              data['mensaje']?.toString() ??
              (body.isEmpty
                  ? 'El servidor devolvió un error (${response.statusCode}).'
                  : body),
        };
      }

      return {
        ...data,
        'statusCode': response.statusCode,
        'exito': data['exito'] != false,
      };
    } on FormatException catch (e) {
      return {
        'exito': false,
        'mensaje': 'El servidor devolvió una respuesta inválida: $e',
      };
    } catch (e) {
      return {'exito': false, 'mensaje': 'No se pudo enviar la biometría: $e'};
    }
  }
}
