import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/appwrite_client.dart';
import '../core/storage_service.dart';
import '../features/actas/data/datasources/acta_datasource.dart';
import '../features/actas/data/models/acta_model.dart';
import 'hive_service.dart';

class SyncService {
  final HiveService _hive;
  final ActaDatasource _datasource;
  final StorageService _storage = StorageService(storage);
  static const int _maxRetries = 3;

  SyncService(this._hive, this._datasource);

  Future<void> syncPendingActas() async {
    final connectivity = await Connectivity().checkConnectivity();
    final online = connectivity.any((r) => r != ConnectivityResult.none);
    if (!online) return;

    final pending = await _hive.getPendingActas();
    if (pending.isEmpty) return;

    for (final item in pending) {
      await _syncSingleActa(item);
    }
  }

  Future<void> _syncSingleActa(Map<String, dynamic> item) async {
    final key = item['_key'] as String;
    final retryCount = item['retryCount'] as int? ?? 0;

    if (retryCount >= _maxRetries) {
      await _hive.markFailed(key);
      return;
    }

    try {
      final fotoLocalPath = item['fotoLocalPath'] as String?;
      String fotoId = item['fotoId'] as String? ?? '';

      if (fotoId.isEmpty && fotoLocalPath != null && fotoLocalPath.isNotEmpty) {
        final file = File(fotoLocalPath);
        if (await file.exists()) {
          try {
            fotoId = await _storage.uploadImage(file);
          } catch (_) {
            await _hive.incrementRetry(key);
            return;
          }
        }
      }

      final userId = item['userId'] as String?;
      final junta = item['junta'] as int;
      final dignidad = item['dignidad'] as String? ?? 'alcalde';

      String? existingDocId;
      if (userId != null) {
        try {
          final existentes = await _datasource.obtenerActas(userId: userId);
          for (final doc in existentes) {
            if (doc['junta'] == junta && doc['dignidad'] == dignidad) {
              existingDocId = doc['\$id'] as String?;
              break;
            }
          }
        } catch (_) {}
      }

      final model = ActaModel(
        junta: junta,
        provincia: item['provincia'] as String? ?? '',
        canton: item['canton'] as String? ?? '',
        parroquia: item['parroquia'] as String? ?? '',
        dignidad: dignidad,
        votosOrganizaciones: (item['votosOrganizaciones'] as List).cast<int>(),
        blancos: item['blancos'] as int? ?? 0,
        nulos: item['nulos'] as int? ?? 0,
        totalSufragantes: item['totalSufragantes'] as int? ?? 0,
        fotoId: fotoId,
        fecha: DateTime.parse(item['fecha'] as String),
        imagenValida: item['imagenValida'] as bool? ?? true,
        latitud: item['latitud'] as double?,
        longitud: item['longitud'] as double?,
        userId: userId,
      );

      if (existingDocId != null && existingDocId.isNotEmpty) {
        await _datasource.actualizarActa(existingDocId, model.toJson());
      } else {
        await _datasource.crearActa(model);
      }

      await _hive.markSynced(key);

      if (fotoLocalPath != null && fotoLocalPath.isNotEmpty) {
        final file = File(fotoLocalPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (_) {
      await _hive.incrementRetry(key);
    }
  }
}
