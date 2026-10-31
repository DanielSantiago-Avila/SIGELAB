
class SesionUsuario {
  static int? idUsuario;
  static String? nombre;
  static String? usuario;

  // Guardar el rol del usuario que inició sesión
  static int? idRol;

  // Verificar si existe una sesión activa
  static bool get tieneSesion => idUsuario != null;

  // Verificar si el usuario tiene rol de ADMIN
  static bool get esAdministrador =>
      tieneSesion && idRol == 1;

  // Guardar la información del usuario autenticado
  static void guardar({
    required int id,
    String? nombreUsuario,
    String? nombreCompleto,
    int? rol,
  }) {
    idUsuario = id;
    usuario = nombreUsuario;
    nombre = nombreCompleto;
    idRol = rol;
  }

  // Limpiar la información al cerrar sesión
  static void cerrarSesion() {
    idUsuario = null;
    usuario = null;
    nombre = null;
    idRol = null;
  }
}
