import '../entities/recinto.dart';

abstract class RecintoRepository {
  Future<void> crearRecinto(Recinto recinto);
  Future<List<Recinto>> obtenerRecintos();
  Future<Recinto?> obtenerRecinto(String id);
  Future<void> asignarCoordinador(String recintoId, String userId);
}
