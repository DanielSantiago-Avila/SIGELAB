import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'facial_recognition_service.dart';

class FacialRecognitionScreen extends StatefulWidget {
  final int idUsuario;
  final bool esRegistro; // true: Registra rostro nuevo | false: Valida login
  final VoidCallback onSuccess;

  const FacialRecognitionScreen({
    Key? key,
    required this.idUsuario,
    this.esRegistro = false,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<FacialRecognitionScreen> createState() => _FacialRecognitionScreenState();
}

class _FacialRecognitionScreenState extends State<FacialRecognitionScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _cargando = false;
  final FacialRecognitionService _service =
      FacialRecognitionService(baseUrl: 'https://tu-backend-api.com');

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
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('Error al inicializar cámara: $e');
    }
  }

  Future<void> _procesarRostro() async {
    if (_controller == null || !_controller!.value.isInitialized || _cargando) return;

    setState(() => _cargando = true);

    try {
      // Captura el frame en tiempo real
      final XFile photo = await _controller!.takePicture();
      final Uint8List bytes = await photo.readAsBytes();
      final String base64Image = base64Encode(bytes);

      bool resultado = false;

      if (widget.esRegistro) {
        // Guarda la biometría inicial del usuario en BIOMETRIA_USUARIO
        resultado = await _service.registrarRostro(
          idUsuario: widget.idUsuario,
          imagenBase64: base64Image,
        );
      } else {
        // Valida el rostro capturado contra el vector guardado
        resultado = await _service.validarRostro(
          idUsuario: widget.idUsuario,
          imagenBase64: base64Image,
        );
      }

      setState(() => _cargando = false);

      if (resultado) {
        if (!mounted) return;

        // Muestra diálogo flotante de éxito
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Column(
                children: const [
                  Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
                  SizedBox(height: 10),
                  Text(
                    '¡Validación Exitosa!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Text(
                widget.esRegistro
                    ? 'Su rostro ha sido registrado correctamente en el sistema.'
                    : 'Rostro reconocido con éxito. ¡Bienvenido al sistema!',
                textAlign: TextAlign.center,
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el modal
                    },
                    child: const Text('Continuar al Home'),
                  ),
                ),
              ],
            );
          },
        );

        // Avanza al Home al cerrar la ventana
        widget.onSuccess();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.esRegistro
                  ? 'Error al registrar biometría.'
                  : 'Reconocimiento facial no coincide. Acceso denegado.',
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _cargando = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en el escaneo: $e')),
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
        title: Text(widget.esRegistro ? 'Registro Biométrico' : 'Validación Biométrica'),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                    : const Center(child: CircularProgressIndicator()),
              ),
              const SizedBox(height: 30),

              _cargando
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _isCameraInitialized ? _procesarRostro : null,
                      icon: const Icon(Icons.face),
                      label: Text(
                        widget.esRegistro ? 'Guardar Biometría' : 'Validar Identidad',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}