import '../../domain/entities/acta.dart';

class ActaModel extends Acta {
  ActaModel({
    required super.junta,
    required super.provincia,
    required super.canton,
    required super.parroquia,
    required super.votosA,
    required super.votosB,
    required super.blancos,
    required super.nulos,
    required super.fotoId,
    required super.fecha,
    required super.imagenValida,
  });

  factory ActaModel.fromJson(Map<String, dynamic> json) {
    return ActaModel(
      junta: _parseInt(json['junta']),
      provincia: _parseString(json['provincia']),
      canton: _parseString(json['canton']),
      parroquia: _parseString(json['parroquia']),
      votosA: _parseInt(json['votosA']),
      votosB: _parseInt(json['votosB']),
      blancos: _parseInt(json['blancos']),
      nulos: _parseInt(json['nulos']),
      fotoId: _parseString(json['fotoId']),
      fecha: _parseDateTime(json['fecha']),
      imagenValida: _parseBool(json['imagenValida']),
    );
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

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'junta': junta,
      'provincia': provincia,
      'canton': canton,
      'parroquia': parroquia,
      'votosA': votosA,
      'votosB': votosB,
      'blancos': blancos,
      'nulos': nulos,
      'fotoId': fotoId,
      'fecha': fecha.toIso8601String(),
      'imagenValida': imagenValida,
    };
  }
}