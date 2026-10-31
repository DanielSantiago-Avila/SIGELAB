import 'package:flutter/material.dart';

import '../sesion/sesion_usuario.dart';
import 'laboratorio_model.dart';
import 'laboratorio_service.dart';

class LaboratoriosScreen extends StatefulWidget {
  const LaboratoriosScreen({super.key});

  @override
  State<LaboratoriosScreen> createState() => _LaboratoriosScreenState();
}

class _LaboratoriosScreenState extends State<LaboratoriosScreen> {
  final LaboratorioService _service = LaboratorioService();

  final _formKey = GlobalKey<FormState>();

  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _busquedaController = TextEditingController();

  final Color primaryDark = const Color(0xFF163C66);

  List<Laboratorio> _listaLaboratorios = [];
  List<Laboratorio> _listaFiltrada = [];

  Laboratorio? _laboratorioSeleccionado;

  bool _cargando = true;
  bool _procesando = false;

  String? _errorCarga;

  @override
  void initState() {
    super.initState();

    _busquedaController.addListener(_filtrarLaboratorios);

    _cargarLaboratorios();
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _ubicacionController.dispose();
    _descripcionController.dispose();
    _capacidadController.dispose();

    _busquedaController.removeListener(_filtrarLaboratorios);
    _busquedaController.dispose();

    super.dispose();
  }

  // ============================================================
  // CARGAR LABORATORIOS DESDE LA API
  // ============================================================

  Future<void> _cargarLaboratorios() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final datos = await _service.obtenerLaboratorios();

      if (!mounted) return;

      setState(() {
        _listaLaboratorios = datos;
      });

