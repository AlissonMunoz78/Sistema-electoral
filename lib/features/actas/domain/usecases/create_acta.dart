import '../entities/acta.dart';
import '../repositories/acta_repository.dart';

class CrearActa {
  final ActaRepository repository;

  CrearActa(this.repository);

  Future<void> call(Acta acta) {
    return repository.crearActa(acta);
  }
}
