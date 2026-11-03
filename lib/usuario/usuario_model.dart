
class Usuario {
  final int idUsuario;
  final String nombre;
  final String apellido;
  final String codigoPersonal;
  final String correo;
  final String usuario;
  final int idRol;
  final String rol;
  final int? idTipoSolicitante;
  final String? tipoSolicitante;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaActualizacion;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.apellido,
    required this.codigoPersonal,
    required this.correo,
    required this.usuario,
    required this.idRol,
    required this.rol,
    this.idTipoSolicitante,
    this.tipoSolicitante,
    required this.activo,
    this.fechaCreacion,
    this.fechaActualizacion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: (json['idUsuario'] as num).toInt(),
      nombre: json['nombre']?.toString() ?? '',
      apellido: json['apellido']?.toString() ?? '',
      codigoPersonal:
          json['codigoPersonal']?.toString() ?? '',
      correo: json['correo']?.toString() ?? '',
      usuario: json['usuario']?.toString() ?? '',
      idRol: (json['idRol'] as num).toInt(),
      rol: json['rol']?.toString() ?? '',
      idTipoSolicitante:
          (json['idTipoSolicitante'] as num?)?.toInt(),
      tipoSolicitante:
          json['tipoSolicitante']?.toString(),
      activo: json['activo'] == true ||
          json['activo'] == 1,
      fechaCreacion: DateTime.tryParse(
        json['fechaCreacion']?.toString() ?? '',
      ),
      fechaActualizacion: DateTime.tryParse(
        json['fechaActualizacion']?.toString() ?? '',
      ),
    );
  }

  String get nombreCompleto => '$nombre $apellido'.trim();
}
