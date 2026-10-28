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
      idLaboratorio: json['id_laboratorio'] ?? json['idLaboratorio'] ?? 0,
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      ubicacion: json['ubicacion']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      activo: json['activo'] == true || json['activo'] == 1,
      capacidad: json['capacidad'] is int ? json['capacidad'] : int.tryParse(json['capacidad']?.toString() ?? '0') ?? 0,
    );
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