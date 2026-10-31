class EquipoMantenimiento {
  final int idEquipo;
  final String codigoInventario;
  final String codigoQR;
  final String estado;
  final String tipoEquipo;
  final String laboratorio;
  final String observaciones;

  const EquipoMantenimiento({
    required this.idEquipo,
    required this.codigoInventario,
    required this.codigoQR,
    required this.estado,
    required this.tipoEquipo,
    required this.laboratorio,
    required this.observaciones,
  });

  factory EquipoMantenimiento.fromJson(Map<String, dynamic> json) {
    return EquipoMantenimiento(
      idEquipo: _entero(json['idEquipo']),
      codigoInventario: json['codigoInventario']?.toString() ?? '',
      codigoQR: json['codigoQR']?.toString() ?? '',
      estado: json['estado']?.toString() ?? 'DESCONOCIDO',
      tipoEquipo: json['tipoEquipo']?.toString() ?? 'Sin tipo',
      laboratorio: json['laboratorio']?.toString() ?? 'Sin laboratorio',
      observaciones: json['observaciones']?.toString() ?? '',
    );
  }

  static int _entero(dynamic valor) {
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }
}

class Mantenimiento {
  final int idMantenimiento;
  final int idEquipo;
  final String codigoInventario;
  final String codigoQR;
  final int idUsuarioResponsable;
  final String responsable;
  final String tipo;
  final String descripcion;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String? resultado;
  final String observaciones;
  final String estadoMantenimiento;
  final String estadoEquipo;
  final bool equipoActivo;

  const Mantenimiento({
    required this.idMantenimiento,
    required this.idEquipo,
    required this.codigoInventario,
    required this.codigoQR,
    required this.idUsuarioResponsable,
    required this.responsable,
    required this.tipo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaFin,
    required this.resultado,
    required this.observaciones,
    required this.estadoMantenimiento,
    required this.estadoEquipo,
    required this.equipoActivo,
  });

  factory Mantenimiento.fromJson(Map<String, dynamic> json) {
    return Mantenimiento(
      idMantenimiento: _entero(json['idMantenimiento']),
      idEquipo: _entero(json['idEquipo']),
      codigoInventario: json['codigoInventario']?.toString() ?? '',
      codigoQR: json['codigoQR']?.toString() ?? '',
      idUsuarioResponsable: _entero(json['idUsuarioResponsable']),
      responsable: json['responsable']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      fechaInicio: DateTime.tryParse(json['fechaInicio']?.toString() ?? ''),
      fechaFin: DateTime.tryParse(json['fechaFin']?.toString() ?? ''),
      resultado: json['resultado']?.toString(),
      observaciones: json['observaciones']?.toString() ?? '',
      estadoMantenimiento: json['estadoMantenimiento']?.toString() ?? '',
      estadoEquipo: json['estadoEquipo']?.toString() ?? '',
      equipoActivo: _booleano(json['equipoActivo']),
    );
  }

  static int _entero(dynamic valor) {
    if (valor is num) return valor.toInt();
    return int.tryParse(valor?.toString() ?? '') ?? 0;
  }

  static bool _booleano(dynamic valor) {
    if (valor is bool) return valor;
    if (valor is num) return valor != 0;

    final texto = valor?.toString().toLowerCase().trim();
    return texto == 'true' || texto == '1';
  }
}
