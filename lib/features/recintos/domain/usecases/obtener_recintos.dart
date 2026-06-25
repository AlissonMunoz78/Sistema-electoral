import '../entities/recinto.dart';
import '../repositories/recinto_repository.dart';

class ObtenerRecintos {
  final RecintoRepository repository;
  ObtenerRecintos(this.repository);

  Future<List<Recinto>> call() => repository.obtenerRecintos();
}
