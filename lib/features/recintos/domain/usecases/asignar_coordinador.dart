import '../repositories/recinto_repository.dart';

class AsignarCoordinador {
  final RecintoRepository repository;
  AsignarCoordinador(this.repository);

  Future<void> call(String recintoId, String userId) =>
      repository.asignarCoordinador(recintoId, userId);
}
