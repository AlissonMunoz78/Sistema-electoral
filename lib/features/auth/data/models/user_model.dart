import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.mustChangePassword,
    this.recintoId,
    this.mesaId,
    this.nombre,
  });

  final String? recintoId;
  final int? mesaId;
  final String? nombre;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['\$id'] as String? ?? '',
      email: json['correo'] as String? ?? '',
      role: _parseRole(json['rol'] as String? ?? 'veedor'),
      mustChangePassword: (json['primerLogin'] as String? ?? 'true') == 'true',
      recintoId: json['recintold'] as String?,
      mesaId: null,
      nombre: '${json['nombres'] ?? ''} ${json['apellidos'] ?? ''}'.trim(),
    );
  }

  Map<String, dynamic> toJson() => {
    'email': email,
    'role': role.name,
    'mustChangePassword': mustChangePassword,
    'recintoId': recintoId,
    'mesaId': mesaId,
    'nombre': nombre,
  };

  static UserRole _parseRole(String role) {
    switch (role) {
      case 'coordinatorProvincial':
      case 'provincial':
        return UserRole.coordinatorProvincial;
      case 'coordinatorRecinto':
      case 'recinto':
        return UserRole.coordinatorRecinto;
      default:
        return UserRole.observer;
    }
  }
}
