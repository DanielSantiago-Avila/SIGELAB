class EquipoModel {
  final int idEquipo;
  final int idTipoEquipo;
  final int idLaboratorio;

  final String codigoInventario;
  final String tipoEquipo;
  final String marca;
  final String modelo;
  final String numeroSerie;
  final String laboratorio;
  final String estado;
  final String observaciones;
  final String codigoQR;

  const EquipoModel({
    this.idEquipo = 0,
    this.idTipoEquipo = 0,
    this.idLaboratorio = 0,
    required this.codigoInventario,
    this.tipoEquipo = '',
    this.marca = '',
    this.modelo = '',
    this.numeroSerie = '',
    this.laboratorio = '',
    this.estado = 'DISPONIBLE',
    this.observaciones = '',
    this.codigoQR = '',
  });

  factory EquipoModel.fromJson(Map<String, dynamic> json) {
    dynamic obtener(List<String> claves) {
      for (final clave in claves) {
        if (json.containsKey(clave) && json[clave] != null) {
          return json[clave];
        }
      }
      return null;
    }

    int convertirId(dynamic valor) {
      if (valor is int) return valor;
      return int.tryParse(valor?.toString() ?? '') ?? 0;
    }

    String convertirTexto(dynamic valor) {
      if (valor == null) return '';

      if (valor is Map) {
        return (valor['nombre'] ??
                valor['Nombre'] ??
                valor['descripcion'] ??
                '')
            .toString();
      }

      return valor.toString();
    }

    final tipo = obtener([
      'tipoEquipo',
      'TipoEquipo',
      'nombreTipoEquipo',
      'NombreTipoEquipo',
    ]);

    final laboratorio = obtener([
      'laboratorio',
      'Laboratorio',
      'nombreLaboratorio',
      'NombreLaboratorio',
    ]);

    return EquipoModel(
      idEquipo: convertirId(
        obtener([
          'idEquipo',
          'IdEquipo',
          'id_equipo',
          'id',
        ]),
      ),
      idTipoEquipo: convertirId(
        obtener([
          'idTipoEquipo',
          'IdTipoEquipo',
          'id_tipo_equipo',
        ]),
      ),
      idLaboratorio: convertirId(
        obtener([
          'idLaboratorio',
          'IdLaboratorio',
          'id_laboratorio',
        ]),
      ),
      codigoInventario: convertirTexto(
        obtener([
          'codigoInventario',
          'CodigoInventario',
          'codigo',
          'Codigo',
          'codigoEquipo',
        ]),
      ),
      tipoEquipo: convertirTexto(tipo),
      marca: convertirTexto(
        obtener(['marca', 'Marca']),
      ),
      modelo: convertirTexto(
        obtener(['modelo', 'Modelo']),
      ),
      numeroSerie: convertirTexto(
        obtener([
          'numeroSerie',
          'NumeroSerie',
          'serie',
          'Serie',
          'numero_serie',
        ]),
      ),
      laboratorio: convertirTexto(laboratorio),
      estado: convertirTexto(
            obtener(['estado', 'Estado']),
          ).isEmpty
          ? 'DISPONIBLE'
          : convertirTexto(
              obtener(['estado', 'Estado']),
            ),
      observaciones: convertirTexto(
        obtener([
          'observaciones',
          'Observaciones',
          'descripcion',
          'Descripcion',
        ]),
      ),
      codigoQR: convertirTexto(
        obtener([
          'codigoQR',
          'CodigoQR',
          'qr',
          'QR',
          'codigoQr',
        ]),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEquipo': idEquipo,
      'idTipoEquipo': idTipoEquipo,
      'idLaboratorio': idLaboratorio,
      'codigoInventario': codigoInventario,
      'tipoEquipo': tipoEquipo,
      'marca': marca,
      'modelo': modelo,
      'numeroSerie': numeroSerie,
      'laboratorio': laboratorio,
      'estado': estado,
      'observaciones': observaciones,
      'codigoQR': codigoQR,
    };
  }

  EquipoModel copyWith({
    int? idEquipo,
    int? idTipoEquipo,
    int? idLaboratorio,
    String? codigoInventario,
    String? tipoEquipo,
    String? marca,
    String? modelo,
    String? numeroSerie,
    String? laboratorio,
    String? estado,
    String? observaciones,
    String? codigoQR,
  }) {
    return EquipoModel(
      idEquipo: idEquipo ?? this.idEquipo,
      idTipoEquipo: idTipoEquipo ?? this.idTipoEquipo,
      idLaboratorio: idLaboratorio ?? this.idLaboratorio,
      codigoInventario: codigoInventario ?? this.codigoInventario,
      tipoEquipo: tipoEquipo ?? this.tipoEquipo,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      numeroSerie: numeroSerie ?? this.numeroSerie,
      laboratorio: laboratorio ?? this.laboratorio,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      codigoQR: codigoQR ?? this.codigoQR,
    );
  }
}