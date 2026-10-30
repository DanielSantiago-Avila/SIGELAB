import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sigelab/login/login_screen.dart';
import 'package:sigelab/reconocimiento_facial/facial_recognition_screen.dart';
import 'package:sigelab/home/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  HttpOverrides.global = MyHttpOverrides();
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
          // Lee los argumentos enviados desde el Login (si los hay)
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          return FacialRecognitionScreen(
            idUsuario: args?['idUsuario'] ?? 1,
            esRegistro: args?['esRegistro'] ?? false,
            onSuccess: () {
              // AL VALIDAR EL ROSTRO CON ÉXITO: navega al menú principal
              Navigator.pushReplacementNamed(context, '/home');
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

      home: const LoginScreen(),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}