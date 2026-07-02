extension ActaListDedup on List<Acta> {
  List<Acta> latestPerJuntaDignidad() {
    final map = <String, Acta>{};
    for (final a in this) {
      final key = '${a.junta}_${a.dignidad}';
      final existing = map[key];
      if (existing == null || a.fecha.isAfter(existing.fecha)) {
        map[key] = a;
      }
    }
    return map.values.toList();
  }
}

class Acta {
  final int junta;
  final String provincia;
  final String canton;
  final String parroquia;
  final String dignidad;
  final List<int> votosOrganizaciones;
  final int blancos;
  final int nulos;
  final int totalSufragantes;
  final String fotoId;
  final DateTime fecha;
  final bool imagenValida;
  final double? latitud;
  final double? longitud;
  final String? userId;
  final String? id;

  Acta({
    required this.junta,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.dignidad,
    required this.votosOrganizaciones,
    required this.blancos,
    required this.nulos,
    required this.totalSufragantes,
    required this.fotoId,
    required this.fecha,
    required this.imagenValida,
    this.latitud,
    this.longitud,
    this.userId,
    this.id,
  });

  int get totalVotos =>
      votosOrganizaciones.fold(0, (a, b) => a + b) + blancos + nulos;

  bool get isValid => totalVotos <= totalSufragantes;

  Acta copyWith({
    int? junta,
    String? provincia,
    String? canton,
    String? parroquia,
    String? dignidad,
    List<int>? votosOrganizaciones,
    int? blancos,
    int? nulos,
    int? totalSufragantes,
    String? fotoId,
    DateTime? fecha,
    bool? imagenValida,
    double? latitud,
    double? longitud,
    String? userId,
    String? id,
  }) {
    return Acta(
      junta: junta ?? this.junta,
      provincia: provincia ?? this.provincia,
      canton: canton ?? this.canton,
      parroquia: parroquia ?? this.parroquia,
      dignidad: dignidad ?? this.dignidad,
      votosOrganizaciones: votosOrganizaciones ?? List.from(this.votosOrganizaciones),
      blancos: blancos ?? this.blancos,
      nulos: nulos ?? this.nulos,
      totalSufragantes: totalSufragantes ?? this.totalSufragantes,
      fotoId: fotoId ?? this.fotoId,
      fecha: fecha ?? this.fecha,
      imagenValida: imagenValida ?? this.imagenValida,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      userId: userId ?? this.userId,
      id: id ?? this.id,
    );
  }
}
