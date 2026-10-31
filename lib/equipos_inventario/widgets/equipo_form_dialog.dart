import 'package:flutter/material.dart';

import '../equipo_model.dart';

class EquipoFormDialog extends StatefulWidget {
  final EquipoModel? equipo;
  final List<Map<String, dynamic>> tiposEquipo;
  final List<Map<String, dynamic>> laboratorios;

  const EquipoFormDialog({
    super.key,
    this.equipo,
    required this.tiposEquipo,
    required this.laboratorios,
  });

  static Future<Map<String, dynamic>?> mostrar(
    BuildContext context, {
    EquipoModel? equipo,
    required List<Map<String, dynamic>> tiposEquipo,
    required List<Map<String, dynamic>> laboratorios,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => EquipoFormDialog(
        equipo: equipo,
        tiposEquipo: tiposEquipo,
        laboratorios: laboratorios,
      ),
    );
  }

  @override
  State<EquipoFormDialog> createState() => _EquipoFormDialogState();
}

class _EquipoFormDialogState extends State<EquipoFormDialog> {
  static const Color azul = Color(0xFF163C66);

  final GlobalKey<FormState> _formulario = GlobalKey<FormState>();

  late final TextEditingController _codigo;
  late final TextEditingController _marca;
  late final TextEditingController _modelo;
  late final TextEditingController _serie;
  late final TextEditingController _observaciones;

  int? _tipoSeleccionado;
  int? _laboratorioSeleccionado;

  String _estadoSeleccionado = 'DISPONIBLE';

  final bool _guardando = false;

  bool get _editando => widget.equipo != null;

  @override
  void initState() {
    super.initState();

    final equipo = widget.equipo;

    _codigo = TextEditingController(
      text: equipo?.codigoInventario ?? '',
    );

    _marca = TextEditingController(
      text: equipo?.marca ?? '',
    );

    _modelo = TextEditingController(
      text: equipo?.modelo ?? '',
    );

    _serie = TextEditingController(
      text: equipo?.numeroSerie ?? '',
    );

    _observaciones = TextEditingController(
      text: equipo?.observaciones ?? '',
    );

    _tipoSeleccionado = equipo?.idTipoEquipo;
    _laboratorioSeleccionado = equipo?.idLaboratorio;

    _estadoSeleccionado = equipo?.estado.isNotEmpty == true
        ? equipo!.estado
        : 'DISPONIBLE';

    // Evita valores iniciales que no estén disponibles en los catálogos.
    if (!_idsTipos.contains(_tipoSeleccionado)) {
      _tipoSeleccionado = null;
    }

    if (!_idsLaboratorios.contains(_laboratorioSeleccionado)) {
      _laboratorioSeleccionado = null;
    }

    const estadosPermitidos = [
      'DISPONIBLE',
      'PRESTADO',
      'DANADO',
      'MANTENIMIENTO',
      'BAJA',
    ];

    if (!estadosPermitidos.contains(_estadoSeleccionado)) {
      _estadoSeleccionado = 'DISPONIBLE';
    }
  }

  @override
  void dispose() {
    _codigo.dispose();
    _marca.dispose();
    _modelo.dispose();
    _serie.dispose();
    _observaciones.dispose();
    super.dispose();
  }

  int? _obtenerId(
    Map<String, dynamic> registro,
    List<String> campos,
  ) {
    for (final campo in campos) {
      final valor = registro[campo];

      if (valor != null) {
        return int.tryParse(valor.toString());
      }
    }

    return null;
  }

  String _obtenerNombre(
    Map<String, dynamic> registro,
    List<String> campos,
  ) {
    for (final campo in campos) {
      final valor = registro[campo];

      if (valor != null && valor.toString().trim().isNotEmpty) {
        return valor.toString();
      }
    }

    return 'Sin nombre';
  }

  List<int?> get _idsTipos {
    return widget.tiposEquipo.map((tipo) {
      return _obtenerId(
        tipo,
        ['idTipoEquipo', 'IdTipoEquipo', 'id'],
      );
    }).toList();
  }

