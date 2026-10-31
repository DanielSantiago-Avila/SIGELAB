import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:sigelab/login/login_screen.dart';
import 'package:sigelab/reconocimiento_facial/facial_recognition_screen.dart';
import 'package:sigelab/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGELAB',
      debugShowCheckedModeBanner: false,

      // ======================================================
      // TEMA DE LA APLICACIÓN
      // ======================================================

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),

      initialRoute: '/',

      // ======================================================
      // RUTAS DE LA APLICACIÓN
      // ======================================================

      routes: {
        // INICIO DE SESIÓN

        '/': (context) => const LoginScreen(),

        // ====================================================
        // RECONOCIMIENTO FACIAL
        // ====================================================

        '/reconocimiento': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments;

          // Verificar que se recibieron los argumentos.

          if (args is! Map) {
            return _pantallaErrorAutenticacion(context);
          }

          // Obtener y validar el ID del usuario.

          final idRaw = args['idUsuario'];

          final idUsuario = idRaw is int
              ? idRaw
              : int.tryParse(idRaw?.toString() ?? '');

          if (idUsuario == null || idUsuario <= 0) {
            return _pantallaErrorAutenticacion(context);
          }

          // Determinar si se trata de un registro biométrico.

          final esRegistro = args['esRegistro'] == true;

          return FacialRecognitionScreen(
            idUsuario: idUsuario,
            esRegistro: esRegistro,

            // Al completar correctamente el reconocimiento,
            // acceder al menú principal.

            onSuccess: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
          );
        },

        // ====================================================
        // MENÚ PRINCIPAL
        // ====================================================

        '/home': (context) => const HomeScreen(),
      },

      // ======================================================
      // CONFIGURACIÓN DE IDIOMA
      // ======================================================

      locale: const Locale('es', 'GT'),

      supportedLocales: const [
        Locale('es', 'GT'),
        Locale('es'),
        Locale('en', 'US'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }

  // ==========================================================
  // PANTALLA DE ERROR DE AUTENTICACIÓN
  // ==========================================================

  Widget _pantallaErrorAutenticacion(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error de autenticación'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),

              const SizedBox(height: 16),

              const Text(
                'No se recibió un ID de usuario válido '
                'para la operación facial.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  );
                },
                child: const Text(
                  'Volver al inicio de sesión',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}