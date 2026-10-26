import 'package:flutter/material.dart';
import 'auth_service.dart';

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

  Future<void> _hacerRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    Map<String, dynamic> res = await _authService.registrarUsuario(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      codigoPersonal: _codigoController.text.trim(),
      correo: _correoController.text.trim(),
      usuario: _usuarioController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _cargando = false);

    if (!mounted) return;

    if (res['exito']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['mensaje']), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['mensaje']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro por Primera Vez')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: Theme.of(context).brightness == Brightness.dark ? 2 : 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _apellidoController,
                          decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _codigoController,
                          decoration: const InputDecoration(labelText: 'Código Personal', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _usuarioController,
                          decoration: const InputDecoration(labelText: 'Nuevo Usuario', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _ocultarPassword,
                          decoration: InputDecoration(
                            labelText: 'Nueva Contraseña',
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            suffixIcon: IconButton(
                              icon: Icon(_ocultarPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _cargando ? null : _hacerRegistro,
                            child: _cargando
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text('Crear Cuenta', style: TextStyle(fontSize: 16)),
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