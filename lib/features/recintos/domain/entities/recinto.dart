class Recinto {
  final String? id;
  final String nombre;
  final String provincia;
  final String canton;
  final String parroquia;
  final int numeroJRV;
  final String? coordinadorId;

  Recinto({
    this.id,
    required this.nombre,
    required this.provincia,
    required this.canton,
    required this.parroquia,
    required this.numeroJRV,
    this.coordinadorId,
  });
}
