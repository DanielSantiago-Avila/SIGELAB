import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'registro_screen.dart';

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

  Future<void> _hacerLogin() async {
    String usuario = _usuarioController.text.trim();
    String password = _passwordController.text.trim();

    if (usuario.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa usuario y contraseña')),
      );
      return;
    }

    setState(() => _cargando = true);
    Map<String, dynamic> res = await _authService.iniciarSesion(usuario, password);
    setState(() => _cargando = false);

    if (!mounted) return;

    if (res['exito']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['mensaje']), backgroundColor: Colors.green),
      );
      // TODO: Navegar a tu vista principal / Home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['mensaje']), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              const Text('SIGELAB', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(
                controller: _usuarioController,
                decoration: const InputDecoration(labelText: 'Usuario', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _ocultarPassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultarPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _cargando ? null : _hacerLogin,
                  child: _cargando ? const CircularProgressIndicator(color: Colors.white) : const Text('Iniciar Sesión'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegistroScreen()),
                  );
                },
                child: const Text('¿Es tu primera vez aquí? Regístrate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}