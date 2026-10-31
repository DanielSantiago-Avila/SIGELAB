import 'dart:convert';

import 'package:http/http.dart' as http;

import 'equipo_model.dart';

class EquiposInventarioService {
  static const String _baseUrl = 'http://18.119.123.181';

  static const Duration _timeout = Duration(seconds: 20);

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 1. LISTAR EQUIPOS
  Future<List<EquipoModel>> listar({
    String busqueda = '',
  }) async {
    final uri = Uri.parse('$_baseUrl/api/Equipo').replace(
      queryParameters: busqueda.trim().isEmpty
          ? null
          : {'busqueda': busqueda.trim()},
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(_timeout);

    _validarHttp(response, 'consultar equipos');

    final registros = _extraerLista(
      utf8.decode(response.bodyBytes),
    );

    return registros.map((registro) {
      return EquipoModel.fromJson(registro);
    }).toList();
  }

  // 2. LISTAR TIPOS DE EQUIPO ACTIVOS
  // Utiliza el mismo endpoint del TipoEquipoService existente.
  Future<List<Map<String, dynamic>>> listarTipos() async {
    final uri = Uri.parse(
      '$_baseUrl/api/TipoEquipo/listar-activos-combo',
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(_timeout);

    _validarHttp(response, 'consultar tipos de equipo');

    return _extraerLista(
      utf8.decode(response.bodyBytes),
    );
  }

  // 3. LISTAR LABORATORIOS
  Future<List<Map<String, dynamic>>> listarLaboratorios() async {
    final uri = Uri.parse(
      '$_baseUrl/api/Equipo/laboratorios',
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(_timeout);

    _validarHttp(response, 'consultar laboratorios');

    return _extraerLista(
      utf8.decode(response.bodyBytes),
    );
  }

  // 4. PREPARAR DATOS PARA EL PROCEDIMIENTO ALMACENADO
  Map<String, dynamic> _prepararDatos(
    Map<String, dynamic> datos, {
    bool esCreacion = false,
  }) {
    final resultado = Map<String, dynamic>.from(datos);

    final codigo = resultado['codigoInventario']
        ?.toString()
        .trim();

    if (codigo == null || codigo.isEmpty) {
      throw Exception(
        'El código de inventario es obligatorio.',
      );
    }

    final idTipo = int.tryParse(
      resultado['idTipoEquipo']?.toString() ?? '',
    );

    final idLaboratorio = int.tryParse(
      resultado['idLaboratorio']?.toString() ?? '',
    );

    if (idTipo == null || idTipo <= 0) {
      throw Exception('Selecciona un tipo de equipo válido.');
    }

    if (idLaboratorio == null || idLaboratorio <= 0) {
      throw Exception('Selecciona un laboratorio válido.');
    }

    resultado['codigoInventario'] = codigo;
    resultado['idTipoEquipo'] = idTipo;
    resultado['idLaboratorio'] = idLaboratorio;

    // Genera un código QR cuando todavía no existe uno.
    final qr = resultado['codigoQR']?.toString().trim();

    resultado['codigoQR'] =
        qr != null && qr.isNotEmpty
            ? qr
            : 'QR-$codigo';

    // En registros nuevos, utiliza la fecha actual
    // si el formulario no proporciona una fecha de adquisición.
    if (esCreacion &&
        (resultado['fechaAdquisicion'] == null ||
            resultado['fechaAdquisicion'].toString().isEmpty)) {
      resultado['fechaAdquisicion'] =
          DateTime.now().toIso8601String().split('T').first;
    }

    resultado['numeroSerie'] =
        resultado['numeroSerie']?.toString().trim() ?? '';

    resultado['observaciones'] =
        resultado['observaciones']?.toString().trim() ?? '';

    return resultado;
  }

  // 5. CREAR EQUIPO
  Future<void> crear({
    required int idUsuarioAccionante,
    required Map<String, dynamic> datos,
  }) async {
    if (idUsuarioAccionante <= 0) {
      throw Exception('El usuario accionante no es válido.');
    }

    final uri = Uri.parse('$_baseUrl/api/Equipo');

    final datosPreparados = _prepararDatos(
      datos,
      esCreacion: true,
    );

    final cuerpo = {
      'usuarioAccionante': {
        'idUsuario': idUsuarioAccionante,
      },
      'datos': datosPreparados,
    };

    final response = await http
        .post(
          uri,
          headers: _headers,
          body: jsonEncode(cuerpo),
        )
        .timeout(_timeout);

    _validarHttp(response, 'registrar equipo');

    _validarRespuesta(
      utf8.decode(response.bodyBytes),
    );
  }

  // 6. ACTUALIZAR EQUIPO
  // El ID se envía tanto en la URL como dentro de datos.
  // El controlador comprueba que ambos coincidan.
  Future<void> actualizar({
    required int idEquipo,
    required int idUsuarioAccionante,
    required Map<String, dynamic> datos,
  }) async {
    if (idEquipo <= 0) {
      throw Exception('El ID del equipo no es válido.');
    }

    if (idUsuarioAccionante <= 0) {
      throw Exception('El usuario accionante no es válido.');
    }

    final uri = Uri.parse(
      '$_baseUrl/api/Equipo/$idEquipo',
    );

    final datosPreparados = _prepararDatos(datos);

    datosPreparados['idEquipo'] = idEquipo;

    final cuerpo = {
      'usuarioAccionante': {
        'idUsuario': idUsuarioAccionante,
      },
      'datos': datosPreparados,
    };

    final response = await http
        .put(
          uri,
          headers: _headers,
          body: jsonEncode(cuerpo),
        )
        .timeout(_timeout);

    _validarHttp(response, 'actualizar equipo');

    _validarRespuesta(
      utf8.decode(response.bodyBytes),
    );
  }

  // 7. BUSCAR EQUIPO POR CÓDIGO QR
  Future<EquipoModel> buscarPorQr(String codigoQR) async {
    if (codigoQR.trim().isEmpty) {
      throw Exception('El código QR está vacío.');
    }

    final uri = Uri.parse(
      '$_baseUrl/api/Equipo/qr/'
      '${Uri.encodeComponent(codigoQR.trim())}',
    );

    final response = await http
        .get(uri, headers: _headers)
        .timeout(_timeout);

    _validarHttp(response, 'buscar equipo por QR');

    dynamic respuesta = jsonDecode(
      utf8.decode(response.bodyBytes),
    );

    while (respuesta is List) {
      if (respuesta.isEmpty) {
        throw const FormatException(
          'No se encontró el equipo.',
        );
      }

      respuesta = respuesta.first;
    }

    if (respuesta is! Map) {
      throw const FormatException(
        'La API devolvió información inválida del equipo.',
      );
    }

    return EquipoModel.fromJson(
      Map<String, dynamic>.from(respuesta),
    );
  }

  // 8. VALIDAR RESPUESTA HTTP
  void _validarHttp(
    http.Response response,
    String operacion,
  ) {
    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      final mensaje = utf8.decode(response.bodyBytes);

      throw Exception(
        'Error al $operacion. '
        'HTTP ${response.statusCode}. $mensaje',
      );
    }
  }

  // 9. VALIDAR RESPUESTA DEL PROCEDIMIENTO ALMACENADO
  void _validarRespuesta(String contenido) {
    if (contenido.trim().isEmpty) return;

    dynamic respuesta;

    try {
      respuesta = jsonDecode(contenido);
    } on FormatException {
      throw const FormatException(
        'La API devolvió una respuesta JSON inválida.',
      );
    }

    if (respuesta is! Map) return;

    final exito = respuesta['exito'] ?? respuesta['Exito'];

    if (exito == false || exito == 0) {
      throw Exception(
        respuesta['mensaje'] ??
            respuesta['Mensaje'] ??
            'No se pudo completar la operación.',
      );
    }

    // El EquipoController devuelve los resultados del procedimiento
    // almacenado dentro de la propiedad "datos".
    final resultados = respuesta['datos'] ?? respuesta['Datos'];

    if (resultados is List) {
      for (final resultado in resultados) {
        if (resultado is Map) {
          final exitoso =
              resultado['exitoso'] ?? resultado['Exitoso'];

          if (exitoso == false || exitoso == 0) {
            throw Exception(
              resultado['mensaje'] ??
                  resultado['Mensaje'] ??
                  'El procedimiento almacenado no pudo completar la operación.',
            );
          }
        }
      }
    }
  }

  // 10. CONVERTIR RESPUESTAS JSON EN LISTAS
  List<Map<String, dynamic>> _extraerLista(String contenido) {
    dynamic respuesta;

    try {
      respuesta = jsonDecode(contenido);
    } on FormatException {
      throw const FormatException(
        'La API devolvió un JSON inválido.',
      );
    }

    dynamic lista = respuesta;

    // Procesar listas anidadas.
    while (lista is List &&
        lista.length == 1 &&
        lista.first is List) {
      lista = lista.first;
    }

    // Procesar respuestas envueltas en objetos.
    if (lista is Map) {
      lista = lista['value'] ??
          lista['Value'] ??
          lista['datos'] ??
          lista['Datos'] ??
          lista['data'] ??
          lista['Data'];
    }

    if (lista is! List) {
      throw const FormatException(
        'La API no devolvió una lista válida.',
      );
    }

    final registros = <Map<String, dynamic>>[];

    for (final elemento in lista) {
      if (elemento is! Map) {
        throw const FormatException(
          'La API devolvió un registro inválido.',
        );
      }

      registros.add(
        Map<String, dynamic>.from(elemento),
      );
    }

    return registros;
  }
}