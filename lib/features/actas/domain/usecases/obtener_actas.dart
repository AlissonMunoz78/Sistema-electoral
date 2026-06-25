import '../entities/acta.dart';
import '../repositories/acta_repository.dart';

class ObtenerActas {
  final ActaRepository repository;

  ObtenerActas(this.repository);

  Future<List<Acta>> call() {
    return repository.obtenerActas();
  }
}