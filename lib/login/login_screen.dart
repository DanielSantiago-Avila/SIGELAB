import 'dart:convert';

import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'registro_screen.dart';
import '../sesion/sesion_usuario.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _cargando = false;
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _usuarioController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // INICIAR SESIÓN Y ACCEDER DIRECTAMENTE AL MENÚ PRINCIPAL
  Future<void> _hacerLogin() async {
    final usuario = _usuarioController.text.trim();
    final password = _passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa usuario y contraseña'),
        ),
      );
      return;
    }

    setState(() {
      _cargando = true;
    });

    Map<String, dynamic> respuesta;

    try {
      respuesta = await _authService.iniciarSesion(
        usuario,
        password,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _cargando = false;
    });

    // COMPROBAR RESPUESTA DEL LOGIN
    if (respuesta['exito'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            respuesta['mensaje'] ?? 'Error al iniciar sesión',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // PROCESAR LOS DATOS DEL USUARIO
    final datosRaw = respuesta['datos'];

    Map<String, dynamic> datosLogin;

    try {
      if (datosRaw is String) {
        datosLogin = Map<String, dynamic>.from(
          jsonDecode(datosRaw) as Map,
        );
      } else if (datosRaw is Map) {
        datosLogin = Map<String, dynamic>.from(datosRaw);
      } else {
        throw const FormatException(
          'Formato de datos de usuario inválido.',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudieron procesar los datos del usuario: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // OBTENER ID DEL USUARIO
    final idRaw = datosLogin['id_usuario'] ??
        datosLogin['idUsuario'];

    final idUsuario = int.tryParse(idRaw?.toString() ?? '');

    if (idUsuario == null || idUsuario <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se recibió un ID de usuario válido.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // OBTENER INFORMACIÓN DEL USUARIO
    final nombre = datosLogin['nombre']?.toString() ?? '';
    final apellido = datosLogin['apellido']?.toString() ?? '';

    final nombreCompleto = '$nombre $apellido'.trim();

    final nombreUsuario =
        datosLogin['usuario']?.toString() ?? nombreCompleto;

    // GUARDAR SESIÓN
    SesionUsuario.guardar(
      id: idUsuario,
      nombreUsuario: nombreUsuario,
      nombreCompleto: nombreCompleto,
    );

    debugPrint(
      'SESIÓN GUARDADA: ID ${SesionUsuario.idUsuario}',
    );

    // ACCESO DIRECTO AL MENÚ PRINCIPAL
    // RECONOCIMIENTO FACIAL DESACTIVADO TEMPORALMENTE

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          respuesta['mensaje'] ?? '¡Bienvenido!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Card(
                elevation:
                    Theme.of(context).brightness == Brightness.dark
                        ? 2
                        : 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.school,
                        size: 70,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'SIGELAB',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // USUARIO
                      TextField(
                        controller: _usuarioController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Usuario',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // CONTRASEÑA
                      TextField(
                        controller: _passwordController,
                        obscureText: _ocultarPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!_cargando) {
                            _hacerLogin();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarPassword = !_ocultarPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // BOTÓN INICIAR SESIÓN
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _cargando ? null : _hacerLogin,
                          child: _cargando
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Iniciar Sesión',
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // REGISTRO
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RegistroScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '¿Es tu primera vez aquí? Regístrate',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}