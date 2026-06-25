import '../../domain/entities/acta.dart';

class ActaModel extends Acta {
  ActaModel({
    required super.junta,
    required super.provincia,
    required super.canton,
    required super.parroquia,
    required super.dignidad,
    required super.votosOrganizaciones,
    required super.blancos,
    required super.nulos,
    required super.totalSufragantes,
    required super.fotoId,
    required super.fecha,
    required super.imagenValida,
    super.latitud,
    super.longitud,
    super.userId,
    super.id,
  });

  factory ActaModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return ActaModel(
      junta: _parseInt(json['junta']),
      provincia: _parseString(json['provincia']),
      canton: _parseString(json['canton']),
      parroquia: _parseString(json['parroquia']),
      dignidad: _parseString(json['dignidad']),
      votosOrganizaciones: _parseIntList(json['votosOrganizaciones']),
      blancos: _parseInt(json['blancos']),
      nulos: _parseInt(json['nulos']),
      totalSufragantes: _parseInt(json['totalSufragantes']),
      fotoId: _parseString(json['fotoId']),
      fecha: _parseDateTime(json['fecha']),
      imagenValida: _parseBool(json['imagenValida']),
      latitud: _parseNullableDouble(json['latitud']),
      longitud: _parseNullableDouble(json['longitud']),
      userId: _parseStringNullable(json['userId']),
      id: docId ?? json['\$id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'junta': junta,
    'provincia': provincia,
    'canton': canton,
    'parroquia': parroquia,
    'dignidad': dignidad,
    'votosOrganizaciones': votosOrganizaciones,
    'blancos': blancos,
    'nulos': nulos,
    'totalSufragantes': totalSufragantes,
    'fotoId': fotoId,
    'fecha': fecha.toIso8601String(),
    'imagenValida': imagenValida,
    'latitud': latitud,
    'longitud': longitud,
    'userId': userId,
  };

  static double? _parseNullableDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _parseString(dynamic value) {
    if (value is String) return value;
    return '';
  }

  static String? _parseStringNullable(dynamic value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static List<int> _parseIntList(dynamic value) {
    if (value is List) return value.map((e) => _parseInt(e)).toList();
    return List.filled(5, 0);
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
