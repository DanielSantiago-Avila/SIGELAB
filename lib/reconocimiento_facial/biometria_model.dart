class BiometriaUsuario {
  final int idBiometria;
  final int idUsuario;
  final String vectorFacial; // O formato Base64/Hash de la biometría
  final DateTime fechaRegistro;

  BiometriaUsuario({
    required this.idBiometria,
    required this.idUsuario,
    required this.vectorFacial,
    required this.fechaRegistro,
  });

  factory BiometriaUsuario.fromJson(Map<String, dynamic> json) {
    return BiometriaUsuario(
      idBiometria: json['id_biometria'] ?? 0,
      idUsuario: json['id_usuario'] ?? 0,
      vectorFacial: json['vector_facial'] ?? '',
      fechaRegistro: DateTime.parse(json['fecha_registro']),
    );
  }
}