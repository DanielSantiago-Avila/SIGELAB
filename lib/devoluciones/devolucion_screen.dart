import 'package:flutter/material.dart';

import 'devolucion_service.dart';

import 'devolucion_detalle_screen.dart';

class DevolucionScreen extends StatefulWidget {
  const DevolucionScreen({super.key});

  @override
  State<DevolucionScreen> createState() => _DevolucionScreenState();
}

class _DevolucionScreenState extends State<DevolucionScreen> {
  final DevolucionService _service = DevolucionService();

  List<Map<String, dynamic>> _devoluciones = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDevoluciones();
  }

  Future<void> _cargarDevoluciones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await _service.listarPendientes();

      if (!mounted) return;

      setState(() {
        _devoluciones = resultado;
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

  Widget _crearTarjeta(Map<String, dynamic> devolucion) {
    final idPrestamo = _texto(devolucion['idPrestamo']);
    final solicitante = _texto(devolucion['solicitante']);
    final estado = _texto(
      devolucion['estadoDevolucion'],
      defecto: 'PENDIENTE',
    ).toUpperCase();

    final pendientes = _texto(devolucion['equiposPendientes'], defecto: '0');

    final total = _texto(devolucion['totalEquipos'], defecto: '0');

    final esParcial = estado == 'PARCIAL';

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Préstamo #$idPrestamo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(estado),
                  backgroundColor: esParcial
                      ? Colors.orange.shade100
                      : Colors.amber.shade100,
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                Expanded(child: Text(solicitante)),
              ],
            ),

            const SizedBox(height: 12),

            Text('Total de equipos: $total'),
            Text('Equipos pendientes: $pendientes'),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DevolucionDetalleScreen(devolucion: devolucion),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Ver detalle'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Devoluciones pendientes'),
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargarDevoluciones,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
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
                      onPressed: _cargarDevoluciones,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            )
          : _devoluciones.isEmpty
          ? const Center(
              child: Text(
                'No hay devoluciones pendientes.',
                textAlign: TextAlign.center,
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarDevoluciones,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _devoluciones.length,
                itemBuilder: (context, index) {
                  return _crearTarjeta(_devoluciones[index]);
                },
              ),
            ),
    );
  }
}
