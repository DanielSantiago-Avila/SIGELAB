import 'package:flutter/material.dart';
import 'laboratorio_model.dart';
import 'laboratorio_service.dart';

class LaboratoriosScreen extends StatefulWidget {
  const LaboratoriosScreen({super.key});

  @override
  State<LaboratoriosScreen> createState() => _LaboratoriosScreenState();
}

class _LaboratoriosScreenState extends State<LaboratoriosScreen> {
  final LaboratorioService _service = LaboratorioService();

  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _capacidadController = TextEditingController();
  final _busquedaController = TextEditingController();

  final Color primaryDark = const Color(0xFF163C66);

  List<Laboratorio> _listaLaboratorios = [];
  List<Laboratorio> _listaFiltrada = [];
  bool _cargando = true;
  bool _procesando = false;
  Laboratorio? _laboratorioSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarLaboratorios();
    _busquedaController.addListener(_filtrarLaboratorios);
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _ubicacionController.dispose();
    _descripcionController.dispose();
    _capacidadController.dispose();
    _busquedaController.dispose();
    super.dispose();
  }

  Future<void> _cargarLaboratorios() async {
    setState(() => _cargando = true);
    final datos = await _service.obtenerLaboratorios();
    setState(() {
      _listaLaboratorios = datos;
      _listaFiltrada = datos;
      _cargando = false;
    });
    _filtrarLaboratorios();
  }

  void _filtrarLaboratorios() {
    final query = _busquedaController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _listaFiltrada = _listaLaboratorios;
      } else {
        _listaFiltrada = _listaLaboratorios.where((lab) {
          return lab.nombre.toLowerCase().contains(query) ||
                 lab.codigo.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _seleccionarFila(Laboratorio lab) {
    setState(() {
      if (_laboratorioSeleccionado?.idLaboratorio == lab.idLaboratorio) {
        _limpiarFormulario();
      } else {
        _laboratorioSeleccionado = lab;
        _codigoController.text = lab.codigo;
        _nombreController.text = lab.nombre;
        _ubicacionController.text = lab.ubicacion;
        _descripcionController.text = lab.descripcion;
        _capacidadController.text = lab.capacidad.toString();
      }
    });
  }

  void _limpiarFormulario() {
    _codigoController.clear();
    _nombreController.clear();
    _ubicacionController.clear();
    _descripcionController.clear();
    _capacidadController.clear();
    setState(() => _laboratorioSeleccionado = null);
  }

        Future<void> _guardarONuevo() async {
        if (_codigoController.text.trim().isEmpty || _nombreController.text.trim().isEmpty) {
          _mostrarMensaje('El código y el nombre son obligatorios', Colors.orange);
          return;
        }

        setState(() => _procesando = true);

        // Estructura limpia exacta para sp_laboratorio_crear / sp_laboratorio_actualizar
        final Map<String, dynamic> datosJson = {
          'codigo': _codigoController.text.trim(),
          'nombre': _nombreController.text.trim(),
          'ubicacion': _ubicacionController.text.trim(),
          'descripcion': _descripcionController.text.trim(),
          'capacidad': int.tryParse(_capacidadController.text.trim()) ?? 0,
        };

        bool exito;
        if (_laboratorioSeleccionado == null) {
          exito = await _service.crearLaboratorio(datosJson);
        } else {
          datosJson['id_laboratorio'] = _laboratorioSeleccionado!.idLaboratorio;
          exito = await _service.actualizarLaboratorio(datosJson);
        }

        setState(() => _procesando = false);

        if (exito) {
          _mostrarMensaje('Operación realizada con éxito', Colors.green);
          _limpiarFormulario();
          _cargarLaboratorios();
        } else {
          _mostrarMensaje('Error al procesar solicitud', Colors.red);
        }
}

  Future<void> _cambiarEstado() async {
    if (_laboratorioSeleccionado == null) return;

    setState(() => _procesando = true);
    final nuevoEstado = !_laboratorioSeleccionado!.activo;
    
    bool exito = await _service.cambiarEstadoLaboratorio(
      _laboratorioSeleccionado!.idLaboratorio,
      nuevoEstado,
    );

    setState(() => _procesando = false);

    if (exito) {
      _mostrarMensaje('Estado cambiado correctamente', Colors.green);
      _limpiarFormulario();
      _cargarLaboratorios();
    } else {
      _mostrarMensaje('Error al cambiar estado', Colors.red);
    }
  }

  void _mostrarMensaje(String texto, Color col) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto), backgroundColor: col),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FORMULARIO
          _buildHeader(_laboratorioSeleccionado == null ? 'Nuevo Laboratorio' : 'Editar Laboratorio'),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _boxStyle(),
            child: Column(
              children: [
                _buildField('Código de laboratorio', _codigoController),
                const SizedBox(height: 12),
                _buildField('Nombre del laboratorio', _nombreController),
                const SizedBox(height: 12),
                _buildField('Ubicación', _ubicacionController),
                const SizedBox(height: 12),
                _buildField('Descripción', _descripcionController),
                const SizedBox(height: 12),
                _buildField('Capacidad', _capacidadController, isNum: true),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton(
                      style: _btnStyle(primaryDark),
                      onPressed: _procesando ? null : _guardarONuevo,
                      child: Text(_laboratorioSeleccionado == null ? 'Guardar' : 'Actualizar', style: const TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: _btnStyle(const Color(0xFFC5A059)),
                      onPressed: _limpiarFormulario,
                      child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          // BÚSQUEDA Y ACCIONES
          _buildHeader('Acciones y búsqueda'),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: _boxStyle(),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Búsqueda por nombre de laboratorio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _busquedaController,
                  decoration: InputDecoration(
                    hintText: 'Ej. DEM026-LAB-RED',
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
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
                    ElevatedButton(
                      style: _btnStyle(primaryDark),
                      onPressed: _limpiarFormulario,
                      child: const Text(
                        'Agregar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: _btnStyle(
                        _laboratorioSeleccionado != null
                            ? primaryDark
                            : Colors.grey,
                      ),
                      onPressed: _laboratorioSeleccionado != null
                          ? _guardarONuevo
                          : null,
                      child: const Text(
                        'Modificar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: _btnStyle(
                        _laboratorioSeleccionado != null
                            ? primaryDark
                            : Colors.grey,
                      ),
                      onPressed: _laboratorioSeleccionado != null
                          ? _cambiarEstado
                          : null,
                      child: const Text(
                        'Cambiar estado',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          ),

          const SizedBox(height: 24),

          // TABLA
          _buildHeader('Lista de laboratorios'),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: _boxStyle(),
            child: _cargando
                ? const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                : _listaFiltrada.isEmpty
                    ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No hay laboratorios registrados.')))
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: const [
                            DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Nombre', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Ubicación', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Capacidad', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _listaFiltrada.map((lab) {
                            final isSel = _laboratorioSeleccionado?.idLaboratorio == lab.idLaboratorio;
                            return DataRow(
                              selected: isSel,
                              onSelectChanged: (_) => _seleccionarFila(lab),
                              cells: [
                                DataCell(Text(lab.idLaboratorio.toString())),
                                DataCell(Text(lab.codigo)),
                                DataCell(Text(lab.nombre)),
                                DataCell(Text(lab.ubicacion)),
                                DataCell(Text(lab.descripcion)),
                                DataCell(Text(lab.capacidad.toString())),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: lab.activo ? Colors.green.shade100 : Colors.red.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      lab.activo ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        color: lab.activo ? Colors.green.shade800 : Colors.red.shade800,
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
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
      border: Border.all(color: const Color(0xFFE2E8F0)),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  ButtonStyle _btnStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}