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
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _apellidoController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Apellido',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _codigoController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Código Personal',
                            prefixIcon: Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _correoController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Correo Electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Campo requerido';
                            if (!v.contains('@') || !v.contains('.')) return 'Correo inválido';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _usuarioController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nuevo Usuario',
                            prefixIcon: Icon(Icons.account_circle_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _ocultarPassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _cargando ? null : _hacerRegistro(),
                          decoration: InputDecoration(
                            labelText: 'Nueva Contraseña',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                            suffixIcon: IconButton(
                              icon: Icon(_ocultarPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Campo requerido';
                            if (v.trim().length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
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
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
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