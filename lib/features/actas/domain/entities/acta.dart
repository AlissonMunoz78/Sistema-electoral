class Acta {
  final int junta;
  final String provincia;
  final String canton;
  final String parroquia;
  final int votosA;
  final int votosB;
  final int blancos;
  final int nulos;
  final String fotoId;
  final DateTime fecha;
  final bool imagenValida;

  Acta({
    required this.junta,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.votosA,
    required this.votosB,
    required this.blancos,
    required this.nulos,
    required this.fotoId,
    required this.fecha,
    required this.imagenValida,
  });
}