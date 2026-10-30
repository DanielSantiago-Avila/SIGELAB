import 'dart:convert';

import 'package:http/http.dart' as http;

/// Datos calculados para mostrar el resumen del inventario.
class DashboardResumen {
  final int totalEquipos;
  final int disponibles;
  final int prestados;
  final int danados;
  final int enMantenimiento;
  final int dadosDeBaja;
  final int otrosEstados;

  final int prestamosActivos;
  final int prestamosVencidos;
  final int mantenimientosAbiertos;

  final Map<String, int> equiposPorTipo;

  const DashboardResumen({
    required this.totalEquipos,
    required this.disponibles,
    required this.prestados,
    required this.danados,
    required this.enMantenimiento,
    required this.dadosDeBaja,
    required this.otrosEstados,
    required this.prestamosActivos,
    required this.prestamosVencidos,
    required this.mantenimientosAbiertos,
    required this.equiposPorTipo,
  });

  factory DashboardResumen.calcular({
    required List<Map<String, dynamic>> equipos,
    required List<Map<String, dynamic>> prestamos,
    required List<Map<String, dynamic>> mantenimientos,
  }) {
    int disponibles = 0;
    int prestados = 0;
    int danados = 0;
    int enMantenimiento = 0;
    int dadosDeBaja = 0;

    final Map<String, int> equiposPorTipo = {};

    for (final equipo in equipos) {
      final estado = _normalizar(equipo['estado']?.toString() ?? '');

      switch (estado) {
        case 'DISPONIBLE':
          disponibles++;
          break;
        case 'PRESTADO':
          prestados++;
          break;
        case 'DANADO':
          danados++;
          break;
        case 'MANTENIMIENTO':
          enMantenimiento++;
          break;
        case 'BAJA':
        case 'DADO DE BAJA':
          dadosDeBaja++;
          break;
      }

      final tipo = equipo['tipoEquipo']?.toString().trim();

      final nombreTipo = tipo == null || tipo.isEmpty ? 'Sin tipo' : tipo;

      equiposPorTipo.update(
        nombreTipo,
        (cantidad) => cantidad + 1,
        ifAbsent: () => 1,
      );
    }

    final otrosEstados =
        equipos.length -
        disponibles -
        prestados -
        danados -
        enMantenimiento -
        dadosDeBaja;

    final prestamosActivos = prestamos.where((prestamo) {
      return _normalizar(prestamo['estado']?.toString() ?? '') == 'ACTIVO';
    }).length;

    final ahora = DateTime.now();

    final prestamosVencidos = prestamos.where((prestamo) {
      final estado = _normalizar(prestamo['estado']?.toString() ?? '');

      final fecha = DateTime.tryParse(
        prestamo['fechaDevolucionEsperada']?.toString() ?? '',
      );

      return estado == 'ACTIVO' && fecha != null && fecha.isBefore(ahora);
    }).length;

    final mantenimientosAbiertos = mantenimientos.where((item) {
      return _normalizar(item['estadoMantenimiento']?.toString() ?? '') ==
          'ABIERTO';
    }).length;

    return DashboardResumen(
      totalEquipos: equipos.length,
      disponibles: disponibles,
      prestados: prestados,
      danados: danados,
      enMantenimiento: enMantenimiento,
      dadosDeBaja: dadosDeBaja,
      otrosEstados: otrosEstados,
      prestamosActivos: prestamosActivos,
      prestamosVencidos: prestamosVencidos,
      mantenimientosAbiertos: mantenimientosAbiertos,
      equiposPorTipo: equiposPorTipo,
    );
  }

  static String _normalizar(String texto) {
    return texto
        .trim()
        .toUpperCase()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N');
  }
}

/// Servicio encargado de consultar la información del Dashboard.
class DashboardService {
  static const String _baseUrl = 'http://18.119.123.181';

  Future<DashboardResumen> obtenerResumen() async {
    final resultados = await Future.wait<List<Map<String, dynamic>>>([
      _consultarLista('/api/Equipo'),
      _consultarLista('/api/Prestamo'),
      _consultarLista('/api/Mantenimiento'),
    ]);

    return DashboardResumen.calcular(
      equipos: resultados[0],
      prestamos: resultados[1],
      mantenimientos: resultados[2],
    );
  }

  Future<List<Map<String, dynamic>>> _consultarLista(String ruta) async {
    final uri = Uri.parse('$_baseUrl$ruta');

    final http.Response respuesta;

    try {
      respuesta = await http.get(uri).timeout(const Duration(seconds: 20));
    } catch (error) {
      throw Exception('No se pudo conectar con $ruta: $error');
    }

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error HTTP ${respuesta.statusCode} al consultar $ruta: '
        '${utf8.decode(respuesta.bodyBytes)}',
      );
    }

    final contenido = utf8.decode(respuesta.bodyBytes);

    final dynamic datos;

    try {
      datos = jsonDecode(contenido);
    } on FormatException {
      throw FormatException('La API devolvió JSON inválido en $ruta.');
    }

    dynamic lista;

    if (datos is List) {
      lista = datos;
    } else if (datos is Map) {
      // La respuesta observada en la terminal tiene:
      // { "value": [...], "Count": 10 }
      lista =
          datos['value'] ?? datos['Value'] ?? datos['datos'] ?? datos['data'];
    }

    if (lista is! List) {
      throw FormatException(
        'La respuesta de $ruta no contiene una lista válida.',
      );
    }

    return lista.map((elemento) {
      if (elemento is! Map) {
        throw FormatException('Se recibió un registro inválido en $ruta.');
      }

      return Map<String, dynamic>.from(elemento);
    }).toList();
  }
}
