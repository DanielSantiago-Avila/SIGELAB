import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:mssql_connection/mssql_connection.dart';
import '../coneccion_BD/db_config.dart';

class AuthService {
  final MssqlConnection _mssqlConnection = MssqlConnection.getInstance();

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> _conectarBD() async {
    Map<String, dynamic> config = await DBConfig.obtenerCredenciales();
    return await _mssqlConnection.connect(
      ip: config['Hostname'],
      port: config['Puerto'].toString(),
      databaseName: 'SIGELAB',
      username: config['Usuario'],
      password: config['Password'],
      timeoutInSeconds: 15,
    );
  }

  // 1. Iniciar sesión validando con el hash
  Future<Map<String, dynamic>> iniciarSesion(String usuario, String password) async {
    try {
      if (!await _conectarBD()) {
        return {'exito': false, 'mensaje': 'No se pudo conectar a la base de datos.'};
      }

      // Hashear la contraseña ingresada
      String passHash = _hashPassword(password);

      String query = "SELECT id_usuario, nombre, apellido, usuario, activo FROM dbo.Usuario WHERE usuario = '$usuario' AND password_hash = '$passHash'";
      String resultJson = await _mssqlConnection.getData(query);

      if (resultJson.isEmpty || resultJson == "[]") {
        return {'exito': false, 'mensaje': 'Usuario o contraseña incorrectos.'};
      }

      return {'exito': true, 'mensaje': 'Bienvenido a SIGELAB', 'datos': resultJson};
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error al iniciar sesión: $e'};
    }
  }

  // 2. Registrar usuario guardando la contraseña hasheada
  Future<Map<String, dynamic>> registrarUsuario({
    required String nombre,
    required String apellido,
    required String codigoPersonal,
    required String correo,
    required String usuario,
    required String password,
    int idRol = 1,
    int idTipoSolicitante = 1,
  }) async {
    try {
      if (!await _conectarBD()) {
        return {'exito': false, 'mensaje': 'No se pudo conectar a la base de datos.'};
      }

      // Hashear la contraseña antes de insertarla en la BD
      String passHash = _hashPassword(password);

      String queryInsert = '''
        INSERT INTO dbo.Usuario 
        (id_rol, id_tipo_solicitante, nombre, apellido, codigo_personal, correo, usuario, password_hash, activo, fecha_creacion)
        VALUES 
        ($idRol, $idTipoSolicitante, '$nombre', '$apellido', '$codigoPersonal', '$correo', '$usuario', '$passHash', 1, GETDATE());
      ''';

      String resultado = await _mssqlConnection.writeData(queryInsert);

      if (resultado.isNotEmpty && !resultado.toLowerCase().contains('error')) {
        return {'exito': true, 'mensaje': 'Usuario registrado exitosamente.'};
      } else {
        return {'exito': false, 'mensaje': 'Error en la BD: $resultado'};
      }
    } catch (e) {
      return {'exito': false, 'mensaje': 'Error al registrar usuario: $e'};
    }
  }
}