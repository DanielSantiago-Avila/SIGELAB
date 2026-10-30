import 'package:flutter/material.dart';

import 'devolucion_service.dart';
import '../sesion/sesion_usuario.dart';

class DevolucionDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> devolucion;

  const DevolucionDetalleScreen({super.key, required this.devolucion});

  @override
  State<DevolucionDetalleScreen> createState() =>
      _DevolucionDetalleScreenState();
}

class _DevolucionDetalleScreenState extends State<DevolucionDetalleScreen> {
  final DevolucionService _service = DevolucionService();

  Map<String, dynamic>? _detalle;
  bool _cargando = true;
  String? _error;
  bool _enviando = false;
  final Set<int> _seleccionados = {};
  final Map<int, String> _condiciones = {};
  final Map<int, TextEditingController> _observacionesEquipo = {};
  final TextEditingController _observacionesGenerales = TextEditingController();

  @override
  void dispose() {
    _observacionesGenerales.dispose();
    for (final controlador in _observacionesEquipo.values) {
      controlador.dispose();
    }
    super.dispose();
  }

  int? _idEquipo(Map<String, dynamic> equipo) =>
      int.tryParse('${equipo['idEquipo']}');

  bool _estaPendiente(Map<String, dynamic> equipo) =>
      '${equipo['estadoRecepcion'] ?? ''}'.toUpperCase() == 'PENDIENTE';

