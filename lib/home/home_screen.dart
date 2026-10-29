import 'package:flutter/material.dart';
import 'package:sigelab/laboratorio/laboratorios_screen.dart';

import '../login/login_screen.dart';
import '../mantenimiento/mantenimiento_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final String nombreUsuario;
  final String rol;

  const HomeScreen({
    super.key,
    this.nombreUsuario = 'Gerson Jiménez',
    this.rol = 'Administrador',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Color primaryDark = const Color(0xFF163C66);

  // Todas las opciones se definen una sola vez
  // para mantener sincronizados el menú móvil y el de escritorio.
  final List<_MenuEntry> _menuItems = const [
    _MenuEntry(index: 0, icon: Icons.grid_view_rounded, title: 'Dashboard'),
    _MenuEntry(index: 1, icon: Icons.people_outline, title: 'Usuarios'),
    _MenuEntry(index: 2, icon: Icons.science_outlined, title: 'Laboratorios'),
    _MenuEntry(
      index: 3,
      icon: Icons.devices_outlined,
      title: 'Tipos de Equipo',
    ),
    _MenuEntry(
      index: 4,
      icon: Icons.inventory_2_outlined,
      title: 'Inventario y Equipos',
    ),
    _MenuEntry(index: 5, icon: Icons.front_hand_outlined, title: 'Préstamos'),
    _MenuEntry(index: 6, icon: Icons.replay, title: 'Devoluciones'),
    _MenuEntry(index: 7, icon: Icons.build_outlined, title: 'Mantenimiento'),
    _MenuEntry(index: 8, icon: Icons.bar_chart_outlined, title: 'Reportes'),
    _MenuEntry(index: 9, icon: Icons.fact_check_outlined, title: 'Auditoría'),
  ];

  // Genera las iniciales a partir del nombre del usuario.
  String _obtenerIniciales(String nombre) {
    final nombreLimpio = nombre.trim();

    if (nombreLimpio.isEmpty) {
      return 'US';
    }

    final partes = nombreLimpio.split(RegExp(r'\s+'));

    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }

    return partes[0][0].toUpperCase();
  }

  // Cierra la sesión y regresa a la pantalla de inicio de sesión.
  void _cerrarSesion() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final iniciales = _obtenerIniciales(widget.nombreUsuario);
    final anchoPantalla = MediaQuery.sizeOf(context).width;
    final esPantallaPequena = anchoPantalla < 700;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6F9),

      // MENÚ MÓVIL
      drawer: esPantallaPequena
          ? Drawer(
              child: SafeArea(
                child: Column(
                  children: [
                    DrawerHeader(
                      margin: EdgeInsets.zero,
                      decoration: BoxDecoration(color: primaryDark),
                      child: const Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'SIGELAB',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'PORTAL UNIVERSITARIO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SIGELAB · ADMINISTRADOR',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),

                    // El menú móvil contiene las mismas opciones
                    // que el menú de escritorio.
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [..._menuItems.map(_buildDrawerMenuItem)],
                      ),
                    ),

                    // Perfil y cierre de sesión en la parte inferior.
                    _buildMobileDrawerProfile(iniciales),
                  ],
                ),
              ),
            )
          : null,

      // CONTENIDO RESPONSIVE
      body: SafeArea(
        child: Row(
          children: [
            // MENÚ LATERAL DE ESCRITORIO
            if (!esPantallaPequena)
              Container(
                width: 250,
                color: Colors.white,
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Logo y subtítulo.
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SIGELAB',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            'PORTAL UNIVERSITARIO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Navegación lateral.
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            child: Text(
                              'SIGELAB · ADMINISTRADOR',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          ..._menuItems.map(_buildMenuItem),
                        ],
                      ),
                    ),

                    // Perfil y cierre de sesión.
                    _buildDesktopProfile(iniciales),
                  ],
                ),
              ),

            // El separador solo se muestra cuando existe
            // el menú lateral de escritorio.
            if (!esPantallaPequena)
              const VerticalDivider(
                width: 1,
                thickness: 1,
                color: Color(0xFFE2E8F0),
              ),

            // ÁREA PRINCIPAL
            Expanded(
              child: Column(
                children: [
                  // ENCABEZADO SUPERIOR
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: esPantallaPequena ? 8 : 24,
                      vertical: esPantallaPequena ? 8 : 18,
                    ),
                    color: Colors.white,
                    child: Row(
                      children: [
                        // Botón para abrir el menú en móviles.
                        if (esPantallaPequena)
                          IconButton(
                            icon: const Icon(Icons.menu),
                            color: primaryDark,
                            tooltip: 'Abrir menú',
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),

                        // Título de la sección actual.
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!esPantallaPequena)
                                const Text(
                                  'PANEL ADMINISTRATIVO',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(
                                _obtenerTitulo(_selectedIndex),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: esPantallaPequena ? 17 : 26,
                                  fontWeight: FontWeight.bold,
                                  color: primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // En móvil se utiliza un avatar compacto
                        // para evitar desbordamientos horizontales.
                        _buildHeaderProfile(
                          iniciales,
                          compacto: esPantallaPequena,
                        ),
                      ],
                    ),
                  ),

                  // PANTALLA SELECCIONADA
                  Expanded(child: _buildBodyContent()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ELEMENTO DEL MENÚ MÓVIL
  Widget _buildDrawerMenuItem(_MenuEntry item) {
    final seleccionado = _selectedIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: seleccionado ? const Color(0xFFE8F0FB) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        selected: seleccionado,
        leading: Icon(
          item.icon,
          color: seleccionado ? primaryDark : Colors.black87,
          size: 21,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: seleccionado ? primaryDark : Colors.black87,
            fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          setState(() {
            _selectedIndex = item.index;
          });

          // Cierra el menú después de seleccionar una opción.
          Navigator.pop(context);
        },
      ),
    );
  }

  // ELEMENTO DEL MENÚ DE ESCRITORIO
  Widget _buildMenuItem(_MenuEntry item) {
    final seleccionado = _selectedIndex == item.index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: seleccionado ? primaryDark : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          item.icon,
          color: seleccionado ? Colors.white : Colors.black87,
          size: 20,
        ),
        title: Text(
          item.title,
          style: TextStyle(
            color: seleccionado ? Colors.white : Colors.black87,
            fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          setState(() {
            _selectedIndex = item.index;
          });
        },
      ),
    );
  }

  // PERFIL DEL USUARIO EN EL MENÚ MÓVIL
  Widget _buildMobileDrawerProfile(String iniciales) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFD5E5FA),
                child: Text(
                  iniciales,
                  style: TextStyle(
                    color: primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nombreUsuario,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      widget.rol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout, size: 20),
            title: const Text('Cerrar sesión'),
            onTap: _cerrarSesion,
          ),
        ],
      ),
    );
  }

  // PERFIL DEL USUARIO EN EL MENÚ DE ESCRITORIO
  Widget _buildDesktopProfile(String iniciales) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFD0E1F9),
                child: Text(
                  iniciales,
                  style: TextStyle(
                    color: primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nombreUsuario,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      widget.rol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          InkWell(
            onTap: _cerrarSesion,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Cerrar sesión',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // PERFIL COMPACTO EN EL ENCABEZADO
  Widget _buildHeaderProfile(String iniciales, {required bool compacto}) {
    if (compacto) {
      return Tooltip(
        message: '${widget.nombreUsuario} · ${widget.rol}',
        child: CircleAvatar(
          radius: 17,
          backgroundColor: primaryDark,
          child: Text(
            iniciales,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 130),
            child: Text(
              '${widget.nombreUsuario} · ${widget.rol}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 12,
            backgroundColor: primaryDark,
            child: Text(
              iniciales,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CONTENIDO SEGÚN LA OPCIÓN SELECCIONADA
  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 0:
        // Dashboard integrado.
        return DashboardScreen();

      case 2:
        // Pantalla de laboratorios existente.
        return const LaboratoriosScreen();

      case 7:
        // Pantalla de mantenimiento integrada.
        return const MantenimientoScreen();

      default:
        // Los demás módulos conservan su opción en el menú,
        // pero permanecen pendientes de desarrollo o integración.
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.construction_outlined, size: 70, color: primaryDark),
                const SizedBox(height: 16),
                Text(
                  _obtenerTitulo(_selectedIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Este módulo está pendiente de desarrollo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        );
    }
  }

  // TÍTULO DINÁMICO DE LA CABECERA
  String _obtenerTitulo(int index) {
    switch (index) {
      case 0:
        return 'Dashboard General';
      case 1:
        return 'Gestión de Usuarios';
      case 2:
        return 'Gestión de Laboratorios';
      case 3:
        return 'Tipos de Equipo';
      case 4:
        return 'Inventario y Equipos';
      case 5:
        return 'Préstamos de Equipos';
      case 6:
        return 'Devoluciones';
      case 7:
        return 'Mantenimiento';
      case 8:
        return 'Reportes';
      case 9:
        return 'Auditoría';
      default:
        return 'Dashboard General';
    }
  }
}

// Modelo de cada opción de navegación.
class _MenuEntry {
  final int index;
  final IconData icon;
  final String title;

  const _MenuEntry({
    required this.index,
    required this.icon,
    required this.title,
  });
}
