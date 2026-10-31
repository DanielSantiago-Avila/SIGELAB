import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../equipo_model.dart';

class EquipoQrDialog {
  static Future<void> mostrar(
    BuildContext context,
    EquipoModel equipo,
  ) async {
    final contenido = equipo.codigoQR.trim().isNotEmpty
        ? equipo.codigoQR
        : equipo.codigoInventario;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Código QR del equipo',
            style: TextStyle(
              color: Color(0xFF163C66),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: contenido,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  equipo.codigoInventario,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${equipo.marca} ${equipo.modelo}'.trim(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}