import '../entities/acta.dart';

abstract class ActaRepository {
  Future<void> crearActa(Acta acta);
  Future<List<Acta>> obtenerActas({String? userId});
  Future<void> actualizarActa(String id, Acta acta);
}
