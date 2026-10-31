import 'package:flutter/material.dart';

import 'usuario_model.dart';
import 'usuario_service.dart';
import '../sesion/sesion_usuario.dart';

class UsuariosScreen extends StatefulWidget {
  final int? idUsuarioAccionante;

  const UsuariosScreen({super.key, this.idUsuarioAccionante});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  final UsuarioService _service = UsuarioService();
  final TextEditingController _buscador = TextEditingController();
  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _tiposSolicitante = [];
  bool get esAdministrador => SesionUsuario.esAdministrador;

  static const Color azul = Color(0xFF163C66);
  static const Color fondo = Color(0xFFF3F5F9);

  List<Usuario> _usuarios = [];
  bool _cargando = false;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
    _cargarRolesYTipos();
  }

  @override
  void dispose() {
    _buscador.dispose();
    super.dispose();
  }

  Future<void> _cargarRolesYTipos() async {
    try {
      final roles = await _service.listarRoles();
      final tipos = await _service.listarTiposSolicitante();

      if (!mounted) return;

      setState(() {
        _roles = roles;
        _tiposSolicitante = tipos;
      });

      debugPrint('ROLES RECIBIDOS: ${_roles.length}');
      debugPrint(
        'TIPOS DE SOLICITANTE RECIBIDOS: '
        '${_tiposSolicitante.length}',
      );
    } catch (e) {
      debugPrint('Error al cargar roles y tipos: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar roles y tipos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cargarUsuarios() async {
    if (_cargando) return;

    setState(() => _cargando = true);

    try {
      final usuarios = await _service.listar();

      if (!mounted) return;

      setState(() {
        _usuarios = usuarios;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar usuarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  List<Usuario> get _usuariosFiltrados {
    final texto = _filtro.toLowerCase().trim();

    return _usuarios.where((usuario) {
      return usuario.nombreCompleto.toLowerCase().contains(texto) ||
          usuario.usuario.toLowerCase().contains(texto) ||
          usuario.correo.toLowerCase().contains(texto) ||
          usuario.codigoPersonal.toLowerCase().contains(texto);
    }).toList();
  }

  Widget _detalle(String etiqueta, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            etiqueta,
            style: const TextStyle(fontWeight: FontWeight.bold, color: azul),
          ),
          const SizedBox(height: 3),
          SelectableText(valor),
        ],
      ),
    );
  }

  // FORMULARIO PARA AGREGAR ESTUDIANTE
  void _mostrarFormularioEstudiante() {
    final formKey = GlobalKey<FormState>();

    final nombreController = TextEditingController();
    final apellidoController = TextEditingController();
    final codigoController = TextEditingController();
    final correoController = TextEditingController();
    final usuarioController = TextEditingController();
    final passwordController = TextEditingController();

    bool ocultarPassword = true;
    int? idRolSeleccionado = 3;
    int? idTipoSolicitanteSeleccionado = 1;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.person_add, color: azul),
                  SizedBox(width: 10),
                  Text('Agregar usuario'),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (valor) =>
                              valor == null || valor.trim().isEmpty
                              ? 'Ingresa el nombre'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: apellidoController,
                          decoration: const InputDecoration(
                            labelText: 'Apellido',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (valor) =>
                              valor == null || valor.trim().isEmpty
                              ? 'Ingresa el apellido'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: codigoController,
                          decoration: const InputDecoration(
                            labelText: 'Código personal',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: (valor) =>
                              valor == null || valor.trim().isEmpty
                              ? 'Ingresa el código personal'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Ingresa el correo';
                            }
                            if (!valor.contains('@') || !valor.contains('.')) {
                              return 'Correo electrónico inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: usuarioController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de usuario',
                            prefixIcon: Icon(Icons.account_circle),
                          ),
                          validator: (valor) =>
                              valor == null || valor.trim().isEmpty
                              ? 'Ingresa el usuario'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
                          obscureText: ocultarPassword,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                ocultarPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setDialogState(() {
                                  ocultarPassword = !ocultarPassword;
                                });
                              },
                            ),
                          ),
                          validator: (valor) {
                            if (valor == null || valor.isEmpty) {
                              return 'Ingresa una contraseña';
                            }
                            if (valor.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<int>(
                          initialValue: idRolSeleccionado,
                          decoration: const InputDecoration(
                            labelText: 'Rol del usuario',
                            prefixIcon: Icon(Icons.admin_panel_settings),
                          ),
                          items: _roles.map((rol) {
                            return DropdownMenuItem<int>(
                              value: (rol['idRol'] as num).toInt(),
                              child: Text(rol['nombre'].toString()),
                            );
                          }).toList(),
                          onChanged: (valor) {
                            setDialogState(() {
                              idRolSeleccionado = valor;

                              if (valor == 3) {
                                idTipoSolicitanteSeleccionado = 1;
                              } else {
                                idTipoSolicitanteSeleccionado = null;
                              }
                            });
                          },
                          validator: (valor) =>
                              valor == null ? 'Selecciona un rol' : null,
                        ),

                        if (idRolSeleccionado == 3) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: idTipoSolicitanteSeleccionado,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de solicitante',
                              prefixIcon: Icon(Icons.school),
                            ),
                            items: _tiposSolicitante.map((tipo) {
                              return DropdownMenuItem<int>(
                                value: (tipo['idTipoSolicitante'] as num)
                                    .toInt(),
                                child: Text(tipo['nombre'].toString()),
                              );
                            }).toList(),
                            onChanged: (valor) {
                              setDialogState(() {
                                idTipoSolicitanteSeleccionado = valor;
                              });
                            },
                            validator: (valor) =>
                                valor == null ? 'Selecciona un tipo' : null,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final idAccionante = SesionUsuario.idUsuario;

                    if (!SesionUsuario.esAdministrador ||
                        idAccionante == null) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'No tienes permisos para crear usuarios.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    if (idRolSeleccionado == null) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(content: Text('Selecciona un rol.')),
                      );
                      return;
                    }

                    // PREPARADO PARA CUANDO TENGAMOS HTTPS.
                    //
                    // IMPORTANTE:
                    // Actualmente el registro real está deshabilitado.
                    // No enviamos contraseñas mediante HTTP.

                    try {
                      final resultado = await _service.crear(
                        idUsuarioAccionante: idAccionante,
                        idRol: idRolSeleccionado!,
                        idTipoSolicitante: idRolSeleccionado == 3
                            ? idTipoSolicitanteSeleccionado
                            : null,
                        nombre: nombreController.text,
                        apellido: apellidoController.text,
                        codigoPersonal: codigoController.text,
                        correo: correoController.text,
                        usuario: usuarioController.text,
                        passwordHash: passwordController.text,
                      );

                      if (!mounted || !dialogContext.mounted) return;

                      if (resultado['exito'] == false) {
                        throw Exception(
                          resultado['mensaje'] ??
                              'No se pudo crear el usuario.',
                        );
                      }

                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          content: Text('Usuario creado correctamente.'),
                          backgroundColor: Colors.green,
                        ),
                      );

                      await _cargarUsuarios();
                    } catch (e) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text('Error al crear usuario: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },

                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _mostrarFormularioEditar(Usuario usuario) async {
    final formKey = GlobalKey<FormState>();

    final nombreController = TextEditingController(text: usuario.nombre);
    final apellidoController = TextEditingController(text: usuario.apellido);
    final codigoController = TextEditingController(
      text: usuario.codigoPersonal,
    );
    final correoController = TextEditingController(text: usuario.correo);
    final usuarioController = TextEditingController(text: usuario.usuario);
    final passwordController = TextEditingController();

    int? idRolSeleccionado = usuario.idRol;
    int? idTipoSolicitanteSeleccionado = usuario.idTipoSolicitante;

    bool guardando = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Editar usuario'),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                          ),
                          validator: (valor) =>
                              valor == null || valor.trim().isEmpty
                              ? 'Ingresa el nombre'
                              : null,
                        ),
                        TextFormField(
                          controller: apellidoController,
                          decoration: const InputDecoration(
                            labelText: 'Apellido',
                          ),
                          validator: (valor) =>
                              valor == null || valor.trim().isEmpty
                              ? 'Ingresa el apellido'
                              : null,
                        ),
                        TextFormField(
                          controller: codigoController,
                          decoration: const InputDecoration(
                            labelText: 'Código personal',
                          ),
                          validator: (valor) =>
                              valor == null || valor.trim().isEmpty
                              ? 'Ingresa el código'
                              : null,
                        ),
                        TextFormField(
                          controller: correoController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                          ),
                          validator: (valor) {
                            if (valor == null || valor.trim().isEmpty) {
                              return 'Ingresa el correo';
                            }
                            if (!valor.contains('@') || !valor.contains('.')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: usuarioController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de usuario',
                          ),
                          validator: (valor) =>
                              valor == null || valor.trim().isEmpty
                              ? 'Ingresa el usuario'
                              : null,
                        ),

                        const SizedBox(height: 12),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Nueva contraseña (opcional)',
                            prefixIcon: Icon(Icons.lock_outline),
                            helperText: 'Déjalo vacío para conservar la contraseña actual',
                          ),
                          validator: (valor) {
                            if (valor != null &&
                                valor.isNotEmpty &&
                                valor.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),
                        DropdownButtonFormField<int>(
                          initialValue: idRolSeleccionado,
                          decoration: const InputDecoration(labelText: 'Rol'),
                          items: _roles.map((rol) {
                            return DropdownMenuItem<int>(
                              value: (rol['idRol'] as num).toInt(),
                              child: Text(rol['nombre'].toString()),
                            );
                          }).toList(),
                          onChanged: guardando
                              ? null
                              : (valor) {
                                  setDialogState(() {
                                    idRolSeleccionado = valor;
                                    if (valor != 3) {
                                      idTipoSolicitanteSeleccionado = null;
                                    }
                                  });
                                },
                          validator: (valor) =>
                              valor == null ? 'Selecciona un rol' : null,
                        ),
                        if (idRolSeleccionado == 3) ...[
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            key: ValueKey(idRolSeleccionado),
                            initialValue: idTipoSolicitanteSeleccionado,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de solicitante',
                            ),
                            items: _tiposSolicitante.map((tipo) {
                              return DropdownMenuItem<int>(
                                value: (tipo['idTipoSolicitante'] as num)
                                    .toInt(),
                                child: Text(tipo['nombre'].toString()),
                              );
                            }).toList(),
                            onChanged: guardando
                                ? null
                                : (valor) {
                                    setDialogState(() {
                                      idTipoSolicitanteSeleccionado = valor;
                                    });
                                  },
                            validator: (valor) =>
                                valor == null ? 'Selecciona un tipo' : null,
                          ),
                        ],
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
                ElevatedButton.icon(
                  onPressed: guardando
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }
                          final idAccionante = SesionUsuario.idUsuario;

                          if (!SesionUsuario.esAdministrador ||
                              idAccionante == null ||
                              idRolSeleccionado == null) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No tienes permisos para editar.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            guardando = true;
                          });

                          try {
                            await _service.actualizar(
                              idUsuarioAccionante: idAccionante,
                              idUsuario: usuario.idUsuario,
                              idRol: idRolSeleccionado!,
                              idTipoSolicitante: idRolSeleccionado == 3
                                  ? idTipoSolicitanteSeleccionado
                                  : null,
                              nombre: nombreController.text,
                              apellido: apellidoController.text,
                              codigoPersonal: codigoController.text,
                              correo: correoController.text,
                              usuario: usuarioController.text,
                              passwordHash: passwordController.text,
                            );
                            if (!mounted || !dialogContext.mounted) {
                              return;
                            }

                            final messenger = ScaffoldMessenger.of(
                              this.context,
                            );

                            Navigator.pop(dialogContext);

                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Usuario actualizado correctamente.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );

                            await _cargarUsuarios();
                          } catch (e) {
                            if (!mounted || !dialogContext.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text('Error al actualizar: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );

                            final tieneNuevaPassword =
                                passwordController.text.isNotEmpty;

                            debugPrint(
                              '¿El usuario escribió una nueva contraseña? '
                              '$tieneNuevaPassword',
                            );

                            setDialogState(() {
                              guardando = false;
                            });
                          }
                        },
                  icon: const Icon(Icons.save),
                  label: Text(guardando ? 'Guardando...' : 'Guardar cambios'),
                ),
              ],
            );
          },
        );
      },
    );

    nombreController.dispose();
    apellidoController.dispose();
    codigoController.dispose();
    correoController.dispose();
    usuarioController.dispose();
    passwordController.dispose();
  }

  // ACTIVAR O DESACTIVAR USUARIO
  Future<void> _cambiarEstadoUsuario(Usuario usuario) async {
    if (!esAdministrador || SesionUsuario.idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permisos para esta acción.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final accion = usuario.activo ? 'desactivar' : 'activar';

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Confirmar ${accion == 'activar' ? 'activación' : 'desactivación'}',
        ),
        content: Text('¿Deseas $accion al usuario ${usuario.nombreCompleto}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar != true || !mounted) return;

    try {
      await _service.cambiarEstado(
        idUsuario: usuario.idUsuario,
        idUsuarioAccionante: SesionUsuario.idUsuario!,
      );

      if (!mounted) return;

      await _cargarUsuarios();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solicitud de cambio de estado completada.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // MOSTRAR DETALLES DEL USUARIO
  void _mostrarDetalle(Usuario usuario) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Detalle del usuario'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detalle('ID', '${usuario.idUsuario}'),
                _detalle('Nombre', usuario.nombreCompleto),
                _detalle('Usuario', usuario.usuario),
                _detalle('Código personal', usuario.codigoPersonal),
                _detalle('Correo', usuario.correo),
                _detalle('Rol', usuario.rol),
                _detalle(
                  'Tipo de solicitante',
                  usuario.tipoSolicitante ?? 'No aplica',
                ),
                _detalle('Estado', usuario.activo ? 'Activo' : 'Inactivo'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cerrar'),
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
          // ENCABEZADO Y BOTONES
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gestión de Usuarios',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: azul,
                    ),
                  ),
                  Text(
                    'Administra los usuarios registrados en SIGELAB',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),

              // BOTÓN ACTUALIZAR
              OutlinedButton.icon(
                onPressed: _cargando ? null : _cargarUsuarios,
                icon: _cargando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_cargando ? 'Actualizando...' : 'Actualizar'),
              ),

              // BOTÓN AGREGAR ESTUDIANTE
              if (esAdministrador)
                ElevatedButton.icon(
                  onPressed: _mostrarFormularioEstudiante,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Agregar usuario'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: azul,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // BUSCADOR
          TextField(
            controller: _buscador,
            onChanged: (valor) {
              setState(() => _filtro = valor);
            },
            decoration: InputDecoration(
              hintText: 'Buscar por nombre, usuario, correo o código',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // LISTADO DE USUARIOS
          Expanded(
            child: _cargando && _usuarios.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Card(
                    child: _usuariosFiltrados.isEmpty
                        ? const Center(
                            child: Text('No se encontraron usuarios'),
                          )
                        : ListView.separated(
                            itemCount: _usuariosFiltrados.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final usuario = _usuariosFiltrados[index];

                              return ListTile(
                                contentPadding: const EdgeInsets.all(14),
                                leading: CircleAvatar(
                                  backgroundColor: azul.withValues(alpha: 0.10),
                                  child: const Icon(Icons.person, color: azul),
                                ),
                                title: Text(
                                  usuario.nombreCompleto,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${usuario.usuario} · ${usuario.rol}\n'
                                  '${usuario.correo}',
                                ),
                                isThreeLine: true,
                                trailing: Wrap(
                                  spacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Chip(
                                      label: Text(
                                        usuario.activo ? 'Activo' : 'Inactivo',
                                      ),
                                      backgroundColor: usuario.activo
                                          ? Colors.green.shade100
                                          : Colors.grey.shade200,
                                    ),

                                    // BOTÓN VER DETALLES
                                    IconButton(
                                      tooltip: 'Ver detalles',
                                      icon: const Icon(
                                        Icons.visibility,
                                        color: azul,
                                      ),
                                      onPressed: () {
                                        _mostrarDetalle(usuario);
                                      },
                                    ),

                                    // BOTÓN EDITAR USUARIO - SOLO ADMIN
                                    if (esAdministrador)
                                      IconButton(
                                        tooltip: 'Editar usuario',
                                        icon: const Icon(
                                          Icons.edit,
                                          color: azul,
                                        ),
                                        onPressed: () {
                                          _mostrarFormularioEditar(usuario);
                                        },
                                      ),

                                    // BOTÓN ACTIVAR / DESACTIVAR - SOLO ADMIN
                                    if (esAdministrador)
                                      IconButton(
                                        tooltip: usuario.activo
                                            ? 'Desactivar usuario'
                                            : 'Activar usuario',
                                        icon: Icon(
                                          usuario.activo
                                              ? Icons.person_off
                                              : Icons.person_add_alt_1,
                                          color: usuario.activo
                                              ? Colors.red
                                              : Colors.green,
                                        ),
                                        onPressed: () {
                                          _cambiarEstadoUsuario(usuario);
                                        },
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
    );
  }
}