  List<int?> get _idsLaboratorios {
    return widget.laboratorios.map((laboratorio) {
      return _obtenerId(
        laboratorio,
        ['idLaboratorio', 'IdLaboratorio', 'id'],
      );
    }).toList();
  }

  Widget _campo(
    TextEditingController controller,
    String etiqueta, {
    bool obligatorio = false,
    int lineas = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: lineas,
        decoration: InputDecoration(
          labelText: etiqueta,
          border: const OutlineInputBorder(),
        ),
        validator: obligatorio
            ? (valor) {
                if (valor == null || valor.trim().isEmpty) {
                  return 'Este campo es obligatorio';
                }

                return null;
              }
            : null,
      ),
    );
  }

  void _guardar() {
    if (!_formulario.currentState!.validate()) {
      return;
    }

    if (_tipoSeleccionado == null ||
        _laboratorioSeleccionado == null) {
      return;
    }

    Navigator.pop(
      context,
      <String, dynamic>{
        'codigoInventario': _codigo.text.trim(),
        'idTipoEquipo': _tipoSeleccionado,
        'marca': _marca.text.trim(),
        'modelo': _modelo.text.trim(),
        'numeroSerie': _serie.text.trim(),
        'idLaboratorio': _laboratorioSeleccionado,
        'estado': _estadoSeleccionado,
        'observaciones': _observaciones.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        _editando ? 'Editar equipo' : 'Registrar equipo',
        style: const TextStyle(
          color: azul,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formulario,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campo(
                  _codigo,
                  'Código de inventario',
                  obligatorio: true,
                ),

                DropdownButtonFormField<int>(
                  initialValue: _tipoSeleccionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de equipo',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.tiposEquipo.map((tipo) {
                    final id = _obtenerId(
                      tipo,
                      ['idTipoEquipo', 'IdTipoEquipo', 'id'],
                    );

                    if (id == null) return null;

                    final nombre = _obtenerNombre(
                      tipo,
                      ['nombre', 'Nombre', 'tipoEquipo'],
                    );

                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(nombre),
                    );
                  }).whereType<DropdownMenuItem<int>>().toList(),
                  onChanged: _guardando
                      ? null
                      : (valor) {
                          setState(() {
                            _tipoSeleccionado = valor;
                          });
                        },
                  validator: (valor) {
                    return valor == null
                        ? 'Selecciona un tipo de equipo'
                        : null;
                  },
                ),

                const SizedBox(height: 14),

                _campo(_marca, 'Marca'),
                _campo(_modelo, 'Modelo'),
                _campo(_serie, 'Número de serie'),

                DropdownButtonFormField<int>(
                  initialValue: _laboratorioSeleccionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Laboratorio',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.laboratorios.map((laboratorio) {
                    final id = _obtenerId(
                      laboratorio,
                      ['idLaboratorio', 'IdLaboratorio', 'id'],
                    );

                    if (id == null) return null;

                    final nombre = _obtenerNombre(
                      laboratorio,
                      ['nombre', 'Nombre'],
                    );

                    return DropdownMenuItem<int>(
                      value: id,
                      child: Text(nombre),
                    );
                  }).whereType<DropdownMenuItem<int>>().toList(),
                  onChanged: _guardando
                      ? null
                      : (valor) {
                          setState(() {
                            _laboratorioSeleccionado = valor;
                          });
                        },
                  validator: (valor) {
                    return valor == null
                        ? 'Selecciona un laboratorio'
                        : null;
                  },
                ),

                const SizedBox(height: 14),

                DropdownButtonFormField<String>(
                  initialValue: _estadoSeleccionado,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
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
                  onChanged: _guardando
                      ? null
                      : (valor) {
                          if (valor != null) {
                            setState(() {
                              _estadoSeleccionado = valor;
                            });
                          }
                        },
                ),

                const SizedBox(height: 14),

                _campo(
                  _observaciones,
                  'Observaciones',
                  lineas: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _guardando
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: _guardando ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: azul,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar'),
        ),
      ],
    );
  }
}