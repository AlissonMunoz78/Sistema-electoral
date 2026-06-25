import '../../domain/entities/recinto.dart';

class RecintoModel extends Recinto {
  RecintoModel({
    String? id,
    required String nombre,
    required String provincia,
    required String canton,
    required String parroquia,
    required int numeroJRV,
    String? coordinadorId,
  }) : super(
          id: id,
          nombre: nombre,
          provincia: provincia,
          canton: canton,
          parroquia: parroquia,
          numeroJRV: numeroJRV,
          coordinadorId: coordinadorId,
        );

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
