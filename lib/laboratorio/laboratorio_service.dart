import 'dart:convert';

import 'package:http/http.dart' as http;

import 'laboratorio_model.dart';

class LaboratorioService {
  final String _baseUrl = 'http://18.119.123.181/api/Laboratorio';

  final String _urlConsulta = 'http://18.119.123.181/api/Equipo/laboratorios';

  Future<List<Laboratorio>> obtenerLaboratorios() async {
    try {
      print('Intentando conectar a: $_baseUrl');
      final response = await http.get(Uri.parse(_urlConsulta));
      print('Respuesta HTTP (${response.statusCode}): ${response.body}');
      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Laboratorio.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error en GET: $e');
      return [];
    }
  }

  Future<bool> crearLaboratorio(Map<String, dynamic> datosJson) async {
    try {
      print('>>> POST enviando JSON: ${jsonEncode(datosJson)}');
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datosJson),
      );
      print(
        '>>> POST Respuesta HTTP (${response.statusCode}): ${response.body}',
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('>>> POST Error: $e');
      return false;
    }
  }

  Future<bool> actualizarLaboratorio(Map<String, dynamic> datosJson) async {
    try {
      final response = await http.put(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(datosJson),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> cambiarEstadoLaboratorio(int id, bool nuevoEstado) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/$id/estado'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'activo': nuevoEstado}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
