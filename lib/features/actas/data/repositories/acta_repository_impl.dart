import '../../../../offline/hive_service.dart';
import '../../domain/entities/acta.dart';
import '../../domain/repositories/acta_repository.dart';
import '../datasources/acta_datasource.dart';
import '../models/acta_model.dart';

class ActaRepositoryImpl implements ActaRepository {
  final ActaDatasource datasource;
  final HiveService? hiveService;

  ActaRepositoryImpl(this.datasource, {this.hiveService});

  @override
  Future<void> crearActa(Acta acta, {String? fotoLocalPath}) async {
    try {
      String? existingDocId;
      if (acta.userId != null) {
        try {
          final existentes = await datasource.obtenerActas(userId: acta.userId);
          for (final doc in existentes) {
            if (doc['junta'] == acta.junta && doc['dignidad'] == acta.dignidad) {
              existingDocId = doc['\$id'] as String?;
              break;
            }
          }
        } catch (_) {}
      }

      if (existingDocId != null && existingDocId.isNotEmpty) {
        await datasource.actualizarActa(existingDocId, ActaModel(
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
        ).toJson());
      } else {
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
      }
    } catch (_) {
      if (hiveService != null) {
        await hiveService!.saveActaLocal(acta, fotoLocalPath: fotoLocalPath);
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
