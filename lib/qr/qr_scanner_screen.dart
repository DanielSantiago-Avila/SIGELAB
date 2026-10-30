
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [BarcodeFormat.qrCode],
  );

  bool _procesando = false;

  Future<void> _detectarCodigo(BarcodeCapture capture) async {
    if (_procesando) return;

    String? codigo;

    for (final barcode in capture.barcodes) {
      final valor = barcode.rawValue;
      if (valor != null && valor.isNotEmpty) {
        codigo = valor;
        break;
      }
    }

    if (codigo == null) return;

    _procesando = true;
    await _controller.stop();

    if (!mounted) return;

    final codigoLeido = codigo;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Código QR detectado'),
        content: SelectableText(codigoLeido),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Escanear otro'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    _procesando = false;
    await _controller.start();
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
        title: const Text('Escanear QR'),
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
          const Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Apunta la cámara hacia el código QR del equipo.',
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
