import 'package:flutter/material.dart';

class MantenimientoScreen extends StatefulWidget {
  const MantenimientoScreen({super.key});

  @override
  State<MantenimientoScreen> createState() =>
      _MantenimientoScreenState();
}

class _MantenimientoScreenState extends State<MantenimientoScreen> {
  static const Color azul = Color(0xFF163C66);
  static const Color azulClaro = Color(0xFF2878D4);
  static const Color fondo = Color(0xFFF4F6F9);
  static const Color verde = Color(0xFF239765);

  final _descripcionController = TextEditingController();
  final _tecnicoController = TextEditingController();
  final _informeController = TextEditingController();
  final ScrollController _equiposScrollController = ScrollController();

  final List<Map<String, String>> _equipos = [
    {
      'id': 'CAM-002',
      'nombre': 'Cámara Canon',
      'tipo': 'Cámara',
      'marca': 'Canon 80D Kit',
      'laboratorio': 'Fotografía',
      'fecha': '12/03/2026',
    },
    {
      'id': 'MIC-003',
      'nombre': 'Microscopio',
      'tipo': 'Microscopio',
      'marca': 'Olympus CX23',
      'laboratorio': 'Biología',
      'fecha': '18/05/2026',
    },
    {
      'id': 'ESP-001',
      'nombre': 'Espectrofotómetro',
      'tipo': 'Analizador',
      'marca': 'Thermo Scientific',
      'laboratorio': 'Química',
      'fecha': '27/06/2026',
    },
    {
      'id': 'BAL-004',
      'nombre': 'Balanza analítica',
      'tipo': 'Balanza',
      'marca': 'Ohaus PX224',
      'laboratorio': 'Química',
      'fecha': '10/09/2026',
    },
    {
      'id': 'INC-002',
      'nombre': 'Incubadora',
      'tipo': 'Incubadora',
      'marca': 'Memmert IN30',
      'laboratorio': 'Biología',
      'fecha': '22/11/2025',
    },
  ];

  String _equipoId = 'CAM-002';
  String _tipoMantenimiento = 'Correctivo';
  String _resultado = 'Reparado';
  DateTime _fechaIngreso = DateTime(2026, 10, 14);
  DateTime _fechaSalida = DateTime(2026, 10, 14);

  bool _registrarSalida = true;
  bool _mantenimientoActivo = false;

  Map<String, String> get _equipoSeleccionado =>
      _equipos.firstWhere((e) => e['id'] == _equipoId);

  @override
  void dispose() {
    _descripcionController.dispose();
    _tecnicoController.dispose();
    _informeController.dispose();
    _equiposScrollController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    const meses = [
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];

    return '${fecha.day} ${meses[fecha.month - 1]} ${fecha.year}';
  }