  Future<void> _registrarRecepcion(List<Map<String, dynamic>> equipos) async {
    if (_enviando || _seleccionados.isEmpty) return;

    final idUsuario = SesionUsuario.idUsuario;
    final idPrestamo = int.tryParse('${widget.devolucion['idPrestamo']}');
    if (idUsuario == null ||
        idUsuario <= 0 ||
        idPrestamo == null ||
        idPrestamo <= 0) {
      _mensaje('Falta el usuario autenticado o el ID del préstamo.');
      return;
    }

    final pendientes = equipos.where(_estaPendiente).toList();
    final idsPendientes = pendientes.map(_idEquipo).whereType<int>().toSet();
    final idsElegidos = _seleccionados.intersection(idsPendientes);
    if (idsElegidos.length != _seleccionados.length || idsElegidos.isEmpty) {
      _mensaje('Actualiza el detalle: algunos equipos ya no están pendientes.');
      return;
    }

    final seleccion = pendientes
        .where((e) => idsElegidos.contains(_idEquipo(e)))
        .map((e) {
          final id = _idEquipo(e)!;
          return <String, dynamic>{
            'idEquipo': id,
            'condicion': _condiciones[id] ?? 'BUENO',
            'observaciones': _observacionesEquipo[id]?.text.trim() ?? '',
          };
        })
        .toList();

    // Ocultar el teclado antes de mostrar la confirmación
    FocusManager.instance.primaryFocus?.unfocus();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar recepción'),
        content: Text(
          '¿Registrar la recepción de ${seleccion.length} equipo(s) '
          'del préstamo #$idPrestamo? Esta acción actualizará sus estados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    setState(() => _enviando = true);
    try {
      // Refrescamos antes de registrar para evitar enviar equipos ya recibidos.
      final idDevolucion = int.tryParse('${widget.devolucion['idDevolucion']}');
      if (idDevolucion == null) throw StateError('ID de devolución inválido.');
      final actual = await _service.obtenerDetalle(idDevolucion);
      final actuales = actual['equipos'] as List<Map<String, dynamic>>? ?? [];
      final idsActuales = actuales
          .where(_estaPendiente)
          .map(_idEquipo)
          .whereType<int>()
          .toSet();
      if (!idsActuales.containsAll(idsElegidos)) {
        throw StateError(
          'Uno de los equipos ya no está pendiente. Actualiza la pantalla.',
        );
      }
      await _service.registrarRecepcion(
        idUsuario: idUsuario,
        idPrestamo: idPrestamo,
        equipos: seleccion,
        observaciones: _observacionesGenerales.text.trim(),
      );
      if (!mounted) return;
      _seleccionados.clear();
      _condiciones.clear();
      _observacionesGenerales.clear();
      for (final controlador in _observacionesEquipo.values) {
        controlador.clear();
      }
      await _cargarDetalle();
      if (!mounted) return;
      _mensaje('Recepción registrada correctamente.');
    } catch (e) {
      if (!mounted) return;
      _mensaje('No se pudo registrar la recepción: $e');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mensaje(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  @override
  void initState() {
    super.initState();
    _cargarDetalle();
  }

  Future<void> _cargarDetalle() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final idDevolucion = int.tryParse('${widget.devolucion['idDevolucion']}');

      if (idDevolucion == null) {
        throw Exception('El ID de devolución no es válido.');
      }

      final resultado = await _service.obtenerDetalle(idDevolucion);

      if (!mounted) return;

      setState(() {
        _detalle = resultado;
        final vigentes =
            (resultado['equipos'] as List<Map<String, dynamic>>? ?? [])
                .where(_estaPendiente)
                .map(_idEquipo)
                .whereType<int>()
                .toSet();
        _seleccionados.removeWhere((id) => !vigentes.contains(id));
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  String _texto(dynamic valor, {String defecto = 'No disponible'}) {
    if (valor == null || valor.toString().trim().isEmpty) {
      return defecto;
    }

    return valor.toString();
  }

  Widget _dato(IconData icono, String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiqueta,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(valor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _crearEquipo(Map<String, dynamic> equipo) {
    final tipo = _texto(equipo['tipoEquipo']);
    final inventario = _texto(equipo['codigoInventario']);
    final qr = _texto(equipo['codigoQR']);
    final estado = _texto(
      equipo['estadoRecepcion'],
      defecto: 'PENDIENTE',
    ).toUpperCase();

    final condicion = _texto(equipo['condicion']);

    final recibido = estado == 'RECIBIDO';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.devices_outlined, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tipo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(estado),
                  backgroundColor: recibido
                      ? Colors.green.shade100
                      : Colors.amber.shade100,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _dato(
              Icons.inventory_2_outlined,
              'Código de inventario',
              inventario,
            ),
            _dato(Icons.qr_code, 'Código QR', qr),
            _dato(Icons.fact_check_outlined, 'Condición', condicion),
            if (_estaPendiente(equipo) && _idEquipo(equipo) != null) ...[
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recibir este equipo'),
                value: _seleccionados.contains(_idEquipo(equipo)),
                onChanged: _enviando
                    ? null
                    : (valor) {
                        setState(() {
                          final id = _idEquipo(equipo)!;
                          if (valor == true) {
                            _seleccionados.add(id);
                            _condiciones.putIfAbsent(id, () => 'BUENO');
                          } else {
                            _seleccionados.remove(id);
                          }
                        });
                      },
              ),
              if (_seleccionados.contains(_idEquipo(equipo))) ...[
                DropdownButtonFormField<String>(
                  initialValue: _condiciones[_idEquipo(equipo)!] ?? 'BUENO',
                  decoration: const InputDecoration(
                    labelText: 'Condición de recepción',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'BUENO', child: Text('BUENO')),
                    DropdownMenuItem(value: 'DAÑADO', child: Text('DAÑADO')),
                  ],
                  onChanged: _enviando
                      ? null
                      : (valor) {
                          if (valor != null) {
                            setState(() {
                              _condiciones[_idEquipo(equipo)!] = valor;
                            });
                          }
                        },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _observacionesEquipo.putIfAbsent(
                    _idEquipo(equipo)!,
                    () => TextEditingController(),
                  ),
                  enabled: !_enviando,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones del equipo (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devolucion = widget.devolucion;

    final idPrestamo = _texto(devolucion['idPrestamo']);
    final idDevolucion = _texto(devolucion['idDevolucion']);

    final informacion = _detalle?['informacion'] as Map<String, dynamic>?;

    final resumen = _detalle?['resumen'] as Map<String, dynamic>?;

    final equipos = _detalle?['equipos'] as List<Map<String, dynamic>>? ?? [];

    final solicitante = _texto(
      informacion?['solicitante'] ?? devolucion['solicitante'],
    );

    final estado = _texto(
      informacion?['estadoDevolucion'] ?? devolucion['estadoDevolucion'],
      defecto: 'PENDIENTE',
    ).toUpperCase();

    final total = _texto(
      resumen?['totalEquipos'] ?? devolucion['totalEquipos'],
      defecto: '0',
    );

    final pendientes = _texto(
      resumen?['pendientes'] ?? devolucion['equiposPendientes'],
      defecto: '0',
    );

    final recibidos = _texto(resumen?['recibidos'], defecto: '0');

    final fechaEsperada = _texto(
      informacion?['fechaDevolucionEsperada'] ??
          devolucion['fechaDevolucionEsperada'],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Préstamo #$idPrestamo'),
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargarDetalle,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar detalle',
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _cargarDetalle,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarDetalle,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de la devolución',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 20),
                          _dato(
                            Icons.confirmation_number_outlined,
                            'ID de devolución',
                            idDevolucion,
                          ),
                          _dato(
                            Icons.person_outline,
                            'Solicitante',
                            solicitante,
                          ),
                          _dato(Icons.info_outline, 'Estado', estado),
                          _dato(
                            Icons.inventory_2_outlined,
                            'Total de equipos',
                            total,
                          ),
                          _dato(
                            Icons.check_circle_outline,
                            'Equipos recibidos',
                            recibidos,
                          ),
                          _dato(
                            Icons.assignment_late_outlined,
                            'Equipos pendientes',
                            pendientes,
                          ),
                          _dato(
                            Icons.event_outlined,
                            'Fecha esperada de devolución',
                            fechaEsperada,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Equipos de la devolución',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 12),

                  if (equipos.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No hay equipos registrados '
                          'para esta devolución.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ...equipos.map(_crearEquipo),

                  const SizedBox(height: 20),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.qr_code_scanner,
                            size: 52,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Recepción de equipos',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Selecciona los equipos pendientes, indica su condición '
                            'y confirma la recepción.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _observacionesGenerales,
                            enabled: !_enviando,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Observaciones generales (opcional)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _enviando || _seleccionados.isEmpty
                                  ? null
                                  : () => _registrarRecepcion(equipos),
                              icon: _enviando
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.fact_check_outlined),
                              label: Text(
                                _enviando
                                    ? 'Registrando...'
                                    : 'Registrar devolución (${_seleccionados.length})',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
