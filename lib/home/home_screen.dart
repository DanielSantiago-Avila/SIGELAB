import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import 'package:sigelab/laboratorio/laboratorios_screen.dart';
import 'package:sigelab/tipo_equipo/tipos_equipo_screen.dart';



class HomeScreen extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario;
  final String rol;

  const HomeScreen({
    super.key,
    required this.idUsuario,
    this.nombreUsuario = 'Usuario',
    this.rol = 'Administrador',
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Azul institucional de SIGELAB
  final Color primaryDark = const Color(0xFF163C66);

  // Helper para generar las iniciales del nombre (ej. Gerson Jiménez -> GJ)
  String _obtenerIniciales(String nombre) {
    if (nombre.trim().isEmpty) return 'US';
    List<String> partes = nombre.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return partes[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final iniciales = _obtenerIniciales(widget.nombreUsuario);

    final anchoPantalla = MediaQuery.sizeOf(context).width;
    final esPantallaPequena = anchoPantalla < 700;

    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF4F6F9),
        drawer: esPantallaPequena
    ? Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
              const DrawerHeader(
                child: Text(
                  'SIGELAB',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {
                  setState(() => _selectedIndex = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_outline),
                title: const Text('Usuarios'),
                onTap: () {
                  setState(() => _selectedIndex = 1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.science_outlined),
                title: const Text('Laboratorios'),
                onTap: () {
                  setState(() => _selectedIndex = 2);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.devices_outlined),
                title: const Text('Tipos de Equipo'),
                onTap: () {
                  setState(() => _selectedIndex = 3);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Inventario y Equipos'),
                onTap: () {
                  setState(() => _selectedIndex = 4);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.front_hand_outlined),
                title: const Text('Préstamos'),
                onTap: () {
                  setState(() => _selectedIndex = 5);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.replay),
                title: const Text('Devoluciones'),
                  onTap: () {
                    setState(() => _selectedIndex = 6);

              Navigator.pop(context);
                            },
                          ), // Cierra ListTile de Devoluciones
                        ], // Cierra children del ListView
                      ), // Cierra ListView
                    ), // Cierra Expanded

                    // Tarjeta de perfil al fondo del menú

                  Container(          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFD5E5FA),
                    child: Text(
                      iniciales,
                      style: const TextStyle(
                        color: Color(0xFF173B64),
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
                          ),
                        ),
                        Text(
                          widget.rol,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  ),
)
: null,


        body: Row(        children: [
          // ---------------- MENU LATERAL (SIDEBAR) ----------------
        if (!esPantallaPequena)
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Logo y Subtítulo SIGELAB
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

                // Secciones del Menú
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                      _buildMenuItem(0, Icons.grid_view_rounded, 'Dashboard'),
                      _buildMenuItem(1, Icons.people_outline, 'Usuarios'),
                      _buildMenuItem(2, Icons.science_outlined, 'Laboratorios'),
                      _buildMenuItem(3, Icons.devices_outlined, 'Tipos de Equipo'),
                      _buildMenuItem(4, Icons.inventory_2_outlined, 'Inventario y Equipos'),
                      _buildMenuItem(5, Icons.front_hand_outlined, 'Préstamos'),
                      _buildMenuItem(6, Icons.replay, 'Devoluciones'),
                    ],
                  ),
                ),

                // Perfil de usuario dinámico e Iniciar/Cerrar sesión en el pie
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
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
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.nombreUsuario,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  widget.rol,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: const Row(
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // ---------------- CONTENIDO PRINCIPAL ----------------
          Expanded(
            child: Column(
              children: [
                // Encabezado Superior (Header)
                Container(

                  padding: EdgeInsets.symmetric(
                    horizontal: esPantallaPequena ? 12 : 32,
                    vertical: esPantallaPequena ? 12 : 18,
                  ),


                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                    if (esPantallaPequena)
                      IconButton(
                        icon: const Icon(Icons.menu),
                        color: primaryDark,
                        tooltip: 'Abrir menú',
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                      ),


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
                                fontSize: esPantallaPequena ? 18 : 26,
                                fontWeight: FontWeight.bold,
                                color: primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Pill de perfil en la esquina superior derecha dinámico
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.menu, size: 16, color: Colors.black54),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.nombreUsuario} · ${widget.rol}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: primaryDark,
                              child: Text(
                                iniciales,
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Vista dinámica según el elemento seleccionado en el menú
                Expanded(
                  child: _buildBodyContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  // Renderiza la pantalla correspondiente al menú seleccionado
  Widget _buildBodyContent() {
    switch (_selectedIndex) {
      case 2:
        return const LaboratoriosScreen(); // Vista real conectada a BD
      
      case 3:
        return TiposEquipoScreen(
          idUsuarioAccionante: widget.idUsuario,
        );
      default:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: primaryDark,
                ),
                const SizedBox(height: 20),
                Text(
                  '¡Bienvenido a SIGELAB!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Conexión exitosa con el servidor backend en AWS EC2.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sección de métricas y gráficos en desarrollo...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.dashboard, color: Colors.white),
                  label: const Text(
                    'Ir al Dashboard',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }

  // Helper para construir ítems del menú con estado de selección
  Widget _buildMenuItem(int index, IconData icon, String title) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? primaryDark : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.black87,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  // Título dinámico para la cabecera
  String _obtenerTitulo(int index) {
    switch (index) {
      case 0:
        return 'Dashboard general';
      case 1:
        return 'Gestión de Usuarios';
      case 2:
        return 'Gestión de laboratorios';
      case 3:
        return 'Tipos de Equipo';
      case 4:
        return 'Inventario y Equipos';
      case 5:
        return 'Préstamos de Equipos';
      case 6:
        return 'Devoluciones';
      default:
        return 'Dashboard general';
    }
  }
}