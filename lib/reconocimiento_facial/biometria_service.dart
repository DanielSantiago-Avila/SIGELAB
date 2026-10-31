import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class BiometriaService {
  final String baseUrl = 'http://18.119.123.181/api/usuario';

  Future<Map<String, dynamic>> registrarBiometria({
    required File imagenFile,
    required String idUsuario,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/biometria/registrar'),
      );

      // 1. Especificar el contentType correcto según la extensión
      String extension = imagenFile.path.split('.').last.toLowerCase();
      MediaType mediaType = (extension == 'png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');

      // 2. Adjuntar el archivo con el nombre de campo 'foto' y su MimeType
      request.files.add(
        await http.MultipartFile.fromPath(
          'foto',
          imagenFile.path,
          contentType: mediaType,
        ),
      );

      // 3. Enviar el ID del usuario
      request.fields['idUsuario'] = idUsuario;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return {
          'exito': false,
          'statusCode': response.statusCode,
          'mensaje': 'El servidor devolvió un error (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Error de conexión HTTP: $e',
      };
    }
  }
}