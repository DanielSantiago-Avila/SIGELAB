
class TipoEquipo {
  final int idTipoEquipo;
  final String codigo;
  final String nombre;
  final String? marca;
  final String? modelo;
  final String? descripcion;
  final bool activo;

  TipoEquipo({
    required this.idTipoEquipo,
    required this.codigo,
    required this.nombre,
    this.marca,
    this.modelo,
    this.descripcion,
    this.activo = true,
  });

  // Convertir la respuesta JSON del backend a Dart
  factory TipoEquipo.fromJson(Map<String, dynamic> json) {
    return TipoEquipo(
      idTipoEquipo: json['idTipoEquipo'] as int,
      codigo: json['codigo'] as String,
      nombre: json['nombre'] as String,
      marca: json['marca'] as String?,
      modelo: json['modelo'] as String?,
      descripcion: json['descripcion'] as String?,
      activo: json['activo'] == true ||
          json['activo'] == 1,
    );
  }

  // Convertir los datos de Dart a JSON
  Map<String, dynamic> toJson() {
    return {
      'idTipoEquipo': idTipoEquipo,
      'codigo': codigo,
      'nombre': nombre,
      'marca': marca,
      'modelo': modelo,
      'descripcion': descripcion,
      'activo': activo,
    };
  }

  // Crear una copia con valores actualizados
  TipoEquipo copyWith({
    int? idTipoEquipo,
    String? codigo,
    String? nombre,
    String? marca,
    String? modelo,
    String? descripcion,
    bool? activo,
  }) {
    return TipoEquipo(
      idTipoEquipo: idTipoEquipo ?? this.idTipoEquipo,
      codigo: codigo ?? this.codigo,
      nombre: nombre ?? this.nombre,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
    );
  }
}