      _filtrarLaboratorios();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorCarga = error.toString();
        _listaLaboratorios = [];
        _listaFiltrada = [];
      });
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  // ============================================================
  // FILTRAR LABORATORIOS
  // ============================================================

  void _filtrarLaboratorios() {
    if (!mounted) return;

    final busqueda = _busquedaController.text.toLowerCase().trim();

    final resultados = _listaLaboratorios.where((laboratorio) {
      return laboratorio.nombre.toLowerCase().contains(busqueda) ||
          laboratorio.codigo.toLowerCase().contains(busqueda) ||
          laboratorio.ubicacion.toLowerCase().contains(busqueda);
    }).toList();

    setState(() {
      _listaFiltrada = resultados;
    });
  }

  // ============================================================
  // SELECCIONAR LABORATORIO
  // ============================================================

  void _seleccionarFila(Laboratorio laboratorio) {
    setState(() {
      if (_laboratorioSeleccionado?.idLaboratorio ==
          laboratorio.idLaboratorio) {
        _laboratorioSeleccionado = null;

        _codigoController.clear();
        _nombreController.clear();
        _ubicacionController.clear();
        _descripcionController.clear();
        _capacidadController.clear();
      } else {
        _laboratorioSeleccionado = laboratorio;

        _codigoController.text = laboratorio.codigo;
        _nombreController.text = laboratorio.nombre;
        _ubicacionController.text = laboratorio.ubicacion;
        _descripcionController.text = laboratorio.descripcion;
        _capacidadController.text = laboratorio.capacidad.toString();
      }
    });
  }

  // ============================================================
  // LIMPIAR FORMULARIO
  // ============================================================

  void _limpiarFormulario() {
    _codigoController.clear();
    _nombreController.clear();
    _ubicacionController.clear();
    _descripcionController.clear();
    _capacidadController.clear();

    setState(() {
      _laboratorioSeleccionado = null;
    });
  }

  // ============================================================
  // VALIDAR USUARIO DE LA SESIÓN
  // ============================================================

  int? get _idUsuarioActual {
    final id = SesionUsuario.idUsuario;

    if (id == null || id <= 0) {
      return null;
    }

    return id;
  }

  // ============================================================
  // CREAR O ACTUALIZAR LABORATORIO
  // ============================================================

  Future<void> _guardarONuevo() async {
    if (_procesando) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final idUsuario = _idUsuarioActual;

    if (idUsuario == null) {
      _mostrarMensaje(
        'No se encontró una sesión de usuario válida. Vuelve a iniciar sesión.',
        Colors.red,
      );
      return;
    }

    final codigo = _codigoController.text.trim();
    final nombre = _nombreController.text.trim();
    final ubicacion = _ubicacionController.text.trim();
    final descripcion = _descripcionController.text.trim();
    final capacidad = int.parse(_capacidadController.text.trim());

    final seleccionado = _laboratorioSeleccionado;

    setState(() => _procesando = true);

    try {
      if (seleccionado == null) {
        // CREAR LABORATORIO
        await _service.crearLaboratorio(
          idUsuarioAccionante: idUsuario,
          codigo: codigo,
          nombre: nombre,
          ubicacion: ubicacion,
          descripcion: descripcion,
          capacidad: capacidad,
        );

        if (!mounted) return;

        _mostrarMensaje(
          'Solicitud de creación enviada correctamente.',
          Colors.green,
        );
      } else {
        // ACTUALIZAR LABORATORIO
        await _service.actualizarLaboratorio(
          idUsuarioAccionante: idUsuario,
          idLaboratorio: seleccionado.idLaboratorio,
          nombre: nombre,
          ubicacion: ubicacion,
          capacidad: capacidad,
        );

        if (!mounted) return;

        _mostrarMensaje(
          'Solicitud de actualización enviada correctamente.',
          Colors.green,
        );
      }

      _limpiarFormulario();

      await _cargarLaboratorios();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje('No se pudo guardar el laboratorio: $error', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  // ============================================================
  // CAMBIAR ESTADO DEL LABORATORIO
  // ============================================================

  Future<void> _cambiarEstado() async {
    final laboratorio = _laboratorioSeleccionado;

    if (_procesando || laboratorio == null) {
      return;
    }

    if (laboratorio.activo == null) {
      _mostrarMensaje(
        'La API no proporcionó el estado de este laboratorio.',
        Colors.orange,
      );
      return;
    }

    final nuevoEstado = !laboratorio.activo!;

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar cambio de estado'),
          content: Text(
            nuevoEstado
                ? '¿Deseas activar el laboratorio ${laboratorio.codigo}?'
                : '¿Deseas desactivar el laboratorio ${laboratorio.codigo}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmado != true || !mounted) {
      return;
    }

    setState(() => _procesando = true);

    try {
      await _service.cambiarEstadoLaboratorio(
        idLaboratorio: laboratorio.idLaboratorio,
        nuevoEstado: nuevoEstado,
      );

      if (!mounted) return;

      _mostrarMensaje(
        nuevoEstado
            ? 'Solicitud de activación enviada correctamente.'
            : 'Solicitud de desactivación enviada correctamente.',
        Colors.green,
      );

      _limpiarFormulario();

      await _cargarLaboratorios();
    } catch (error) {
      if (!mounted) return;

      _mostrarMensaje('No se pudo cambiar el estado: $error', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _procesando = false);
      }
    }
  }

  // ============================================================
  // MOSTRAR MENSAJES
  // ============================================================

  void _mostrarMensaje(String texto, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: color,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ============================================================
  // CONSTRUIR PANTALLA
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final seleccionado = _laboratorioSeleccionado;

    return RefreshIndicator(
      onRefresh: _cargarLaboratorios,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FORMULARIO
            _buildHeader(
              seleccionado == null
                  ? 'Nuevo Laboratorio'
                  : 'Editar Laboratorio #${seleccionado.idLaboratorio}',
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _boxStyle(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(
                      'Código de laboratorio',
                      _codigoController,
                      enabled: !_procesando && seleccionado == null,
                      obligatorio: true,
                    ),

                    const SizedBox(height: 12),

                    _buildField(
                      'Nombre del laboratorio',
                      _nombreController,
                      enabled: !_procesando,
                      obligatorio: true,
                    ),

                    const SizedBox(height: 12),

                    _buildField(
                      'Ubicación',
                      _ubicacionController,
                      enabled: !_procesando,
                      obligatorio: true,
                    ),

                    const SizedBox(height: 12),

                    _buildField(
                      'Descripción',
                      _descripcionController,
                      enabled: !_procesando && seleccionado == null,
                      maxLines: 2,
                    ),

                    const SizedBox(height: 12),

                    _buildField(
                      'Capacidad',
                      _capacidadController,
                      enabled: !_procesando,
                      isNum: true,
                      obligatorio: true,
                    ),

                    const SizedBox(height: 20),

                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          style: _btnStyle(primaryDark),
                          onPressed: _procesando ? null : _guardarONuevo,
                          icon: Icon(
                            seleccionado == null ? Icons.save : Icons.edit,
                            color: Colors.white,
                          ),
                          label: Text(
                            seleccionado == null ? 'Guardar' : 'Actualizar',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),

                        ElevatedButton.icon(
                          style: _btnStyle(const Color(0xFFC5A059)),
                          onPressed: _procesando ? null : _limpiarFormulario,
                          icon: const Icon(Icons.clear, color: Colors.white),
                          label: const Text(
                            'Cancelar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    if (_procesando) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],

                    if (seleccionado != null) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'En la actualización actual, el código y la descripción '
                        'se conservan sin modificaciones.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // BÚSQUEDA Y ACCIONES
            _buildHeader('Acciones y búsqueda'),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: _boxStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buscar por código, nombre o ubicación',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      hintText: 'Ej. DEMO26-LAB-RED',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        tooltip: 'Limpiar búsqueda',
                        onPressed: _busquedaController.clear,
                        icon: const Icon(Icons.clear),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        style: _btnStyle(primaryDark),
                        onPressed: _limpiarFormulario,
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          'Agregar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      ElevatedButton.icon(
                        style: _btnStyle(
                          seleccionado != null ? primaryDark : Colors.grey,
                        ),
                        onPressed: seleccionado != null && !_procesando
                            ? _guardarONuevo
                            : null,
                        icon: const Icon(Icons.edit, color: Colors.white),
                        label: const Text(
                          'Modificar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      ElevatedButton.icon(
                        style: _btnStyle(
                          seleccionado != null && seleccionado.activo != null
                              ? primaryDark
                              : Colors.grey,
                        ),
                        onPressed:
                            seleccionado != null &&
                                seleccionado.activo != null &&
                                !_procesando
                            ? _cambiarEstado
                            : null,
                        icon: const Icon(Icons.toggle_on, color: Colors.white),
                        label: const Text(
                          'Cambiar estado',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),

                      OutlinedButton.icon(
                        onPressed: _cargando ? null : _cargarLaboratorios,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Actualizar lista'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // LISTA DE LABORATORIOS
            _buildHeader('Lista de laboratorios'),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: _boxStyle(),
              child: _construirContenidoTabla(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTENIDO DE LA TABLA
  // ============================================================

  Widget _construirContenidoTabla() {
    if (_cargando) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorCarga != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.cloud_off, color: Colors.red, size: 42),
            const SizedBox(height: 12),
            const Text(
              'No fue posible cargar los laboratorios.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_errorCarga!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _cargarLaboratorios,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_listaFiltrada.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('No hay laboratorios que coincidan con la búsqueda.'),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(
            label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              'Código',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Nombre',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Ubicación',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Descripción',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Capacidad',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              'Estado',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows: _listaFiltrada.map((laboratorio) {
          final seleccionado =
              _laboratorioSeleccionado?.idLaboratorio ==
              laboratorio.idLaboratorio;

          final Color colorEstado;

          if (laboratorio.activo == true) {
            colorEstado = Colors.green;
          } else if (laboratorio.activo == false) {
            colorEstado = Colors.red;
          } else {
            colorEstado = Colors.grey;
          }

          final String textoEstado;

          if (laboratorio.activo == true) {
            textoEstado = 'Activo';
          } else if (laboratorio.activo == false) {
            textoEstado = 'Inactivo';
          } else {
            textoEstado = 'No disponible';
          }

          return DataRow(
            selected: seleccionado,
            onSelectChanged: (_) {
              if (!_procesando) {
                _seleccionarFila(laboratorio);
              }
            },
            cells: [
              DataCell(Text(laboratorio.idLaboratorio.toString())),
              DataCell(Text(laboratorio.codigo)),
              DataCell(Text(laboratorio.nombre)),
              DataCell(Text(laboratorio.ubicacion)),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    laboratorio.descripcion,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text(laboratorio.capacidad.toString())),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    textoEstado,
                    style: TextStyle(
                      color: colorEstado,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // COMPONENTES VISUALES
  // ============================================================

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    bool isNum = false,
    bool obligatorio = false,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),

        const SizedBox(height: 6),

        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: !enabled,
            fillColor: const Color(0xFFF1F5F9),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            final texto = value?.trim() ?? '';

            if (obligatorio && texto.isEmpty) {
              return 'Este campo es obligatorio.';
            }

            if (isNum && texto.isNotEmpty) {
              final numero = int.tryParse(texto);

              if (numero == null || numero < 0) {
                return 'Ingresa un número entero válido.';
              }
            }

            return null;
          },
        ),
      ],
    );
  }

  ButtonStyle _btnStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
