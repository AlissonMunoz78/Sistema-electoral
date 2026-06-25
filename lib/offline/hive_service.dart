import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../features/actas/domain/entities/acta.dart';

class HiveService {
  static const String _boxName = 'offline_actas';
  static const String _pendingBoxName = 'pending_sync';
  late Box<String> _box;
  late Box<String> _pendingBox;

  static Future<HiveService> init() async {
    await Hive.initFlutter();
    final service = HiveService();
    service._box = await Hive.openBox<String>(_boxName);
    service._pendingBox = await Hive.openBox<String>(_pendingBoxName);
    return service;
  }

  Future<void> saveActaLocal(Acta acta) async {
    final key = '${acta.junta}_${acta.dignidad}_${DateTime.now().millisecondsSinceEpoch}';
    await _box.put(key, jsonEncode({
      'junta': acta.junta,
      'provincia': acta.provincia,
      'canton': acta.canton,
      'parroquia': acta.parroquia,
      'dignidad': acta.dignidad,
      'votosOrganizaciones': acta.votosOrganizaciones,
      'blancos': acta.blancos,
      'nulos': acta.nulos,
      'totalSufragantes': acta.totalSufragantes,
      'fotoId': acta.fotoId,
      'fecha': acta.fecha.toIso8601String(),
      'imagenValida': acta.imagenValida,
      'latitud': acta.latitud,
      'longitud': acta.longitud,
      'userId': acta.userId,
      'synced': false,
    }));
    await _pendingBox.put(key, 'pending');
  }

  Future<List<Map<String, dynamic>>> getPendingActas() async {
    final keys = _pendingBox.keys.toList();
    final result = <Map<String, dynamic>>[];
    for (final key in keys) {
      final data = _box.get(key);
      if (data != null) {
        result.add({...jsonDecode(data) as Map<String, dynamic>, '_key': key});
      }
    }
    return result;
  }

  Future<void> markSynced(String key) async {
    await _pendingBox.delete(key);
    final data = _box.get(key);
    if (data != null) {
      final map = jsonDecode(data) as Map<String, dynamic>;
      map['synced'] = true;
      await _box.put(key, jsonEncode(map));
    }
  }

  Future<void> removeActa(String key) async {
    await _box.delete(key);
    await _pendingBox.delete(key);
  }

  Future<List<Acta>> getAllLocalActas() async {
    final keys = _box.keys.toList();
    final result = <Acta>[];
    for (final key in keys) {
      final data = _box.get(key);
      if (data != null) {
        final map = jsonDecode(data) as Map<String, dynamic>;
        result.add(Acta(
          junta: map['junta'] as int,
          provincia: map['provincia'] as String? ?? '',
          canton: map['canton'] as String? ?? '',
          parroquia: map['parroquia'] as String? ?? '',
          dignidad: map['dignidad'] as String? ?? 'alcalde',
          votosOrganizaciones: (map['votosOrganizaciones'] as List).cast<int>(),
          blancos: map['blancos'] as int? ?? 0,
          nulos: map['nulos'] as int? ?? 0,
          totalSufragantes: map['totalSufragantes'] as int? ?? 0,
          fotoId: map['fotoId'] as String? ?? '',
          fecha: DateTime.parse(map['fecha'] as String),
          imagenValida: map['imagenValida'] as bool? ?? true,
          latitud: map['latitud'] as double?,
          longitud: map['longitud'] as double?,
          userId: map['userId'] as String?,
        ));
      }
    }
    return result;
  }

  bool hasPending() => _pendingBox.isNotEmpty;
}
