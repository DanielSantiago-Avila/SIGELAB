import 'package:flutter/material.dart';

import 'prestamo_service.dart';

import '../sesion/sesion_usuario.dart';

class PrestamoScreen extends StatefulWidget {
  final Map<String, dynamic> equipo;

  const PrestamoScreen({super.key, required this.equipo});

  @override
  State<PrestamoScreen> createState() => _PrestamoScreenState();
}

class _PrestamoScreenState extends State<PrestamoScreen> {
  final PrestamoService _service = PrestamoService();

  final TextEditingController _observacionesController =
      TextEditingController();

  List<Map<String, dynamic>> _solicitantes = [];

  int? _idSolicitante;
  DateTime? _fechaDevolucion;

  bool _cargando = true;
  bool _validando = false;
  bool _autorizado = false;

  String? _error;
  String? _mensajeValidacion;

  @override
  void initState() {
    super.initState();
    _cargarSolicitantes();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _cargarSolicitantes() async {
    try {
      final solicitantes = await _service.obtenerSolicitantes();

      if (!mounted) return;

      setState(() {
        _solicitantes = solicitantes;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _validarPrestamo(int idSolicitante) async {
    setState(() {
      _idSolicitante = idSolicitante;
      _validando = true;
      _autorizado = false;
      _mensajeValidacion = null;
    });

    try {
      final idTipoEquipo = widget.equipo['idTipoEquipo'];

      if (idTipoEquipo is! int) {
        throw Exception('El equipo no tiene un tipo válido.');
      }

      final permiso = await _service.validarPermiso(
        idSolicitante: idSolicitante,
        idTipoEquipo: idTipoEquipo,
      );

      final codigoQr = widget.equipo['codigoQR']?.toString();

      if (codigoQr == null || codigoQr.isEmpty) {
        throw Exception('El equipo no tiene código QR.');
      }

      final equipoValidado = await _service.consultarEquipoParaPrestamo(
        codigoQr: codigoQr,
        idSolicitante: idSolicitante,
      );

      final puedePrestarse = equipoValidado['puedePrestarse'] == true;

      final autorizado = permiso && puedePrestarse;

      debugPrint('========== VALIDACIÓN PRÉSTAMO ==========');
debugPrint('Solicitante: $idSolicitante');
debugPrint('Equipo: ${widget.equipo['codigoInventario']}');
debugPrint('Permiso del solicitante: $permiso');
debugPrint('Equipo puede prestarse: $puedePrestarse');
debugPrint('Autorización final: $autorizado');
debugPrint('========================================');

      if (!mounted || _idSolicitante != idSolicitante) return;

      setState(() {
        _autorizado = autorizado;
        _mensajeValidacion = autorizado
            ? 'El solicitante está autorizado para este préstamo.'
            : 'El préstamo no está permitido para este solicitante.';
        _validando = false;
      });
    } catch (error) {
      if (!mounted || _idSolicitante != idSolicitante) return;

      setState(() {
        _autorizado = false;
        _mensajeValidacion = error.toString();
        _validando = false;
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();

    final fecha = await showDatePicker(
      context: context,
      initialDate: ahora.add(const Duration(days: 1)),
      firstDate: ahora,
      lastDate: ahora.add(const Duration(days: 365)),
      helpText: 'Fecha esperada de devolución',
    );

    if (fecha == null || !mounted) return;

    final hora = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 16, minute: 0),
      helpText: 'Hora esperada de devolución',
    );

    if (hora == null || !mounted) return;

    final fechaCompleta = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hora.hour,
      hora.minute,
    );

    if (!fechaCompleta.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha y hora de devolución deben ser futuras.'),
        ),
      );
      return;
    }

    setState(() {
      _fechaDevolucion = fechaCompleta;
    });
  }

  String _formatearFecha(DateTime fecha) {
    String dosDigitos(int numero) => numero.toString().padLeft(2, '0');

    return '${dosDigitos(fecha.day)}/'
        '${dosDigitos(fecha.month)}/'
        '${fecha.year} '
        '${dosDigitos(fecha.hour)}:'
        '${dosDigitos(fecha.minute)}';
  }

  void _prepararRegistro() {
    if (!_autorizado || _idSolicitante == null) {
      return;
    }

    if (_fechaDevolucion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una fecha de devolución.')),
      );
      return;
    }

    if (!_fechaDevolucion!.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha de devolución debe ser futura.'),
        ),
      );
      return;
    }

    final idEquipo = widget.equipo['idEquipo'];

    if (idEquipo is! int) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se encontró un ID válido del equipo.'),
        ),
      );
      return;
    }

    // El formulario ya reúne los datos necesarios:
    // _idSolicitante
    // _fechaDevolucion
    // _observacionesController.text.trim()
    // idEquipo
    //
    // Falta confirmar el endpoint POST y obtener el
    // idUsuario real de la sesión autenticada.

    final int? idUsuario = SesionUsuario.idUsuario;

if (idUsuario == null) {
  throw StateError(
    'Debes iniciar sesión para registrar un préstamo.',
  );
}

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Formulario listo. Pendiente conectar el endpoint '
          'POST y el usuario autenticado.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final equipo = widget.equipo;

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo préstamo')),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.laptop_mac, size: 36),
                    title: Text(equipo['tipoEquipo']?.toString() ?? 'Equipo'),
                    subtitle: Text(
                      '${equipo['codigoInventario'] ?? ''}\n'
                      '${equipo['laboratorio'] ?? ''}',
                    ),
                    isThreeLine: true,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Seleccionar solicitante',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<int>(
                  initialValue: _idSolicitante,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Estudiante o docente',
                  ),
                  isExpanded: true,
                  items: _solicitantes.map((solicitante) {
                    final id = solicitante['idSolicitante'];

                    return DropdownMenuItem<int>(
                      value: id as int,
                      child: Text(
                        '${solicitante['nombre']} '
                        '${solicitante['apellido']} '
                        '(${solicitante['tipoSolicitante']})',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _validando
                      ? null
                      : (valor) {
                          if (valor != null) {
                            _validarPrestamo(valor);
                          }
                        },
                ),

                const SizedBox(height: 20),

                if (_validando)
                  const Center(child: CircularProgressIndicator()),

                if (_mensajeValidacion != null)
                  Card(
                    color: _autorizado
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            _autorizado
                                ? Icons.check_circle
                                : Icons.warning_amber,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _mensajeValidacion!,
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                Text(
                  'Fecha esperada de devolución',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: _seleccionarFecha,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(
                    _fechaDevolucion == null
                        ? 'Seleccionar fecha y hora'
                        : _formatearFecha(_fechaDevolucion!),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Observaciones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _observacionesController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText:
                        'Ejemplo: Préstamo para práctica '
                        'de laboratorio.',
                  ),
                ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed:
                      _autorizado && !_validando && _fechaDevolucion != null
                      ? _prepararRegistro
                      : null,
                  icon: const Icon(Icons.assignment_turned_in),
                  label: const Text('Registrar préstamo'),
                ),

                const SizedBox(height: 12),

                const Text(
                  'El registro definitivo se habilitará '
                  'cuando confirmemos el endpoint POST '
                  'y el usuario autenticado.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
    );
  }
}
