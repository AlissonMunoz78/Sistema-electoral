import '../entities/acta.dart';
import '../repositories/acta_repository.dart';

class ActualizarActa {
  final ActaRepository repository;

  ActualizarActa(this.repository);

  Future<void> call(String id, Acta acta) {
    return repository.actualizarActa(id, acta);
  }
}
