class Laboratorio {
  final int idLaboratorio;
  final String codigo;
  final String nombre;
  final String ubicacion;
  final String descripcion;
  final bool? activo;
  final int capacidad;

  const Laboratorio({
    this.idLaboratorio = 0,
    required this.codigo,
    required this.nombre,
    required this.ubicacion,
    required this.descripcion,
    required this.activo,
    required this.capacidad,
  });

  factory Laboratorio.fromJson(Map<String, dynamic> json) {
    return Laboratorio(
      idLaboratorio: _convertirEntero(
        _obtenerValor(json, [
          'idLaboratorio',
          'id_laboratorio',
          'IdLaboratorio',
          'ID_LABORATORIO',
        ]),
      ),
      codigo: _convertirTexto(
        _obtenerValor(json, ['codigo', 'Codigo', 'Código']),
      ),
      nombre: _convertirTexto(
        _obtenerValor(json, ['nombre', 'Nombre']),
      ),
      ubicacion: _convertirTexto(
        _obtenerValor(json, ['ubicacion', 'Ubicacion', 'Ubicación']),
      ),
      descripcion: _convertirTexto(
        _obtenerValor(json, ['descripcion', 'Descripcion', 'Descripción']),
      ),
      activo: _convertirBooleano(
        _obtenerValor(json, ['activo', 'Activo']),
      ),
      capacidad: _convertirEntero(
        _obtenerValor(json, ['capacidad', 'Capacidad']),
      ),
    );
  }

  // ============================================================
  // OBTENER VALORES CON DISTINTOS NOMBRES DE PROPIEDADES
  // ============================================================

  static dynamic _obtenerValor(
    Map<String, dynamic> json,
    List<String> posiblesClaves,
  ) {
    for (final clave in posiblesClaves) {
      if (json.containsKey(clave)) {
        return json[clave];
      }
    }

    return null;
  }

  // ============================================================
  // CONVERTIR TEXTO
  // ============================================================

  static String _convertirTexto(dynamic valor) {
    return valor?.toString().trim() ?? '';
  }

  // ============================================================
  // CONVERTIR NÚMEROS ENTEROS
  // ============================================================

  static int _convertirEntero(dynamic valor) {
    if (valor == null) {
      return 0;
    }

    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.toInt();
    }

    final texto = valor.toString().trim();

    return int.tryParse(texto) ??
        double.tryParse(texto)?.toInt() ??
        0;
  }

  // ============================================================
  // CONVERTIR ESTADO BOOLEANO
  // ============================================================

  static bool? _convertirBooleano(dynamic valor) {
    if (valor == null) {
      return null;
    }

    if (valor is bool) {
      return valor;
    }

    if (valor is num) {
      return valor != 0;
    }

    final texto = valor.toString().trim().toLowerCase();

    switch (texto) {
      case 'true':
      case '1':
      case 'activo':
      case 'sí':
      case 'si':
        return true;

      case 'false':
      case '0':
      case 'inactivo':
      case 'no':
        return false;

      default:
        return null;
    }
  }
}