class SesionUsuario {
  static int? idUsuario;
  static String? nombre;
  static String? usuario;

  static bool get tieneSesion => idUsuario != null;

  static void guardar({
    required int id,
    String? nombreUsuario,
    String? nombreCompleto,
  }) {
    idUsuario = id;
    usuario = nombreUsuario;
    nombre = nombreCompleto;
  }

  static void cerrarSesion() {
    idUsuario = null;
    usuario = null;
    nombre = null;
  }
}
