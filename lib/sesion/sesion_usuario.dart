class SesionUsuario {
  static int? idUsuario;
  static String? nombre;
  static String? usuario;

  static int? idRol;
  static String? nombreRol;

  static bool get tieneSesion => idUsuario != null;

  static bool get esAdministrador =>
      tieneSesion && idRol == 1;

  static bool get esEncargado =>
      tieneSesion && idRol == 2;

  static bool get esSolicitante =>
      tieneSesion && idRol == 3;

  static void guardar({
    required int id,
    String? nombreUsuario,
    String? nombreCompleto,
    int? rol,
    String? nombreDelRol,
  }) {
    idUsuario = id;
    usuario = nombreUsuario;
    nombre = nombreCompleto;
    idRol = rol;
    nombreRol = nombreDelRol;

    print('SESIÓN GUARDADA');
    print('ID Usuario: $idUsuario');
    print('ID Rol: $idRol');
    print('Nombre Rol: $nombreRol');
    print('Es Administrador: $esAdministrador');
  }

  static void cerrarSesion() {
    idUsuario = null;
    usuario = null;
    nombre = null;
    idRol = null;
    nombreRol = null;
  }
}