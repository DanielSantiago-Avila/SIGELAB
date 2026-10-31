import 'package:flutter/material.dart';

import '../prestamos/prestamo_screen.dart';

import '../sesion/sesion_usuario.dart';

class QrResultadoScreen extends StatelessWidget {
  final Map<String, dynamic> equipo;

  const QrResultadoScreen({super.key, required this.equipo});

  @override
  Widget build(BuildContext context) {
    final estado = (equipo['estado'] ?? 'DESCONOCIDO').toString().toUpperCase();

    final disponible = estado == 'DISPONIBLE';
    final activo = equipo['activo'] == true;

    return Scaffold(
      appBar: AppBar(title: const Text('Información del equipo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.devices, size: 75, color: Colors.blue),
          const SizedBox(height: 16),

          Text(
            equipo['tipoEquipo']?.toString() ?? 'Equipo',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          const SizedBox(height: 12),

          Center(
            child: Chip(
              label: Text(estado),
              backgroundColor: disponible
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
            ),
          ),

          const SizedBox(height: 24),

          Card(
            child: Column(
              children: [
                _dato('Código de inventario', equipo['codigoInventario']),
                _dato('Código QR', equipo['codigoQR']),
                _dato('Número de serie', equipo['numeroSerie']),
                _dato('Laboratorio', equipo['laboratorio']),
                _dato('Estado', equipo['estado']),
                _dato('Observaciones', equipo['observaciones']),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (!activo)
            const Text(
              'Este equipo se encuentra inactivo.',
              textAlign: TextAlign.center,
            )
          else if (disponible)
            FilledButton.icon(
              onPressed: () {
                final idUsuario = SesionUsuario.idUsuario;

                if (idUsuario == null || idUsuario <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'No se encontró una sesión de usuario válida.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrestamoScreen(
                      equipo: equipo,
                      idUsuarioAccionante: idUsuario,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.assignment_turned_in),
              label: const Text('Iniciar préstamo'),
            )
          else
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Próximamente: consultar devolución.'),
                  ),
                );
              },
              icon: const Icon(Icons.assignment_return),
              label: const Text('Consultar devolución'),
            ),

          const SizedBox(height: 12),

          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Escanear otro equipo'),
          ),
        ],
      ),
    );
  }

  Widget _dato(String titulo, dynamic valor) {
    return ListTile(
      title: Text(titulo),
      subtitle: Text(valor?.toString() ?? 'No disponible'),
    );
  }
}