  Future<DateTime?> _seleccionarFecha(DateTime inicial) async {
    return showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'GT'),
    );
  }

  Future<void> _elegirFechaIngreso() async {
    final fecha = await _seleccionarFecha(_fechaIngreso);
    if (fecha != null && mounted) {
      setState(() => _fechaIngreso = fecha);
    }
  }

  Future<void> _elegirFechaSalida() async {
    final fecha = await _seleccionarFecha(_fechaSalida);
    if (fecha != null && mounted) {
      setState(() => _fechaSalida = fecha);
    }
  }

  void _guardarMantenimiento() {
    if (_descripcionController.text.trim().isEmpty) {
      _mostrarMensaje('Escribe la descripción del problema o las tareas.');
      return;
    }

    if (_tecnicoController.text.trim().isEmpty) {
      _mostrarMensaje('Escribe el nombre del técnico responsable.');
      return;
    }

    setState(() => _mantenimientoActivo = true);

    _mostrarMensaje(
      'Registro preparado correctamente. Aún no se ha enviado a la API.',
    );
  }

  void _cancelarRegistro() {
    setState(() {
      _descripcionController.clear();
      _tecnicoController.clear();
      _tipoMantenimiento = 'Correctivo';
      _mantenimientoActivo = false;
    });
  }

  void _cerrarMantenimiento() {
    if (!_mantenimientoActivo) {
      _mostrarMensaje('Primero registra el mantenimiento del equipo.');
      return;
    }

    if (!_registrarSalida) {
      _mostrarMensaje('Marca Registrar salida para confirmar el cierre.');
      return;
    }

    if (_informeController.text.trim().isEmpty) {
      _mostrarMensaje('Escribe el informe final de la reparación.');
      return;
    }

    setState(() => _mantenimientoActivo = false);

    _mostrarMensaje(
      _resultado == 'Reparado'
          ? 'Cierre de demostración: equipo disponible.'
          : 'Cierre de demostración: equipo marcado para baja.',
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondo,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build_circle_outlined,
                    color: azul, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mantenimiento',
                        style: TextStyle(
                          color: azul,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gestión de mantenimiento de equipos de laboratorio',
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.notifications_none, color: azul),
                const SizedBox(width: 8),
                const Text('SIGELAB',
                    style: TextStyle(
                      color: azul,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            const SizedBox(height: 22),

            // Selección de equipos e ingreso de mantenimiento.
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      _tarjetaEquipos(),
                      const SizedBox(height: 16),
                      _tarjetaIngreso(),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 11, child: _tarjetaEquipos()),
                    const SizedBox(width: 16),
                    Expanded(flex: 10, child: _tarjetaIngreso()),
                  ],
                );
              },
            ),

            const SizedBox(height: 18),
            _tarjetaCierre(),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaEquipos() {
    return _tarjeta(
      titulo: 'Selección de equipos dañados / revisión',
      icono: Icons.inventory_2_outlined,
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              border: Border.all(color: const Color(0xFFFECACA)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 21),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Equipos en estado crítico',
                    style: TextStyle(
                      color: Color(0xFFB91C1C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.redAccent,
                  child: Text('3',
                      style: TextStyle(
                          color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Scrollbar(
            controller: _equiposScrollController,
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            thickness: 10,
            radius: const Radius.circular(8),
            child: SingleChildScrollView(
              controller: _equiposScrollController,
              scrollDirection: Axis.horizontal,
              child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF0F5FC)),
              dataRowMinHeight: 45,
              dataRowMaxHeight: 55,
              horizontalMargin: 10,
              columnSpacing: 18,
              columns: const [
                DataColumn(label: Text('ID Equipo')),
                DataColumn(label: Text('Nombre')),
                DataColumn(label: Text('Tipo')),
                DataColumn(label: Text('Marca/Modelo')),
                DataColumn(label: Text('Laboratorio')),
                DataColumn(label: Text('Fecha registro')),
              ],
              rows: _equipos.map((equipo) {
                final seleccionado = equipo['id'] == _equipoId;

                return DataRow(
                  selected: seleccionado,
                  onSelectChanged: (_) {
                    setState(() {
                      _equipoId = equipo['id']!;
                    });
                  },
                  cells: [
                    DataCell(Text(equipo['id']!)),
                    DataCell(Text(equipo['nombre']!)),
                    DataCell(Text(equipo['tipo']!)),
                    DataCell(Text(equipo['marca']!)),
                    DataCell(Text(equipo['laboratorio']!)),
                    DataCell(Text(equipo['fecha']!)),
                  ],
                );
              }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seleccionado: $_equipoId',
            style: const TextStyle(
              color: azul,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaIngreso() {
    return _tarjeta(
      titulo: 'Ingreso de nuevo mantenimiento',
      icono: Icons.add_task,
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compacto = constraints.maxWidth < 480;

              final equipo = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiqueta('ID Equipo seleccionado'),
                  DropdownButtonFormField<String>(
                    value: _equipoId,
                    isExpanded: true,
                    decoration: _decoracion(),
                    items: _equipos.map((equipo) {
                      return DropdownMenuItem(
                        value: equipo['id'],
                        child: Text(
                          '${equipo['id']} - ${equipo['nombre']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() => _equipoId = valor);
                      }
                    },
                  ),
                ],
              );

              final fecha = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiqueta('Fecha de ingreso'),
                  _campoFecha(
                    _formatearFecha(_fechaIngreso),
                    _elegirFechaIngreso,
                  ),
                ],
              );

              if (compacto) {
                return Column(
                  children: [
                    equipo,
                    const SizedBox(height: 12),
                    fecha,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: equipo),
                  const SizedBox(width: 12),
                  Expanded(child: fecha),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          _etiqueta('Mantenimiento'),
          Wrap(
            spacing: 12,
            children: [
              _opcionRadio('Preventivo', _tipoMantenimiento, (valor) {
                setState(() => _tipoMantenimiento = valor!);
              }),
              _opcionRadio('Correctivo', _tipoMantenimiento, (valor) {
                setState(() => _tipoMantenimiento = valor!);
              }),
            ],
          ),
          const SizedBox(height: 14),
          _etiqueta('Descripción del problema / tareas a realizar'),
          TextField(
            controller: _descripcionController,
            minLines: 3,
            maxLines: 4,
            decoration: _decoracion(
              hint:
                  'Ej: Cámara Canon 80D: limpieza y calibración; revisión del equipo.',
            ),
          ),
          const SizedBox(height: 14),
          _etiqueta('Técnico responsable'),
          TextField(
            controller: _tecnicoController,
            decoration: _decoracion(
              hint: 'Ej: Técnico externo - López',
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _guardarMantenimiento,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: azulClaro,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 16),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _cancelarRegistro,
                icon: const Icon(Icons.close),
                label: const Text('Cancelar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: azulClaro,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tarjetaCierre() {
    return _tarjeta(
      titulo: 'Panel de cierre de mantenimiento / Registro de salida',
      icono: Icons.assignment_turned_in_outlined,
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compacto = constraints.maxWidth < 800;

              final reparacion = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiqueta('Detalles de la reparación / Informe final'),
                  TextField(
                    controller: _informeController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: _decoracion(
                      hint:
                          'Ej: Reemplazo de obturador, limpieza y calibración completada.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _opcionResultado(
                        'Reparado',
                        'Pasa a disponibilidad',
                        Icons.check_circle_outline,
                        verde,
                      ),
                      _opcionResultado(
                        'No reparable',
                        'Pasa a baja',
                        Icons.cancel_outlined,
                        Colors.red,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _resultado == 'Reparado'
                          ? verde
                          : Colors.red.shade600,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _resultado,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final salida = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _etiqueta('Fecha de salida'),
                  _campoFecha(
                    _formatearFecha(_fechaSalida),
                    _elegirFechaSalida,
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text('Registrar salida / cierre'),
                    value: _registrarSalida,
                    activeColor: azulClaro,
                    onChanged: (valor) {
                      setState(() => _registrarSalida = valor ?? false);
                    },
                  ),
                  const SizedBox(height: 10),
                  FilledButton.icon(
                    onPressed: _cerrarMantenimiento,
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Cerrar mantenimiento'),
                    style: FilledButton.styleFrom(
                      backgroundColor: azulClaro,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 46),
                    ),
                  ),
                ],
              );

              if (compacto) {
                return Column(
                  children: [
                    reparacion,
                    const SizedBox(height: 20),
                    salida,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: reparacion),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: salida),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFD7E3F5)),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compacto = constraints.maxWidth < 650;

              final resultado = _bandaResumen(
                color: const Color(0xFFE8F7EF),
                borde: const Color(0xFFB7E7CF),
                icono: Icons.check_circle,
                iconoColor: verde,
                titulo: 'Resultado',
                texto: _resultado == 'Reparado'
                    ? 'Equipo pasa a disponibilidad (${_equipoSeleccionado['laboratorio']}).'
                    : 'Equipo marcado para baja.',
              );

              final resumen = _bandaResumen(
                color: const Color(0xFFEAF2FF),
                borde: const Color(0xFFBED7FF),
                icono: Icons.description_outlined,
                iconoColor: azulClaro,
                titulo: 'Resumen',
                texto: _mantenimientoActivo
                    ? 'Mantenimiento activo con $_equipoId ${_equipoSeleccionado['marca']}.'
                    : 'No hay un mantenimiento activo registrado.',
              );

              if (compacto) {
                return Column(
                  children: [
                    resultado,
                    const SizedBox(height: 10),
                    resumen,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: resultado),
                  const SizedBox(width: 12),
                  Expanded(child: resumen),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tarjeta({
    required String titulo,
    required IconData icono,
    required Widget contenido,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD7E3F5)),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: azul, size: 21),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: azul,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          contenido,
        ],
      ),
    );
  }

  Widget _etiqueta(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        texto,
        style: const TextStyle(
          color: azul,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  InputDecoration _decoracion({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFD2E0F5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: Color(0xFFD2E0F5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: const BorderSide(color: azulClaro, width: 1.5),
      ),
    );
  }

  Widget _campoFecha(String texto, VoidCallback alPresionar) {
    return InkWell(
      onTap: alPresionar,
      borderRadius: BorderRadius.circular(7),
      child: InputDecorator(
        decoration: _decoracion().copyWith(
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            color: azul,
            size: 19,
          ),
        ),
        child: Text(texto),
      ),
    );
  }

  Widget _opcionRadio(
    String texto,
    String grupo,
    ValueChanged<String?> alCambiar,
  ) {
    return InkWell(
      onTap: () => alCambiar(texto),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(
            color: grupo == texto ? azulClaro : const Color(0xFFD7E3F5),
          ),
          borderRadius: BorderRadius.circular(20),
          color: grupo == texto
              ? const Color(0xFFEAF2FF)
              : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: texto,
              groupValue: grupo,
              activeColor: azulClaro,
              onChanged: alCambiar,
              visualDensity: VisualDensity.compact,
            ),
            Text(texto, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _opcionResultado(
    String valor,
    String subtitulo,
    IconData icono,
    Color color,
  ) {
    final seleccionado = _resultado == valor;

    return InkWell(
      onTap: () => setState(() => _resultado = valor),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: seleccionado ? color.withValues(alpha: 0.08) : fondo,
          border: Border.all(
            color: seleccionado ? color : const Color(0xFFD7E3F5),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              seleccionado ? Icons.radio_button_checked : icono,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  valor,
                  style: TextStyle(
                    color: seleccionado ? color : azul,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(subtitulo, style: const TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _bandaResumen({
    required Color color,
    required Color borde,
    required IconData icono,
    required Color iconoColor,
    required String titulo,
    required String texto,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borde),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, color: iconoColor, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$titulo:',
                  style: TextStyle(
                    color: iconoColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(texto, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}