import 'package:flutter/material.dart';
import 'package:sigelab/login/login_screen.dart';
import 'package:sigelab/reconocimiento_facial/facial_recognition_screen.dart';
import 'package:sigelab/home/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', // Inicia en el Login
      routes: {
        '/': (context) => const LoginScreen(),

        '/reconocimiento': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is! Map || args['idUsuario'] is! int) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error de autenticación')),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'No se recibió un ID de usuario válido para la operación facial.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                        child: const Text('Volver al inicio de sesión'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return FacialRecognitionScreen(
            idUsuario: args['idUsuario'] as int,
            esRegistro: args['esRegistro'] == true,
            onSuccess: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (_) => false,
              );
            },
          );
        },
        '/home': (context) => const HomeScreen(),
      },

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
}