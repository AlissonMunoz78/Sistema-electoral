import '../../domain/entities/recinto.dart';
import '../../domain/repositories/recinto_repository.dart';
import '../datasources/recinto_datasource.dart';
import '../models/recinto_model.dart';

class RecintoRepositoryImpl implements RecintoRepository {
  final RecintoDatasource datasource;

  RecintoRepositoryImpl(this.datasource);

  @override
  Future<void> crearRecinto(Recinto recinto) async {
    await datasource.crearRecinto(RecintoModel(
      nombre: recinto.nombre,
      provincia: recinto.provincia,
      canton: recinto.canton,
      parroquia: recinto.parroquia,
      numeroJRV: recinto.numeroJRV,
      coordinadorId: recinto.coordinadorId,
    ));
  }

  @override
  Future<List<Recinto>> obtenerRecintos() async {
    final data = await datasource.obtenerRecintos();
    return data.map((e) => RecintoModel.fromJson(e)).toList();
  }

  @override
  Future<Recinto?> obtenerRecinto(String id) async {
    final data = await datasource.obtenerRecinto(id);
    if (data == null) return null;
    return RecintoModel.fromJson({...data, '\$id': id});
  }

  @override
  Future<void> asignarCoordinador(String recintoId, String userId) async {
    await datasource.actualizarRecinto(recintoId, {'coordinadorId': userId});
  }
}
