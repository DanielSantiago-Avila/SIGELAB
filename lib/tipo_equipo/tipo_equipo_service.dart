
import 'tipo_equipo_model.dart';

class TipoEquipoService {
  // Datos temporales mientras se conecta el backend.
  static final List<TipoEquipo> _tiposEquipo = [
    TipoEquipo(
      idTipoEquipo: 1,
      codigo: 'LAP-001',
      nombre: 'Laptop',
      marca: 'Dell',
      modelo: 'Latitude',
      descripcion: 'Computadora portátil para uso académico',
      activo: true,
    ),
    TipoEquipo(
      idTipoEquipo: 2,
      codigo: 'PRO-001',
      nombre: 'Proyector',
      marca: 'Epson',
      modelo: 'PowerLite',
      descripcion: 'Equipo de proyección audiovisual',
      activo: true,
    ),
    TipoEquipo(
      idTipoEquipo: 3,
      codigo: 'CAM-001',
      nombre: 'Cámara',
      marca: 'Canon',
      modelo: 'EOS',
      descripcion: 'Equipo para fotografía y video',
      activo: false,
    ),
  ];

  // 1. Listar todos los tipos de equipo
  Future<List<TipoEquipo>> listar() async {
    return List.unmodifiable(_tiposEquipo);
  }

  // 2. Obtener un tipo de equipo por su ID
  Future<TipoEquipo?> obtenerPorId(int idTipoEquipo) async {
    for (final tipo in _tiposEquipo) {
      if (tipo.idTipoEquipo == idTipoEquipo) {
        return tipo;
      }
    }
    return null;
  }

  // 3. Listar solamente los tipos activos
  Future<List<TipoEquipo>> listarActivos() async {
    return List.unmodifiable(
      _tiposEquipo.where((tipo) => tipo.activo),
    );
  }

  // 4. Crear un nuevo tipo de equipo
  Future<TipoEquipo> crear(TipoEquipo nuevo) async {
    final codigo = nuevo.codigo.trim();
    final nombre = nuevo.nombre.trim();

    if (codigo.isEmpty || nombre.isEmpty) {
      throw Exception('El código y nombre son obligatorios.');
    }

    final duplicado = _tiposEquipo.any(
      (tipo) => tipo.codigo.toLowerCase() ==
          codigo.toLowerCase(),
    );

    if (duplicado) {
      throw Exception('Ya existe un tipo de equipo con ese código.');
    }

    int nuevoId = 1;

    for (final tipo in _tiposEquipo) {
      if (tipo.idTipoEquipo >= nuevoId) {
        nuevoId = tipo.idTipoEquipo + 1;
      }
    }

    final creado = nuevo.copyWith(
      idTipoEquipo: nuevoId,
      codigo: codigo,
      nombre: nombre,
      activo: true,
    );

    _tiposEquipo.add(creado);
    return creado;
  }

  // 5. Actualizar un tipo de equipo
  Future<TipoEquipo> actualizar(TipoEquipo actualizado) async {
    final indice = _tiposEquipo.indexWhere(
      (tipo) => tipo.idTipoEquipo == actualizado.idTipoEquipo,
    );

    if (indice == -1) {
      throw Exception('Tipo de equipo no encontrado.');
    }

    final codigo = actualizado.codigo.trim();
    final nombre = actualizado.nombre.trim();

    if (codigo.isEmpty || nombre.isEmpty) {
      throw Exception('El código y nombre son obligatorios.');
    }

    final duplicado = _tiposEquipo.any(
      (tipo) =>
          tipo.idTipoEquipo != actualizado.idTipoEquipo &&
          tipo.codigo.toLowerCase() == codigo.toLowerCase(),
    );

    if (duplicado) {
      throw Exception('Ya existe un tipo de equipo con ese código.');
    }

    final guardado = actualizado.copyWith(
      codigo: codigo,
      nombre: nombre,
      activo: _tiposEquipo[indice].activo,
    );

    _tiposEquipo[indice] = guardado;
    return guardado;
  }

  // 6. Desactivar un tipo de equipo
  Future<void> desactivar(int idTipoEquipo) async {
    final indice = _tiposEquipo.indexWhere(
      (tipo) => tipo.idTipoEquipo == idTipoEquipo,
    );

    if (indice == -1) {
      throw Exception('Tipo de equipo no encontrado.');
    }

    if (!_tiposEquipo[indice].activo) {
      throw Exception('El tipo de equipo ya está inactivo.');
    }

    _tiposEquipo[indice] = _tiposEquipo[indice].copyWith(
      activo: false,
    );
  }

  // 7. Activar un tipo de equipo
  Future<void> activar(int idTipoEquipo) async {
    final indice = _tiposEquipo.indexWhere(
      (tipo) => tipo.idTipoEquipo == idTipoEquipo,
    );

    if (indice == -1) {
      throw Exception('Tipo de equipo no encontrado.');
    }

    if (_tiposEquipo[indice].activo) {
      throw Exception('El tipo de equipo ya está activo.');
    }

    _tiposEquipo[indice] = _tiposEquipo[indice].copyWith(
      activo: true,
    );
  }
}
