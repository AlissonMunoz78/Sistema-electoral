import '../../domain/entities/recinto.dart';

class RecintoModel extends Recinto {
  RecintoModel({
    super.id,
    required super.nombre,
    required super.provincia,
    required super.canton,
    required super.parroquia,
    required super.numeroJRV,
    super.coordinadorId,
  });

  factory RecintoModel.fromJson(Map<String, dynamic> json) {
    return RecintoModel(
      id: json['\$id'] as String?,
      nombre: json['nombre'] as String? ?? '',
      provincia: json['provincia'] as String? ?? '',
      canton: json['canton'] as String? ?? '',
      parroquia: json['parroquia'] as String? ?? '',
      numeroJRV: json['numeroJRV'] as int? ?? 0,
      coordinadorId: json['coordinadorId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'nombre': nombre,
    'provincia': provincia,
    'canton': canton,
    'parroquia': parroquia,
    'numeroJRV': numeroJRV,
    'coordinadorId': coordinadorId,
  };
}
