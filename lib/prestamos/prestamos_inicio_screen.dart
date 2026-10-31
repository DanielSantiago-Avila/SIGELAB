import 'package:flutter/material.dart';

import '../qr/qr_scanner_screen.dart';
import 'prestamo_screen.dart';

import '../sesion/sesion_usuario.dart';

class PrestamosInicioScreen extends StatefulWidget {
  const PrestamosInicioScreen({super.key});

  @override
  State<PrestamosInicioScreen> createState() => _PrestamosInicioScreenState();
}

class _PrestamosInicioScreenState extends State<PrestamosInicioScreen> {
  bool _abriendoEscaner = false;

  Future<void> _escanearEquipo() async {
    if (_abriendoEscaner) return;

    setState(() {
      _abriendoEscaner = true;
    });

    try {
      final equipo = await Navigator.push<Map<String, dynamic>>(
        context,
        MaterialPageRoute(
          builder: (_) => const QrScannerScreen(modoSeleccion: true),
        ),
      );

      if (!mounted || equipo == null) return;

      final idEquipo = equipo['idEquipo'];
      final idTipoEquipo = equipo['idTipoEquipo'];
      final codigoQr = equipo['codigoQR']?.toString();

      if (idEquipo is! int ||
          idTipoEquipo is! int ||
          codigoQr == null ||
          codigoQr.trim().isEmpty) {
        throw const FormatException(
          'La API no devolvió todos los datos '
          'necesarios para iniciar el préstamo '
          '(idEquipo, idTipoEquipo y codigoQR).',
        );
      }

        final idUsuario = SesionUsuario.idUsuario;

        if (idUsuario == null || idUsuario <= 0) {
          throw const FormatException(
            'No se encontró una sesión de usuario válida.',
          );
        }

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PrestamoScreen(
              equipo: equipo,
              idUsuarioAccionante: idUsuario,
            ),
          ),
        );
    } catch (error) {
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('No se pudo iniciar el préstamo'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _abriendoEscaner = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF163C66);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 72,
              color: colorPrincipal,
            ),

            const SizedBox(height: 20),

            const Text(
              'Gestión de Préstamos',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: colorPrincipal,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Escanea el código QR del equipo '
              'que deseas prestar.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _abriendoEscaner ? null : _escanearEquipo,
                icon: _abriendoEscaner
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.qr_code_scanner),
                label: Text(
                  _abriendoEscaner
                      ? 'Abriendo escáner...'
                      : 'Escanear equipo para préstamo',
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Después de escanear el equipo podrás '
              'seleccionar al solicitante, establecer '
              'la fecha de devolución y agregar '
              'observaciones.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
