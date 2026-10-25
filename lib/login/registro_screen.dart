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
      Navigator.pop(context); // Regresar al Login tras crear el usuario
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _apellidoController,
                decoration: const InputDecoration(labelText: 'Apellido', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Código Personal', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _correoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Correo Electrónico', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usuarioController,
                decoration: const InputDecoration(labelText: 'Nuevo Usuario', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Nueva Contraseña',
                  border: const OutlineInputBorder(),
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
                  onPressed: _cargando ? null : _hacerRegistro,
                  child: _cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('Crear Cuenta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}