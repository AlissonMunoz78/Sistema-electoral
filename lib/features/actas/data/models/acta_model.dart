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
      junta: json['junta'],
      provincia: json['provincia'],
      canton: json['canton'],
      parroquia: json['parroquia'],
      votosA: json['votosA'],
      votosB: json['votosB'],
      blancos: json['blancos'],
      nulos: json['nulos'],
      fotoId: json['fotoId'],
      fecha: DateTime.parse(json['fecha']),
      imagenValida: json['imagenValida'],
    );
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