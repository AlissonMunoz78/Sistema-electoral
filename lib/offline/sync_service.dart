import '../features/actas/data/datasources/acta_datasource.dart';
import '../features/actas/data/models/acta_model.dart';
import 'hive_service.dart';

class SyncService {
  final HiveService _hive;
  final ActaDatasource _datasource;

  SyncService(this._hive, this._datasource);

  Future<void> syncPendingActas() async {
    final pending = await _hive.getPendingActas();
    for (final item in pending) {
      try {
        final key = item['_key'] as String;
        await _datasource.crearActa(ActaModel(
          junta: item['junta'] as int,
          provincia: item['provincia'] as String? ?? '',
          canton: item['canton'] as String? ?? '',
          parroquia: item['parroquia'] as String? ?? '',
          dignidad: item['dignidad'] as String? ?? 'alcalde',
          votosOrganizaciones: (item['votosOrganizaciones'] as List).cast<int>(),
          blancos: item['blancos'] as int? ?? 0,
          nulos: item['nulos'] as int? ?? 0,
          totalSufragantes: item['totalSufragantes'] as int? ?? 0,
          fotoId: item['fotoId'] as String? ?? '',
          fecha: DateTime.parse(item['fecha'] as String),
          imagenValida: item['imagenValida'] as bool? ?? true,
          latitud: item['latitud'] as double?,
          longitud: item['longitud'] as double?,
          userId: item['userId'] as String?,
        ));
        await _hive.markSynced(key);
      } catch (_) {
        // Conflict: keep as pending for next sync
      }
    }
  }
}
