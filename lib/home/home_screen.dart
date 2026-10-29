import 'package:flutter/material.dart';
import '../login/login_screen.dart';
import 'package:sigelab/laboratorio/laboratorios_screen.dart';
import 'dashboard_screen.dart';
import '../mantenimiento/mantenimiento_screen.dart';

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

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Row(
        children: [
          // ---------------- MENU LATERAL (SIDEBAR) ----------------
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

                _buildMenuItem(
                  0, Icons.grid_view_rounded, 'Dashboard',
                ),
                _buildMenuItem(
                  1, Icons.people_outline, 'Usuarios',
                ),
                _buildMenuItem(
                  2, Icons.science_outlined, 'Laboratorios',
                ),
                _buildMenuItem(
                  3, Icons.devices_outlined, 'Tipos de Equipo',
                ),
                _buildMenuItem(
                  4, Icons.inventory_2_outlined, 'Inventario y Equipos',
                ),
                _buildMenuItem(
                  5, Icons.front_hand_outlined, 'Préstamos',
                ),
                _buildMenuItem(
                  6, Icons.replay, 'Devoluciones',
                ),
                _buildMenuItem(
                  7, Icons.build_outlined, 'Mantenimiento',
                ),
                _buildMenuItem(
                  8, Icons.bar_chart_outlined, 'Reportes',
                ),
                _buildMenuItem(
                  9, Icons.fact_check_outlined, 'Auditoría',
                ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                        ],
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
    );
  }
Widget _buildBodyContent() {
  switch (_selectedIndex) {
    case 0:
      return DashboardScreen();
    case 2:
      return const LaboratoriosScreen();
    case 7:
      return const MantenimientoScreen();
      
    default:
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 70,
                color: primaryDark,
              ),
              const SizedBox(height: 16),
              Text(
                _obtenerTitulo(_selectedIndex),
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
                style: TextStyle(color: Colors.grey),
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