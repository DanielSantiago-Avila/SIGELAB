import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'equipo_model.dart';
import 'equipos_inventario_service.dart';
import 'widgets/equipo_form_dialog.dart';

class EquiposInventarioScreen extends StatefulWidget {
  final int idUsuarioAccionante;

  const EquiposInventarioScreen({
    super.key,
    required this.idUsuarioAccionante,
  });

  @override
  State<EquiposInventarioScreen> createState() =>
      _EquiposInventarioScreenState();
}

class _EquiposInventarioScreenState
    extends State<EquiposInventarioScreen> {
  static const Color azul = Color(0xFF163C66);
  static const Color fondo = Color(0xFFF4F6F9);

  final EquiposInventarioService _service =
      EquiposInventarioService();

  final TextEditingController _buscador =
      TextEditingController();

  List<EquipoModel> _equipos = [];
  List<Map<String, dynamic>> _tiposEquipo = [];
  List<Map<String, dynamic>> _laboratorios = [];

  bool _cargando = true;
  String? _error;
  String _filtroEstado = 'TODOS';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  // CARGAR EQUIPOS, TIPOS Y LABORATORIOS
  Future<void> _cargarDatos() async {
    if (!mounted) return;

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final resultados = await Future.wait([
        _service.listar(
          busqueda: _buscador.text.trim(),
        ),
        _service.listarTipos(),
        _service.listarLaboratorios(),
      ]);

      if (!mounted) return;

      setState(() {
        _equipos = resultados[0] as List<EquipoModel>;
        _tiposEquipo =
            resultados[1] as List<Map<String, dynamic>>;
        _laboratorios =
            resultados[2] as List<Map<String, dynamic>>;
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

  // BUSCAR EQUIPOS
  Future<void> _buscar() async {
    await _cargarDatos();
  }

  // FILTRAR EQUIPOS POR ESTADO
  List<EquipoModel> get _equiposFiltrados {
    if (_filtroEstado == 'TODOS') {
      return _equipos;
    }

    return _equipos.where((equipo) {
      return _normalizar(equipo.estado) ==
          _normalizar(_filtroEstado);
    }).toList();
  }

  // NORMALIZAR TEXTOS
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

  // NOMBRE VISIBLE DEL ESTADO
  String _nombreEstado(String estado) {
    switch (_normalizar(estado)) {
      case 'DISPONIBLE':
        return 'Disponible';
      case 'PRESTADO':
        return 'Prestado';
      case 'DANADO':
        return 'Dañado';
      case 'MANTENIMIENTO':
        return 'En mantenimiento';
      case 'BAJA':
      case 'DADO DE BAJA':
        return 'Dado de baja';
      default:
        return estado.isEmpty ? 'Sin estado' : estado;
    }
  }

  // COLOR SEGÚN EL ESTADO
  Color _colorEstado(String estado) {
    switch (_normalizar(estado)) {
      case 'DISPONIBLE':
        return Colors.green;
      case 'PRESTADO':
        return Colors.orange;
      case 'DANADO':
        return Colors.red;
      case 'MANTENIMIENTO':
        return Colors.deepOrange;
      case 'BAJA':
      case 'DADO DE BAJA':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  // FORMULARIO DE REGISTRO Y EDICIÓN
  // Los controladores pertenecen a EquipoFormDialog.
  // Esta pantalla ya no los crea ni los destruye.
  Future<void> _mostrarFormulario({
    EquipoModel? equipo,
  }) async {
    final editando = equipo != null;

    try {
      final datos = await EquipoFormDialog.mostrar(
        context,
        equipo: equipo,
        tiposEquipo: _tiposEquipo,
        laboratorios: _laboratorios,
      );

      // Si se cancela el formulario, no se realiza ninguna operación.
      if (datos == null || !mounted) return;

      // Registrar un equipo nuevo.
      if (editando) {
        // Actualizar equipo existente.
        await _service.actualizar(
          idEquipo: equipo.idEquipo,
          idUsuarioAccionante: widget.idUsuarioAccionante,
          datos: datos,
        );
      } else {
        // Crear equipo nuevo.
        await _service.crear(
          idUsuarioAccionante: widget.idUsuarioAccionante,
          datos: datos,
        );
      }

      if (!mounted) return;

      // Recargar información después de guardar.
      await _cargarDatos();

      if (!mounted) return;

      _mensaje(
        editando
            ? 'Equipo actualizado correctamente.'
            : 'Equipo registrado correctamente.',
      );
    } catch (e) {
      if (!mounted) return;

      _mensaje('No se pudo guardar el equipo: $e');
    }
  }

  // MOSTRAR MENSAJES
  void _mensaje(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
      ),
    );
  }

  // MOSTRAR CÓDIGO QR
  void _mostrarQr(EquipoModel equipo) {
    final contenido = equipo.codigoQR.trim().isNotEmpty
        ? equipo.codigoQR
        : equipo.codigoInventario;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Código QR del equipo',
            style: TextStyle(
              color: azul,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImageView(
                  data: contenido,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 12),
                Text(
                  equipo.codigoInventario,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${equipo.marca} ${equipo.modelo}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // MOSTRAR DETALLE DEL EQUIPO
  void _mostrarDetalle(EquipoModel equipo) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Detalle del equipo',
            style: TextStyle(color: azul),
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _detalle('Código', equipo.codigoInventario),
                  _detalle('Tipo', equipo.tipoEquipo),
                  _detalle('Marca', equipo.marca),
                  _detalle('Modelo', equipo.modelo),
                  _detalle('Serie', equipo.numeroSerie),
                  _detalle('Laboratorio', equipo.laboratorio),
                  _detalle(
                    'Estado',
                    _nombreEstado(equipo.estado),
                  ),
                  _detalle(
                    'Observaciones',
                    equipo.observaciones,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                _mostrarQr(equipo);
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('Ver QR'),
            ),
          ],
        );
      },
    );
  }

  // CAMPO DE INFORMACIÓN DEL DETALLE
  Widget _detalle(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: azul,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valor.isEmpty ? 'No disponible' : valor,
            style: const TextStyle(
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // TARJETA DE CADA EQUIPO
  Widget _tarjetaEquipo(EquipoModel equipo) {
    final colorEstado = _colorEstado(equipo.estado);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE2E8F0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE8F0FB),
                  child: Icon(
                    Icons.devices_outlined,
                    color: azul,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        equipo.codigoInventario,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: azul,
                        ),
                      ),
                      Text(
                        '${equipo.marca} ${equipo.modelo}'.trim(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorEstado.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _nombreEstado(equipo.estado),
                    style: TextStyle(
                      color: colorEstado,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Wrap(
              spacing: 22,
              runSpacing: 12,
              children: [
                _datoEquipo('Tipo', equipo.tipoEquipo),
                _datoEquipo('Serie', equipo.numeroSerie),
                _datoEquipo('Laboratorio', equipo.laboratorio),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Ver detalles',
                  onPressed: () {
                    _mostrarDetalle(equipo);
                  },
                  icon: const Icon(
                    Icons.visibility_outlined,
                  ),
                ),
                IconButton(
                  tooltip: 'Generar QR',
                  onPressed: () {
                    _mostrarQr(equipo);
                  },
                  icon: const Icon(
                    Icons.qr_code_2,
                    color: azul,
                  ),
                ),
                IconButton(
                  tooltip: 'Editar equipo',
                  onPressed: () {
                    _mostrarFormulario(equipo: equipo);
                  },
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: azul,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // INFORMACIÓN RESUMIDA DEL EQUIPO
  Widget _datoEquipo(String titulo, String valor) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            valor.isEmpty ? 'No disponible' : valor,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondo,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ENCABEZADO
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            spacing: 12,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Equipos / Inventario',
                    style: TextStyle(
                      color: azul,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Registro y administración de equipos universitarios',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _cargando ? null : _cargarDatos,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualizar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: azul,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _mostrarFormulario();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar equipo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: azul,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          // BUSCADOR
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _buscador,
                  onSubmitted: (_) => _buscar(),
                  decoration: InputDecoration(
                    hintText:
                        'Buscar por código, marca, modelo o serie',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                tooltip: 'Buscar',
                onPressed: _buscar,
                style: IconButton.styleFrom(
                  backgroundColor: azul,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.search),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // FILTRO DE ESTADO
          Row(
            children: [
              const Text(
                'Filtrar estado:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: azul,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _filtroEstado,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: 'TODOS',
                      child: Text('Todos'),
                    ),
                    DropdownMenuItem(
                      value: 'DISPONIBLE',
                      child: Text('Disponible'),
                    ),
                    DropdownMenuItem(
                      value: 'PRESTADO',
                      child: Text('Prestado'),
                    ),
                    DropdownMenuItem(
                      value: 'DANADO',
                      child: Text('Dañado'),
                    ),
                    DropdownMenuItem(
                      value: 'MANTENIMIENTO',
                      child: Text('En mantenimiento'),
                    ),
                    DropdownMenuItem(
                      value: 'BAJA',
                      child: Text('Dado de baja'),
                    ),
                  ],
                  onChanged: (valor) {
                    if (valor != null) {
                      setState(() {
                        _filtroEstado = valor;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_equiposFiltrados.length} equipos',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // LISTA DE EQUIPOS
          Expanded(
            child: _cargando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 55,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No fue posible cargar los equipos.',
                              style: TextStyle(
                                color: azul,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _cargarDatos,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      )
                    : _equiposFiltrados.isEmpty
                        ? const Center(
                            child: Text(
                              'No se encontraron equipos registrados.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _equiposFiltrados.length,
                            itemBuilder: (context, index) {
                              return _tarjetaEquipo(
                                _equiposFiltrados[index],
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}