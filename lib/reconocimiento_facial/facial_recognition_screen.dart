import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'biometria_service.dart';

class FacialRecognitionScreen extends StatefulWidget {
  final int idUsuario;
  final bool esRegistro; // true: Registra rostro nuevo | false: Valida login
  final VoidCallback onSuccess;

  const FacialRecognitionScreen({
    super.key,
    required this.idUsuario,
    this.esRegistro = false,
    required this.onSuccess,
  });

  @override
  State<FacialRecognitionScreen> createState() =>
      _FacialRecognitionScreenState();
}

class _FacialRecognitionScreenState extends State<FacialRecognitionScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _cargando = false;
  String? _cameraError;
  final BiometriaService _biometriaService = BiometriaService();
  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        // Selecciona la cámara frontal
        final frontCamera = _cameras!.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (!mounted) return;
        setState(() {
          _cameraError = null;
          _isCameraInitialized = true;
        });
      } else {
        throw StateError('No se encontraron cámaras disponibles.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cameraError = 'No se pudo iniciar la cámara: $e';
        _isCameraInitialized = false;
      });
    }
  }

  Future<void> _procesarRostro() async {
    if (_controller == null || !_controller!.value.isInitialized || _cargando) {
      return;
    }

    setState(() => _cargando = true);

    try {
      if (_controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }

      final XFile photo = await _controller!.takePicture();
      final imagenFile = File(photo.path);
      Map<String, dynamic> respuesta;
      var fueRegistro = widget.esRegistro;

      if (widget.esRegistro) {
        respuesta = await _biometriaService.registrarBiometria(
          imagenFile: imagenFile,
          idUsuario: widget.idUsuario,
        );
      } else {
        respuesta = await _biometriaService.validarBiometria(
          imagenFile: imagenFile,
          idUsuario: widget.idUsuario,
        );

        if (respuesta['requiere_registro'] == true && mounted) {
          final registrar =
              await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Rostro sin registrar'),
                  content: Text(
                    '${respuesta['mensaje'] ?? 'No hay un rostro asociado a esta cuenta.'} '
                    '¿Quieres registrar ahora la foto capturada?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Ahora no'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Registrar rostro'),
                    ),
                  ],
                ),
              ) ??
              false;

          if (!mounted) return;
          if (registrar) {
            fueRegistro = true;
            respuesta = await _biometriaService.registrarBiometria(
              imagenFile: imagenFile,
              idUsuario: widget.idUsuario,
            );
          }
        }
      }

      final resultado =
          respuesta['exito'] == true &&
          (fueRegistro || respuesta['es_valido'] == true);

      if (!mounted) return;
      setState(() => _cargando = false);

      if (resultado) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Éxito', textAlign: TextAlign.center),
            content: Text(
              fueRegistro
                  ? 'Su rostro ha sido registrado correctamente en el sistema.'
                  : 'Rostro reconocido con éxito. ¡Bienvenido al sistema!',
              textAlign: TextAlign.center,
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onSuccess();
                  },
                  child: const Text(
                    'Continuar al Home',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              respuesta['mensaje']?.toString() ??
                  (fueRegistro
                      ? 'El servidor no confirmó el registro biométrico.'
                      : 'Reconocimiento facial no coincide. Acceso denegado.'),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la solicitud facial: $e')),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.esRegistro ? 'Registro Biométrico' : 'Validación Biométrica',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.esRegistro
                    ? 'Posicione su rostro frente a la cámara para registrarlo'
                    : 'Alinee su rostro en el recuadro para validar su ingreso',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Círculo/Recuadro con el preview de la cámara en vivo
              Container(
                width: 280,
                height: 350,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                clipBehavior: Clip.hardEdge,
                child: _isCameraInitialized
                    ? CameraPreview(_controller!)
                    : _cameraError == null
                    ? const Center(child: CircularProgressIndicator())
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_cameraError!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _initCamera,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 30),

              _cargando
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _isCameraInitialized ? _procesarRostro : null,
                      icon: const Icon(Icons.face),
                      label: Text(
                        widget.esRegistro
                            ? 'Guardar Biometría'
                            : 'Validar Identidad',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
