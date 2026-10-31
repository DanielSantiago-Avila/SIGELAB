import 'dart:io';

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
  final QrEquipoService _equipoService = QrEquipoService();

  final TextEditingController _codigoController = TextEditingController();

  // En macOS no inicializamos la cámara.
  late final MobileScannerController? _controller = Platform.isMacOS
      ? null
      : MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          formats: [BarcodeFormat.qrCode],
        );

  bool _procesando = false;

  Future<void> _consultarCodigo(String codigo) async {
    final codigoLimpio = codigo.trim();

    if (_procesando || codigoLimpio.isEmpty) return;

    setState(() => _procesando = true);

    try {
      if (_controller != null) {
        await _controller.stop();
      }

      if (!mounted) return;

      final equipo = await _equipoService.obtenerEquipoPorQr(codigoLimpio);

      if (!mounted) return;

      // Si venimos desde Préstamos, devolvemos el equipo.
      if (widget.modoSeleccion) {
        Navigator.pop(context, equipo);
        return;
      }

      // En modo normal mostramos el resultado del QR.
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

        if (_controller != null) {
          try {
            await _controller.start();
          } catch (_) {
            // La cámara puede no estar disponible.
          }
        }
      }
    }
  }

  Future<void> _detectarCodigo(BarcodeCapture capture) async {
    if (_procesando) return;

    for (final barcode in capture.barcodes) {
      final valor = barcode.rawValue?.trim();

      if (valor != null && valor.isNotEmpty) {
        await _consultarCodigo(valor);
        return;
      }
    }
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Widget _construirEntradaMac() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 72,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),

                  Text(
                    widget.modoSeleccion
                        ? 'Seleccionar equipo'
                        : 'Consultar equipo por QR',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Introduce el código QR del equipo '
                    'para consultar su información.',
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  TextField(
                    controller: _codigoController,
                    enabled: !_procesando,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      labelText: 'Código QR',
                      hintText: 'Ejemplo: DEMO26-QR-E02',
                      prefixIcon: Icon(Icons.qr_code),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _consultarCodigo,
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _procesando
                          ? null
                          : () => _consultarCodigo(_codigoController.text),
                      icon: _procesando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(
                        _procesando ? 'Consultando...' : 'Consultar equipo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _construirScannerMovil() {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller!,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.modoSeleccion ? 'Seleccionar equipo' : 'Escanear QR',
        ),
      ),
      body: Platform.isMacOS
          ? _construirEntradaMac()
          : _construirScannerMovil(),
    );
  }
}
