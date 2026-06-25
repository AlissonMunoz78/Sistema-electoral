import '../entities/recinto.dart';
import '../repositories/recinto_repository.dart';

class CrearRecinto {
  final RecintoRepository repository;
  CrearRecinto(this.repository);

  Future<void> call(Recinto recinto) => repository.crearRecinto(recinto);
}
