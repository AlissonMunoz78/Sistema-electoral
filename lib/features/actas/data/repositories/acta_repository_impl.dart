import '../../domain/entities/acta.dart';
import '../../domain/repositories/acta_repository.dart';
import '../datasources/acta_datasource.dart';
import '../models/acta_model.dart';

class ActaRepositoryImpl implements ActaRepository {
  final ActaDatasource datasource;

  ActaRepositoryImpl(this.datasource);

  @override
  Future<void> crearActa(Acta acta) {
    return datasource.crearActa(ActaModel(
      junta: acta.junta,
      provincia: acta.provincia,
      canton: acta.canton,
      parroquia: acta.parroquia,
      votosA: acta.votosA,
      votosB: acta.votosB,
      blancos: acta.blancos,
      nulos: acta.nulos,
      fotoId: acta.fotoId,
      fecha: acta.fecha,
      imagenValida: acta.imagenValida,
    ));
  }

  @override
  Future<List<Acta>> obtenerActas() async {
    final data = await datasource.obtenerActas();

    return data.map((e) => ActaModel.fromJson(e)).toList();
  }
}