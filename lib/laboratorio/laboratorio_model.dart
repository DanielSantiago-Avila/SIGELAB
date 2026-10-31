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
        json['idLaboratorio'] ?? json['id_laboratorio'],
      ),
      codigo: _convertirTexto(json['codigo']),
      nombre: _convertirTexto(json['nombre']),
      ubicacion: _convertirTexto(json['ubicacion']),
      descripcion: _convertirTexto(json['descripcion']),
      activo: _convertirBooleano(json['activo']),
      capacidad: _convertirEntero(json['capacidad']),
    );
  }

  static String _convertirTexto(dynamic valor) {
    return valor?.toString().trim() ?? '';
  }

  static int _convertirEntero(dynamic valor) {
    if (valor is int) {
      return valor;
    }

    if (valor is num) {
      return valor.toInt();
    }

    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

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

    if (texto == 'true' || texto == '1') {
      return true;
    }

    if (texto == 'false' || texto == '0') {
      return false;
    }

    return null;
  }
}
