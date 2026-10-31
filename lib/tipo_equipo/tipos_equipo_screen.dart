
import 'package:flutter/material.dart';
import 'tipo_equipo_model.dart';
import 'tipo_equipo_service.dart';


class TiposEquipoScreen extends StatefulWidget {
  final int? idUsuarioAccionante;

  const TiposEquipoScreen({
    super.key,
    this.idUsuarioAccionante,
  });

  @override
  State<TiposEquipoScreen> createState() =>
      _TiposEquipoScreenState();
}


class _TiposEquipoScreenState extends State<TiposEquipoScreen> {
  final TipoEquipoService _service = TipoEquipoService();
  final TextEditingController _buscador = TextEditingController();

  List<TipoEquipo> _equipos = [];
  bool _cargando = true;
  String _filtro = '';

  static const Color azul = Color(0xFF163C66);
  static const Color fondo = Color(0xFFF3F5F9);

  @override
  void initState() {
    super.initState();
    _cargarEquipos();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _cargarEquipos() async {
    setState(() => _cargando = true);

    try {
      final datos = await _service.listar();
      
debugPrint('TIPOS EQUIPO RECIBIDOS: ${datos.length}');


      if (!mounted) return;

      setState(() {
        _equipos = datos;
        _cargando = false;
      });
    } catch (e) {
      
debugPrint('ERROR AL CARGAR TIPOS DE EQUIPO: $e');
      if (!mounted) return;
      setState(() => _cargando = false);
      _mensaje('Error al cargar: $e');
    }
  }

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  List<TipoEquipo> get _filtrados {
    final texto = _filtro.toLowerCase().trim();

    return _equipos.where((equipo) {
      return equipo.nombre.toLowerCase().contains(texto) ||
          equipo.codigo.toLowerCase().contains(texto) ||
          (equipo.marca ?? '').toLowerCase().contains(texto) ||
          (equipo.modelo ?? '').toLowerCase().contains(texto);
    }).toList();
  }

  Future<void> _mostrarFormulario({TipoEquipo? equipo}) async {
    final editando = equipo != null;

    final codigo = TextEditingController(
      text: equipo?.codigo ?? '',
    );
    final nombre = TextEditingController(
      text: equipo?.nombre ?? '',
    );
    final marca = TextEditingController(
      text: equipo?.marca ?? '',
    );
    final modelo = TextEditingController(
      text: equipo?.modelo ?? '',
    );
    final descripcion = TextEditingController(
      text: equipo?.descripcion ?? '',
    );

    final formulario = GlobalKey<FormState>();
    bool guardando = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, actualizarDialogo) {
          return AlertDialog(
            title: Text(
              editando
                  ? 'Editar tipo de equipo'
                  : 'Agregar tipo de equipo',
              style: const TextStyle(color: azul),
            ),
            content: SizedBox(
              width: 450,
              child: SingleChildScrollView(
                child: Form(
                  key: formulario,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _campo(codigo, 'Código', obligatorio: true),
                      _campo(nombre, 'Nombre', obligatorio: true),
                      _campo(marca, 'Marca'),
                      _campo(modelo, 'Modelo'),
                      _campo(
                        descripcion,
                        'Descripción',
                        lineas: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: guardando
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: azul,
                  foregroundColor: Colors.white,
                ),
                onPressed: guardando
                    ? null
                    : () async {
                        if (!formulario.currentState!.validate()) {
                          return;
                        }

                        actualizarDialogo(
                          () => guardando = true,
                        );

                        try {
                          final datos = TipoEquipo(
                            idTipoEquipo: equipo?.idTipoEquipo ?? 0,
                            codigo: codigo.text.trim(),
                            nombre: nombre.text.trim(),
                            marca: marca.text.trim(),
                            modelo: modelo.text.trim(),
                            descripcion: descripcion.text.trim(),
                            activo: equipo?.activo ?? true,
                          );

                          

final idUsuario = widget.idUsuarioAccionante;

if (idUsuario == null) {
  throw Exception(
    'No se ha recibido el usuario autenticado. '
    'Solicita la integración de la sesión.',
  );
}

if (editando) {
  await _service.actualizar(
    datos,
    idUsuarioAccionante: idUsuario,
  );
} else {
  await _service.crear(
    datos,
    idUsuarioAccionante: idUsuario,
  );
}



                          if (!dialogContext.mounted) return;
                          Navigator.pop(dialogContext);

                          if (!mounted) return;
                          await _cargarEquipos();

                          if (!mounted) return;
                          _mensaje(
                            editando
                                ? 'Tipo de equipo actualizado'
                                : 'Tipo de equipo creado',
                          );
                        } catch (e) {
                          if (!dialogContext.mounted) return;
                          actualizarDialogo(
                            () => guardando = false,
                          );

                          if (!mounted) return;
                          _mensaje('No se pudo guardar: $e');
                        }
                      },
                child: Text(
                  guardando ? 'Guardando...' : 'Guardar',
                ),
              ),
            ],
          );
        },
      ),
    );
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

 
Future<void> _mostrarDetalle(TipoEquipo equipo) async {
  // Mostramos una ventana mientras consultamos AWS.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => const AlertDialog(
      content: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text('Cargando detalles...'),
        ],
      ),
    ),
  );

  try {
    // Consultamos el equipo real por su ID.
    final detalle = await _service.obtenerPorId(
      equipo.idTipoEquipo,
    );

    if (!mounted) return;

    // Cerramos la ventana de carga.
    Navigator.of(context, rootNavigator: true).pop();

    // Mostramos la información recibida desde AWS.
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Detalle del tipo de equipo',
          style: TextStyle(color: azul),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${detalle.codigo}'),
            Text('Nombre: ${detalle.nombre}'),
            Text('Marca: ${detalle.marca ?? "-"}'),
            Text('Modelo: ${detalle.modelo ?? "-"}'),
            Text(
              'Descripción: ${detalle.descripcion ?? "-"}',
            ),
            Text(
              'Estado: ${detalle.activo ? "Activo" : "Inactivo"}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  } catch (e) {
    if (!mounted) return;

    // Cerramos la ventana de carga.
    Navigator.of(context, rootNavigator: true).pop();

    // Informamos si hubo un problema.
    _mensaje('Error al obtener detalles: $e');
  }
}


  Future<void> _cambiarEstado(TipoEquipo equipo) async {
    final accion = equipo.activo ? 'desactivar' : 'activar';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar $accion'),
        content: Text(
          '¿Deseas $accion el tipo de equipo "${equipo.nombre}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      
final idUsuario = widget.idUsuarioAccionante;

if (idUsuario == null) {
  throw Exception(
    'No se ha recibido el usuario autenticado. '
    'Solicita la integración de la sesión.',
  );
}

if (equipo.activo) {
  await _service.desactivar(
    equipo.idTipoEquipo,
    idUsuarioAccionante: idUsuario,
  );
} else {
  await _service.activar(
    equipo.idTipoEquipo,
    idUsuarioAccionante: idUsuario,
  );
}


      if (!mounted) return;
      await _cargarEquipos();

      if (!mounted) return;
      _mensaje('Estado actualizado correctamente');
    } catch (e) {
      if (!mounted) return;
      _mensaje('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: fondo,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              spacing: 16,
              runSpacing: 12,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Tipos de Equipo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: azul,
                      ),
                    ),
                    Text(
                      'Administra los tipos de equipo registrados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                
            OutlinedButton.icon(
              onPressed: _cargando ? null : _cargarEquipos,
              icon: _cargando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh),
              label: Text(
                _cargando ? 'Actualizando...' : 'Actualizar',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: azul,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                side: const BorderSide(color: azul),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

                ElevatedButton.icon(
                  onPressed: () => _mostrarFormulario(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nuevo tipo de equipo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azul,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _buscador,
              onChanged: (valor) {
                setState(() => _filtro = valor);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por código, nombre, marca o modelo',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Card(
                      child: _filtrados.isEmpty
                          ? const Center(
                              child: Text(
                                'No se encontraron tipos de equipo',
                              ),
                            )
                          : ListView.separated(
                              itemCount: _filtrados.length,
                              separatorBuilder: (_, _) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final equipo = _filtrados[index];

                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.all(16),
                                  leading: const CircleAvatar(
                                    backgroundColor: fondo,
                                    child: Icon(
                                      Icons.devices,
                                      color: azul,
                                    ),
                                  ),
                                  title: Text(
                                    equipo.nombre,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${equipo.codigo} | '
                                    '${equipo.marca ?? "-"} | '
                                    '${equipo.modelo ?? "-"}',
                                  ),
                                  trailing: Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 6,
                                    children: [
                                      Chip(
                                        label: Text(
                                          equipo.activo
                                              ? 'Activo'
                                              : 'Inactivo',
                                        ),
                                        backgroundColor: equipo.activo
                                            ? Colors.green.shade100
                                            : Colors.grey.shade200,
                                      ),
                                      IconButton(
                                        tooltip: 'Ver detalles',
                                        icon: const Icon(
                                          Icons.visibility,
                                        ),
                                        onPressed: () =>
                                            _mostrarDetalle(equipo),
                                      ),
                                      IconButton(
                                        tooltip: 'Editar',
                                        icon: const Icon(
                                          Icons.edit,
                                          color: azul,
                                        ),
                                        onPressed: () =>
                                            _mostrarFormulario(
                                          equipo: equipo,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: equipo.activo
                                            ? 'Desactivar'
                                            : 'Activar',
                                        icon: Icon(
                                          Icons.power_settings_new,
                                          color: equipo.activo
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                        onPressed: () =>
                                            _cambiarEstado(equipo),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
