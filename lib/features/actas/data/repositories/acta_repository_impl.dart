import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../offline/hive_service.dart';
import '../../domain/entities/acta.dart';
import '../../domain/repositories/acta_repository.dart';
import '../datasources/acta_datasource.dart';
import '../models/acta_model.dart';

// Limitación conocida: La sincronización offline usa estrategia "último en escribir gana".
// En escenarios con múltiples veedores offline en la misma mesa, podría haber pérdida de datos.
// Una solución más robusta requeriría MVCC o un servidor de reconciliación.
class ActaRepositoryImpl implements ActaRepository {
  final ActaDatasource datasource;
  final HiveService? hiveService;

  ActaRepositoryImpl(this.datasource, {this.hiveService});

  @override
  Future<void> crearActa(Acta acta) async {
    final connectivity = await Connectivity().checkConnectivity();
    final online = connectivity.any((r) => r != ConnectivityResult.none);

    if (!online && hiveService != null) {
      await hiveService!.saveActaLocal(acta);
      return;
    }

    try {
      await datasource.crearActa(ActaModel(
        junta: acta.junta,
        provincia: acta.provincia,
        canton: acta.canton,
        parroquia: acta.parroquia,
        dignidad: acta.dignidad,
        votosOrganizaciones: acta.votosOrganizaciones,
        blancos: acta.blancos,
        nulos: acta.nulos,
        totalSufragantes: acta.totalSufragantes,
        fotoId: acta.fotoId,
        fecha: acta.fecha,
        imagenValida: acta.imagenValida,
        latitud: acta.latitud,
        longitud: acta.longitud,
        userId: acta.userId,
      ));
    } catch (_) {
      if (hiveService != null) {
        await hiveService!.saveActaLocal(acta);
      } else {
        rethrow;
      }
    }
  }

  @override
  Future<List<Acta>> obtenerActas({String? userId}) async {
    try {
      final data = await datasource.obtenerActas(userId: userId);
      return data.map((e) {
        final docId = e['\$id'] as String?;
        return ActaModel.fromJson(e, docId: docId);
      }).toList();
    } catch (_) {
      if (hiveService != null) {
        return hiveService!.getAllLocalActas();
      }
      return [];
    }
  }

  @override
  Future<void> actualizarActa(String id, Acta acta) async {
    await datasource.actualizarActa(id, ActaModel(
      junta: acta.junta,
      provincia: acta.provincia,
      canton: acta.canton,
      parroquia: acta.parroquia,
      dignidad: acta.dignidad,
      votosOrganizaciones: acta.votosOrganizaciones,
      blancos: acta.blancos,
      nulos: acta.nulos,
      totalSufragantes: acta.totalSufragantes,
      fotoId: acta.fotoId,
      fecha: acta.fecha,
      imagenValida: acta.imagenValida,
      latitud: acta.latitud,
      longitud: acta.longitud,
      userId: acta.userId,
      id: id,
    ).toJson());
  }
}
