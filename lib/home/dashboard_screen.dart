import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color azul = Color(0xFF163C66);
  static const Color fondo = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondo,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del inventario',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: azul,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Indicadores generales del sistema',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final columnas =
                    constraints.maxWidth >= 1000
                        ? 3
                        : constraints.maxWidth >= 600
                            ? 2
                            : 1;

                final ancho =
                    (constraints.maxWidth -
                        (columnas - 1) * 12) /
                    columnas;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Total de equipos',
                        '2,450',
                        Icons.devices,
                        Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Equipos disponibles',
                        '1,200',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Equipos prestados',
                        '900',
                        Icons.assignment_outlined,
                        Colors.orange,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Equipos dañados',
                        '150',
                        Icons.warning_amber,
                        Colors.red,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'En mantenimiento',
                        '120',
                        Icons.build_outlined,
                        Colors.deepOrange,
                      ),
                    ),
                    SizedBox(
                      width: ancho,
                      child: _tarjeta(
                        'Dados de baja',
                        '80',
                        Icons.inventory_2_outlined,
                        Colors.grey,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth >= 700;

                final activos = _alerta(
                  'Préstamos activos',
                  '512',
                  'Préstamos que siguen vigentes',
                  Colors.orange,
                  Icons.warning_amber_rounded,
                );

                final vencidos = _alerta(
                  'Préstamos vencidos',
                  '45',
                  'Requieren revisión',
                  Colors.red,
                  Icons.alarm,
                );

                if (horizontal) {
                  return Row(
                    children: [
                      Expanded(child: activos),
                      const SizedBox(width: 12),
                      Expanded(child: vencidos),
                    ],
                  );
                }

                return Column(
                  children: [
                    activos,
                    const SizedBox(height: 12),
                    vencidos,
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            const Text(
              'Equipos prestados por tipo',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: azul,
              ),
            ),
            const SizedBox(height: 12),

            _graficaBarras(),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado del inventario',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: azul,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Disponible: 49%    '
                    'Prestado: 37%    '
                    'Otros estados: 14%',
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: 0.49,
                    minHeight: 14,
                    backgroundColor: Color(0xFFE0E5EC),
                    color: Colors.green,
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Valores ilustrativos. '
                    'Pendiente de conectar con la API.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tarjeta(
    String titulo,
    String cantidad,
    IconData icono,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  cantidad,
                  style: const TextStyle(
                    fontSize: 25,
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
            'Dato de demostración',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _alerta(
    String titulo,
    String cantidad,
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
        border: Border.all(color: color.withValues(alpha: 0.6)),
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
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  cantidad,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Icon(icono, size: 34, color: color),
        ],
      ),
    );
  }

  Widget _graficaBarras() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Column(
        children: [
          _BarraTipo(
            nombre: 'Laptop',
            activos: 54,
            vencidos: 16,
            maximo: 60,
          ),
          SizedBox(height: 20),
          _BarraTipo(
            nombre: 'Cámara',
            activos: 41,
            vencidos: 10,
            maximo: 60,
          ),
          SizedBox(height: 20),
          _BarraTipo(
            nombre: 'Proyector',
            activos: 38,
            vencidos: 6,
            maximo: 60,
          ),
          SizedBox(height: 14),
          Text(
            'Valores ilustrativos, no obtenidos de la API.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraTipo extends StatelessWidget {
  final String nombre;
  final double activos;
  final double vencidos;
  final double maximo;

  const _BarraTipo({
    required this.nombre,
    required this.activos,
    required this.vencidos,
    required this.maximo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: activos.round(),
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF24558A),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: vencidos.round(),
              child: Container(
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${activos.round()} / ${vencidos.round()}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
