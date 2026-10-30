import 'package:flutter/material.dart';

import 'dashboard_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color azul = Color(0xFF163C66);
  static const Color fondo = Color(0xFFF4F6F9);

  final DashboardService _service = DashboardService();

  DashboardResumen? _resumen;
  String? _error;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultado = await _service.obtenerResumen();

      if (!mounted) return;

      setState(() {
        _resumen = resultado;
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

  @override
  Widget build(BuildContext context) {
    if (_cargando && _resumen == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _resumen == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_outlined,
                size: 55,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              const Text(
                'No fue posible cargar el inventario.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: azul,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _cargarResumen,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final resumen = _resumen!;

    return Container(
      color: fondo,
      child: RefreshIndicator(
        onRefresh: _cargarResumen,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _encabezado(),

            const SizedBox(height: 8),

            const Text(
              'Información obtenida directamente del inventario.',
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            _titulo('Resumen del inventario'),

            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                final columnas = constraints.maxWidth >= 1000
                    ? 3
                    : constraints.maxWidth >= 600
                    ? 2
                    : 1;

                final ancho =
                    (constraints.maxWidth - (columnas - 1) * 12) / columnas;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Total de equipos',
                        resumen.totalEquipos,
                        Icons.devices,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Equipos disponibles',
                        resumen.disponibles,
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Equipos prestados',
                        resumen.prestados,
                        Icons.assignment_outlined,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Equipos dañados',
                        resumen.danados,
                        Icons.warning_amber,
                        Colors.red,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'En mantenimiento',
                        resumen.enMantenimiento,
                        Icons.build_outlined,
                        Colors.deepOrange,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Dados de baja',
                        resumen.dadosDeBaja,
                        Icons.inventory_2_outlined,
                        Colors.grey,
                      ),
                    ),
                    if (resumen.otrosEstados > 0)
                      SizedBox(
                        width: ancho,
                        child: _tarjeta(
                          'Otros estados',
                          resumen.otrosEstados,
                          Icons.help_outline,
                          Colors.blueGrey,
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 26),

            _titulo('Resumen de préstamos y mantenimiento'),

            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth >= 850;

                final tarjetas = [
                  _alerta(
                    'Préstamos activos',
                    resumen.prestamosActivos,
                    'Préstamos que siguen vigentes.',
                    Colors.orange,
                    Icons.assignment_outlined,
                  ),
                  _alerta(
                    'Préstamos vencidos',
                    resumen.prestamosVencidos,
                    'Préstamos activos cuya fecha esperada ya pasó.',
                    Colors.red,
                    Icons.alarm,
                  ),
                  _alerta(
                    'Mantenimientos abiertos',
                    resumen.mantenimientosAbiertos,
                    'Equipos con mantenimiento sin finalizar.',
                    Colors.deepOrange,
                    Icons.build_circle_outlined,
                  ),
                ];

                if (horizontal) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < tarjetas.length; i++) ...[
                        if (i > 0) const SizedBox(width: 12),
                        Expanded(child: tarjetas[i]),
                      ],
                    ],
                  );
                }

                return Column(
                  children: [
                    for (int i = 0; i < tarjetas.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      tarjetas[i],
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: 26),

            _titulo('Inventario por tipo de equipo'),

            const SizedBox(height: 12),

            _graficaPorTipo(resumen.equiposPorTipo),

            const SizedBox(height: 20),

            _resumenEstados(resumen),

            const SizedBox(height: 20),

            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  'No se pudo actualizar la información: $_error',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),

            const SizedBox(height: 12),

            Center(
              child: TextButton.icon(
                onPressed: _cargando ? null : _cargarResumen,
                icon: const Icon(Icons.refresh),
                label: const Text('Actualizar información'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen del inventario',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: azul,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Panel general de SIGELAB',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualizar datos',
          onPressed: _cargando ? null : _cargarResumen,
          icon: _cargando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh, color: azul),
        ),
      ],
    );
  }

  Widget _titulo(String texto) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        color: azul,
      ),
    );
  }

  Widget _tarjeta(String titulo, int cantidad, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  cantidad.toString(),
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: azul,
                  ),
                ),
              ),
              Icon(icono, size: 29, color: color),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Dato obtenido de la API',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _alerta(
    String titulo,
    int cantidad,
    String descripcion,
    Color color,
    IconData icono,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cantidad.toString(),
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Icon(icono, size: 30, color: color),
        ],
      ),
    );
  }

  Widget _graficaPorTipo(Map<String, int> equiposPorTipo) {
    if (equiposPorTipo.isEmpty) {
      return _contenedor(const Text('No hay equipos registrados por tipo.'));
    }

    final entradas = equiposPorTipo.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final maximo = entradas.fold<int>(
      1,
      (actual, item) => item.value > actual ? item.value : actual,
    );

    return _contenedor(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < entradas.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            Text(
              entradas[i].key,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: entradas[i].value / maximo,
                      minHeight: 13,
                      backgroundColor: const Color(0xFFE0E5EC),
                      color: const Color(0xFF24558A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 28,
                  child: Text(
                    entradas[i].value.toString(),
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _resumenEstados(DashboardResumen resumen) {
    final total = resumen.totalEquipos;

    final estados = [
      ('Disponibles', resumen.disponibles, Colors.green),
      ('Prestados', resumen.prestados, Colors.orange),
      ('Dañados', resumen.danados, Colors.red),
      ('En mantenimiento', resumen.enMantenimiento, Colors.deepOrange),
      ('Dados de baja', resumen.dadosDeBaja, Colors.grey),
      ('Otros estados', resumen.otrosEstados, Colors.blueGrey),
    ];

    return _contenedor(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Distribución del inventario',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: azul,
            ),
          ),
          const SizedBox(height: 16),
          for (int i = 0; i < estados.length; i++) ...[
            if (estados[i].$2 > 0) ...[
              Row(
                children: [
                  Expanded(child: Text(estados[i].$1)),
                  Text(
                    '${estados[i].$2}'
                    ' (${total == 0 ? 0 : (estados[i].$2 * 100 / total).toStringAsFixed(1)}%)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : estados[i].$2 / total,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFE0E5EC),
                  color: estados[i].$3,
                ),
              ),
              const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }

  Widget _contenedor(Widget contenido) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: contenido,
    );
  }
}
