class Laboratorio {
  final int idLaboratorio;
  final String codigo;
  final String nombre;
  final String ubicacion;
  final String descripcion;
  final bool activo;
  final int capacidad;

  Laboratorio({
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
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      ubicacion: json['ubicacion']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      activo: _convertirBooleano(json['activo']),
      capacidad: _convertirEntero(json['capacidad']),
    );
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

  static bool _convertirBooleano(dynamic valor) {
    if (valor is bool) {
      return valor;
    }

    if (valor is num) {
      return valor != 0;
    }

    final texto = valor?.toString().toLowerCase().trim();

    return texto == 'true' || texto == '1';
  }

  Map<String, dynamic> toJson() {
    return {
      if (idLaboratorio > 0) 'id_laboratorio': idLaboratorio,
      'codigo': codigo,
      'nombre': nombre,
      'ubicacion': ubicacion,
      'descripcion': descripcion,
      'activo': activo,
      'capacidad': capacidad,
    };
  }
}
