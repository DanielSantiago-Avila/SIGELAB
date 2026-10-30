import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'qr_equipo_service.dart';
import 'qr_resultado_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final bool modoSeleccion;

  const QrScannerScreen({super.key, this.modoSeleccion = false});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  final QrEquipoService _equipoService = QrEquipoService();

  bool _procesando = false;

  Future<void> _detectarCodigo(BarcodeCapture capture) async {
    if (_procesando) return;

    String? codigo;

    for (final barcode in capture.barcodes) {
      final valor = barcode.rawValue?.trim();

      if (valor != null && valor.isNotEmpty) {
        codigo = valor;
        break;
      }
    }

    if (codigo == null) return;

    setState(() => _procesando = true);

    try {
      await _controller.stop();

      if (!mounted) return;

      final equipo = await _equipoService.obtenerEquipoPorQr(codigo);

      if (!mounted) return;

      if (widget.modoSeleccion) {
        Navigator.pop(context, equipo);
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QrResultadoScreen(equipo: equipo)),
      );
    } catch (error) {
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('No se pudo consultar el equipo'),
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
        setState(() => _procesando = false);

        try {
          await _controller.start();
        } catch (_) {
          // La cámara puede no estar disponible al regresar.
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modoSeleccion ? 'Seleccionar equipo' : 'Escanear QR',
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _detectarCodigo,
            errorBuilder: (context, error) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No se pudo abrir la cámara: $error',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),

          if (_procesando)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x99000000),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        'Consultando equipo...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    widget.modoSeleccion
                        ? 'Escanea el QR del equipo que deseas prestar.'
                        : 'Apunta la cámara hacia el código QR del equipo.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
