import 'package:flutter/material.dart';

import '../sesion/sesion_usuario.dart';
import 'mantenimiento_model.dart';
import 'mantenimiento_service.dart';

class MantenimientoScreen extends StatefulWidget {
  const MantenimientoScreen({super.key});

  @override
  State<MantenimientoScreen> createState() => _MantenimientoScreenState();
}

class _MantenimientoScreenState extends State<MantenimientoScreen> {
  static const Color azul = Color(0xFF163C66);
  static const Color azulClaro = Color(0xFF2878D4);
  static const Color fondo = Color(0xFFF4F6F9);
  static const Color verde = Color(0xFF239765);

  final MantenimientoService _service = MantenimientoService();

  final TextEditingController _busquedaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _observacionesIngresoController =
      TextEditingController();
  final TextEditingController _observacionesSalidaController =
      TextEditingController();

  List<EquipoMantenimiento> _equipos = [];
  List<Mantenimiento> _mantenimientos = [];

  EquipoMantenimiento? _equipoSeleccionado;
  Mantenimiento? _mantenimientoSeleccionado;

  bool _cargando = true;
  bool _procesando = false;

  String? _error;
  String _tipoMantenimiento = 'CORRECTIVO';
  String _resultado = 'REPARADO';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    _descripcionController.dispose();
    _observacionesIngresoController.dispose();
    _observacionesSalidaController.dispose();
    super.dispose();
  }

  int? get _idUsuario => SesionUsuario.idUsuario;

  String get _nombreResponsable {
    final nombre = SesionUsuario.nombre?.trim();

    if (nombre == null || nombre.isEmpty) {
      return SesionUsuario.usuario ?? 'Usuario autenticado';
    }

    return nombre;
  }

  List<EquipoMantenimiento> get _equiposFiltrados {
    final busqueda = _busquedaController.text.trim().toLowerCase();

    if (busqueda.isEmpty) return _equipos;

    return _equipos.where((equipo) {
      return equipo.codigoInventario.toLowerCase().contains(busqueda) ||
          equipo.tipoEquipo.toLowerCase().contains(busqueda) ||
          equipo.laboratorio.toLowerCase().contains(busqueda) ||
          equipo.estado.toLowerCase().contains(busqueda);
    }).toList();
  }

  List<Mantenimiento> get _mantenimientosAbiertos {
    return _mantenimientos.where((mantenimiento) {
      return _normalizar(mantenimiento.estadoMantenimiento) == 'ABIERTO';
    }).toList();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final equipos = await _service.obtenerEquiposParaMantenimiento();
      final mantenimientos = await _service.obtenerMantenimientos();

      if (!mounted) return;

      final idAnterior = _mantenimientoSeleccionado?.idMantenimiento;

      Mantenimiento? seleccionado;

      if (idAnterior != null) {
        for (final mantenimiento in mantenimientos) {
          if (mantenimiento.idMantenimiento == idAnterior &&
              _normalizar(mantenimiento.estadoMantenimiento) == 'ABIERTO') {
            seleccionado = mantenimiento;
            break;
          }
        }
      }

      seleccionado ??= mantenimientos.cast<Mantenimiento?>().firstWhere(
        (mantenimiento) =>
            mantenimiento != null &&
            _normalizar(mantenimiento.estadoMantenimiento) == 'ABIERTO',
        orElse: () => null,
      );

      setState(() {
        _equipos = equipos;
        _mantenimientos = mantenimientos;
        _mantenimientoSeleccionado = seleccionado;
        _cargando = false;

        if (_equipoSeleccionado != null) {
          final existe = equipos.any(
            (equipo) => equipo.idEquipo == _equipoSeleccionado!.idEquipo,
          );

          if (!existe) {
            _equipoSeleccionado = null;
          }
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _iniciarMantenimiento() async {
    if (_idUsuario == null || _idUsuario! <= 0) {
      _mostrarMensaje(
        'No se encontró el usuario de la sesión. '
        'Vuelve a iniciar sesión.',
        Colors.red,
      );
      return;
    }

    if (_equipoSeleccionado == null) {
      _mostrarMensaje(
        'Selecciona un equipo para iniciar el mantenimiento.',
        Colors.orange,
      );
      return;
    }

    final descripcion = _descripcionController.text.trim();

    if (descripcion.isEmpty) {
      _mostrarMensaje(
        'Escribe la descripción del problema o las tareas.',
        Colors.orange,
      );
      return;
    }

    setState(() => _procesando = true);

    try {
      await _service.iniciarMantenimiento(
        idUsuario: _idUsuario!,
        idEquipo: _equipoSeleccionado!.idEquipo,
        tipo: _tipoMantenimiento,
        descripcion: descripcion,
        observaciones: _observacionesIngresoController.text.trim(),
      );

      if (!mounted) return;

      _descripcionController.clear();
      _observacionesIngresoController.clear();

      _mostrarMensaje(
        'El mantenimiento fue registrado correctamente.',
        Colors.green,
      );

      await _cargarDatos();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        'No se pudo iniciar el mantenimiento: $error',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  Future<void> _finalizarMantenimiento() async {
    final mantenimiento = _mantenimientoSeleccionado;

    if (_idUsuario == null || _idUsuario! <= 0) {
      _mostrarMensaje('No se encontró el usuario de la sesión.', Colors.red);
      return;
    }

    if (mantenimiento == null ||
        _normalizar(mantenimiento.estadoMantenimiento) != 'ABIERTO') {
      _mostrarMensaje(
        'Selecciona un mantenimiento que esté abierto.',
        Colors.orange,
      );
      return;
    }

    setState(() => _procesando = true);

    try {
      await _service.finalizarMantenimiento(
        idUsuario: _idUsuario!,
        idMantenimiento: mantenimiento.idMantenimiento,
        resultado: _resultado,
        observaciones: _observacionesSalidaController.text.trim(),
      );

      if (!mounted) return;

      _observacionesSalidaController.clear();

      _mostrarMensaje(
        _resultado == 'REPARADO'
            ? 'Mantenimiento finalizado. El equipo debería quedar disponible.'
            : 'Mantenimiento finalizado. El equipo debería quedar dado de baja.',
        Colors.green,
      );

      await _cargarDatos();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje(
        'No se pudo finalizar el mantenimiento: $error',
        Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  Future<void> _mostrarHistorial(EquipoMantenimiento equipo) async {
    try {
      final historial = await _service.obtenerHistorialEquipo(equipo.idEquipo);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text('Historial: ${equipo.codigoInventario}'),
            content: SizedBox(
              width: 520,
              height: 350,
              child: historial.isEmpty
                  ? const Center(
                      child: Text(
                        'Este equipo todavía no tiene historial de mantenimiento.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: historial.length,
                      separatorBuilder: (_, _) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = historial[index];

                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.build_circle_outlined,
                            color: _colorEstado(item.estadoMantenimiento),
                          ),
                          title: Text(
                            '${item.tipo} · ${item.estadoMantenimiento}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.descripcion}\n'
                            'Inicio: ${_formatearFecha(item.fechaInicio)}\n'
                            'Fin: ${_formatearFecha(item.fechaFin)}\n'
                            'Responsable: ${item.responsable}',
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje('No se pudo consultar el historial: $error', Colors.red);
    }
  }

  void _mostrarMensaje(String mensaje, [Color color = azul]) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
  }

  String _normalizar(String texto) {
    return texto
        .trim()
        .toUpperCase()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ñ', 'N');
  }

  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'No registrada';

    String dosDigitos(int numero) => numero.toString().padLeft(2, '0');

    return '${dosDigitos(fecha.day)}/'
        '${dosDigitos(fecha.month)}/'
        '${fecha.year} '
        '${dosDigitos(fecha.hour)}:'
        '${dosDigitos(fecha.minute)}';
  }

  Color _colorEstado(String estado) {
    switch (_normalizar(estado)) {
      case 'ABIERTO':
        return Colors.orange;
      case 'FINALIZADO':
        return verde;
      case 'REPARADO':
        return verde;
      case 'NO_REPARABLE':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando && _equipos.isEmpty && _mantenimientos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: fondo,
      child: RefreshIndicator(
        onRefresh: _cargarDatos,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            _encabezado(),

            const SizedBox(height: 18),

            if (_error != null) _mensajeError(),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 950) {
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

            const SizedBox(height: 20),

            _tarjetaMantenimientos(),

            const SizedBox(height: 20),

            _tarjetaCierre(),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Row(
      children: [
        const Icon(Icons.build_circle_outlined, color: azul, size: 34),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mantenimiento',
                style: TextStyle(
                  color: azul,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Gestión de mantenimiento de equipos de laboratorio',
                style: TextStyle(color: Colors.blueGrey, fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Actualizar información',
          onPressed: _cargando || _procesando ? null : _cargarDatos,
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

  Widget _mensajeError() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_error!, style: const TextStyle(color: Colors.black87)),
          ),
          TextButton(onPressed: _cargarDatos, child: const Text('Reintentar')),
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

  Widget _tarjetaEquipos() {
    return _tarjeta(
      titulo: 'Equipos para mantenimiento',
      icono: Icons.inventory_2_outlined,
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _busquedaController,
            decoration: InputDecoration(
              hintText: 'Buscar por código, tipo, laboratorio o estado',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),

          if (_equiposFiltrados.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No hay equipos que coincidan con la búsqueda.'),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF0F5FC),
                ),
                columns: const [
                  DataColumn(label: Text('Inventario')),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Laboratorio')),
                  DataColumn(label: Text('Estado')),
                ],
                rows: _equiposFiltrados.map((equipo) {
                  final seleccionado =
                      _equipoSeleccionado?.idEquipo == equipo.idEquipo;

                  return DataRow(
                    selected: seleccionado,
                    onSelectChanged: (_) {
                      setState(() {
                        _equipoSeleccionado = equipo;
                      });
                    },
                    cells: [
                      DataCell(Text(equipo.codigoInventario)),
                      DataCell(Text(equipo.tipoEquipo)),
                      DataCell(Text(equipo.laboratorio)),
                      DataCell(_chipEstado(equipo.estado)),
                    ],
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 12),

          if (_equipoSeleccionado != null) ...[
            Text(
              'Seleccionado: ${_equipoSeleccionado!.codigoInventario}',
              style: const TextStyle(color: azul, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _mostrarHistorial(_equipoSeleccionado!),
              icon: const Icon(Icons.history),
              label: const Text('Consultar historial del equipo'),
            ),
          ],
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
          const Text(
            'Equipo seleccionado',
            style: TextStyle(color: azul, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: fondo,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD7E3F5)),
            ),
            child: Text(
              _equipoSeleccionado == null
                  ? 'Selecciona un equipo de la tabla.'
                  : '${_equipoSeleccionado!.codigoInventario}\n'
                        '${_equipoSeleccionado!.tipoEquipo} · '
                        '${_equipoSeleccionado!.laboratorio}\n'
                        'Estado: ${_equipoSeleccionado!.estado}',
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Tipo de mantenimiento',
            style: TextStyle(color: azul, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),

          DropdownButtonFormField<String>(
            initialValue: _tipoMantenimiento,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(value: 'PREVENTIVO', child: Text('Preventivo')),
              DropdownMenuItem(value: 'CORRECTIVO', child: Text('Correctivo')),
            ],
            onChanged: _procesando
                ? null
                : (valor) {
                    if (valor != null) {
                      setState(() {
                        _tipoMantenimiento = valor;
                      });
                    }
                  },
          ),

          const SizedBox(height: 14),

          const Text(
            'Descripción del problema o tareas',
            style: TextStyle(color: azul, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),

          TextField(
            controller: _descripcionController,
            minLines: 3,
            maxLines: 4,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Describe el problema o trabajo que se realizará.',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Observaciones de ingreso',
            style: TextStyle(color: azul, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),

          TextField(
            controller: _observacionesIngresoController,
            maxLines: 2,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Observaciones adicionales (opcional).',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Responsable registrado: $_nombreResponsable\n'
              'El sistema obtiene la fecha de ingreso desde el servidor.',
              style: const TextStyle(fontSize: 12, color: azul),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _procesando ? null : _iniciarMantenimiento,
              icon: const Icon(Icons.save_outlined),
              label: Text(
                _procesando ? 'Procesando...' : 'Registrar mantenimiento',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: azulClaro,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaMantenimientos() {
    return _tarjeta(
      titulo: 'Mantenimientos registrados',
      icono: Icons.assignment_outlined,
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Abiertos: ${_mantenimientosAbiertos.length} · '
                  'Total: ${_mantenimientos.length}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              IconButton(
                tooltip: 'Actualizar',
                onPressed: _procesando ? null : _cargarDatos,
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (_mantenimientos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: Text('No hay mantenimientos registrados.')),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                showCheckboxColumn: false,
                headingRowColor: WidgetStateProperty.all(
                  const Color(0xFFF0F5FC),
                ),
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Equipo')),
                  DataColumn(label: Text('Tipo')),
                  DataColumn(label: Text('Fecha de inicio')),
                  DataColumn(label: Text('Responsable')),
                  DataColumn(label: Text('Estado')),
                ],
                rows: _mantenimientos.map((mantenimiento) {
                  final seleccionado =
                      _mantenimientoSeleccionado?.idMantenimiento ==
                      mantenimiento.idMantenimiento;

                  return DataRow(
                    selected: seleccionado,
                    onSelectChanged: (_) {
                      setState(() {
                        _mantenimientoSeleccionado = mantenimiento;
                        _resultado = 'REPARADO';
                        _observacionesSalidaController.clear();
                      });
                    },
                    cells: [
                      DataCell(Text(mantenimiento.idMantenimiento.toString())),
                      DataCell(Text(mantenimiento.codigoInventario)),
                      DataCell(Text(mantenimiento.tipo)),
                      DataCell(
                        Text(_formatearFecha(mantenimiento.fechaInicio)),
                      ),
                      DataCell(Text(mantenimiento.responsable)),
                      DataCell(_chipEstado(mantenimiento.estadoMantenimiento)),
                    ],
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona un mantenimiento abierto para registrar su finalización.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaCierre() {
    final mantenimiento = _mantenimientoSeleccionado;

    final puedeFinalizar =
        mantenimiento != null &&
        _normalizar(mantenimiento.estadoMantenimiento) == 'ABIERTO';

    return _tarjeta(
      titulo: 'Finalización de mantenimiento',
      icono: Icons.assignment_turned_in_outlined,
      contenido: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mantenimiento == null)
            const Text(
              'No hay un mantenimiento seleccionado.',
              style: TextStyle(color: Colors.grey),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: fondo,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD7E3F5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mantenimiento #${mantenimiento.idMantenimiento}',
                    style: const TextStyle(
                      color: azul,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Equipo: ${mantenimiento.codigoInventario}'),
                  Text('Descripción: ${mantenimiento.descripcion}'),
                  Text('Responsable: ${mantenimiento.responsable}'),
                  Text('Inicio: ${_formatearFecha(mantenimiento.fechaInicio)}'),
                  Text('Estado: ${mantenimiento.estadoMantenimiento}'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (puedeFinalizar) ...[
              const Text(
                'Resultado de la reparación',
                style: TextStyle(color: azul, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _opcionResultado(
                    'REPARADO',
                    'Equipo disponible',
                    verde,
                    Icons.check_circle_outline,
                  ),
                  _opcionResultado(
                    'NO_REPARABLE',
                    'Equipo dado de baja',
                    Colors.red,
                    Icons.cancel_outlined,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Text(
                'Informe final y observaciones',
                style: TextStyle(color: azul, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 7),

              TextField(
                controller: _observacionesSalidaController,
                minLines: 2,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Describe el resultado de la reparación.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _procesando ? null : _finalizarMantenimiento,
                  icon: const Icon(Icons.lock_outline),
                  label: Text(
                    _procesando ? 'Procesando...' : 'Finalizar mantenimiento',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: azulClaro,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ] else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Este mantenimiento ya no está abierto. '
                  'No se puede finalizar nuevamente.',
                  style: TextStyle(color: Colors.black87),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _opcionResultado(
    String valor,
    String subtitulo,
    Color color,
    IconData icono,
  ) {
    final seleccionado = _resultado == valor;

    return InkWell(
      onTap: _procesando
          ? null
          : () {
              setState(() => _resultado = valor);
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
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
                  valor == 'REPARADO' ? 'Reparado' : 'No reparable',
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

  Widget _chipEstado(String estado) {
    final normalizado = _normalizar(estado);
    final color = _colorEstado(normalizado);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
