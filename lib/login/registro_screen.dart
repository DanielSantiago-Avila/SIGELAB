
import 'package:flutter/material.dart';

import 'auth_service.dart';
import '../sesion/sesion_usuario.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _codigoController = TextEditingController();
  final _correoController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _cargando = false;
  bool _ocultarPassword = true;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _codigoController.dispose();
    _correoController.dispose();
    _usuarioController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTRAR NUEVO USUARIO
  // ============================================================

  Future<void> _hacerRegistro() async {
    if (_cargando) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _cargando = true;
    });

    Map<String, dynamic> respuesta;

    // ==========================================================
    // ENVIAR DATOS DE REGISTRO A LA API
    // ==========================================================

    try {
      respuesta = await _authService.registrarUsuario(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        codigoPersonal: _codigoController.text.trim(),
        correo: _correoController.text.trim(),
        usuario: _usuarioController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar usuario: $e'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    if (!mounted) return;

    setState(() {
      _cargando = false;
    });

    // ==========================================================
    // COMPROBAR RESPUESTA DEL REGISTRO
    // ==========================================================

    if (respuesta['exito'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            respuesta['mensaje']?.toString() ??
                'No fue posible registrar la cuenta.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    // ==========================================================
    // OBTENER ID DEL USUARIO CREADO
    // ==========================================================

    final idUsuario = AuthService.idUsuarioDesdeRespuesta(
      respuesta,
    );

    if (idUsuario == null || idUsuario <= 0) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cuenta creada'),
          content: const Text(
            'El servidor no devolvió un ID de usuario válido. '
            'No es posible asociar el rostro a esta cuenta. '
            'Es necesario revisar la respuesta del servicio de registro.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );

      if (mounted) {
        Navigator.pop(context);
      }

      return;
    }

    // ==========================================================
    // OBTENER INFORMACIÓN DEL USUARIO
    // ==========================================================

    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim();

    final nombreCompleto = '$nombre $apellido'.trim();

    final nombreUsuario = _usuarioController.text.trim();

    // ==========================================================
    // GUARDAR SESIÓN DEL NUEVO USUARIO
    // ==========================================================

    SesionUsuario.guardar(
      id: idUsuario,
      nombreUsuario: nombreUsuario,
      nombreCompleto: nombreCompleto,
    );

    debugPrint(
      'SESIÓN GUARDADA DESPUÉS DEL REGISTRO: '
      'ID ${SesionUsuario.idUsuario}',
    );

    // ==========================================================
    // ABRIR REGISTRO BIOMÉTRICO
    // ==========================================================

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      '/reconocimiento',
      arguments: {
        'idUsuario': idUsuario,
        'esRegistro': true,
      },
    );
  }

  // ============================================================
  // CONSTRUIR PANTALLA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro por Primera Vez'),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
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

                  child: Form(
                    key: _formKey,

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // ==================================================
                        // NOMBRE
                        // ==================================================

                        TextFormField(
                          controller: _nombreController,
                          enabled: !_cargando,
                          textInputAction: TextInputAction.next,

                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),

                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Campo requerido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // APELLIDO
                        // ==================================================

                        TextFormField(
                          controller: _apellidoController,
                          enabled: !_cargando,
                          textInputAction: TextInputAction.next,

                          decoration: const InputDecoration(
                            labelText: 'Apellido',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),

                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Campo requerido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // CÓDIGO PERSONAL
                        // ==================================================

                        TextFormField(
                          controller: _codigoController,
                          enabled: !_cargando,
                          textInputAction: TextInputAction.next,

                          decoration: const InputDecoration(
                            labelText: 'Código Personal',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),

                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Campo requerido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // CORREO ELECTRÓNICO
                        // ==================================================

                        TextFormField(
                          controller: _correoController,
                          enabled: !_cargando,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,

                          decoration: const InputDecoration(
                            labelText: 'Correo Electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),

                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Campo requerido';
                            }

                            final correo = v.trim();

                            if (!correo.contains('@') ||
                                !correo.contains('.')) {
                              return 'Correo inválido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // USUARIO
                        // ==================================================

                        TextFormField(
                          controller: _usuarioController,
                          enabled: !_cargando,
                          textInputAction: TextInputAction.next,

                          decoration: const InputDecoration(
                            labelText: 'Nuevo Usuario',
                            prefixIcon: Icon(
                              Icons.account_circle_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),

                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Campo requerido';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ==================================================
                        // CONTRASEÑA
                        // ==================================================

                        TextFormField(
                          controller: _passwordController,
                          enabled: !_cargando,
                          obscureText: _ocultarPassword,
                          textInputAction: TextInputAction.done,

                          onFieldSubmitted: (_) {
                            if (!_cargando) {
                              _hacerRegistro();
                            }
                          },

                          decoration: InputDecoration(
                            labelText: 'Nueva Contraseña',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                            ),

                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),

                            suffixIcon: IconButton(
                              icon: Icon(
                                _ocultarPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),

                              onPressed: _cargando
                                  ? null
                                  : () {
                                      setState(() {
                                        _ocultarPassword =
                                            !_ocultarPassword;
                                      });
                                    },
                            ),
                          ),

                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Campo requerido';
                            }

                            if (v.trim().length < 6) {
                              return 'Mínimo 6 caracteres';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // BOTÓN CREAR CUENTA
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 48,

                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),

                            onPressed:
                                _cargando ? null : _hacerRegistro,

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
                                    'Crear Cuenta',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
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
      ),
    );
  }
}
